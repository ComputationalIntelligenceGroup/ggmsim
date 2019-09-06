library(ggplot2)

p <- 50
d <- 0.05
N <- 10000

f_diagdom <- function(N, ug) {
  sample <- gmat::diagdom(N = N, ug = ug, rfun = rnorm)
  return(array(apply(sample, MARGIN = 3, cov2cor), dim = dim(sample)))
}
f_port <- function(N, ug) {
  return(gmat::port(N = N, ug = ug))
}
f_port_chol <- function(N, ug) { # random: h = 10000
  return(gmat::port_chol(N = N, ug = ug, h = 1000, eps = 0.5))
}
f_sample <- c(
  "diagdom" = f_diagdom,
  "port" = f_port,
  "port_chol" = f_port_chol
)
title <- c(
  "diagdom" = "Diagonal dominance",
  "port" = "Partial orthogonalization",
  "port_chol" = "Uniform + partial orthogonalization"
)
method <- names(f_sample)

dir_plot <- "plot_densities"
dir.create(path = dir_plot, showWarnings = FALSE)

plot_density <- function(m, N, ug, exp) {
  madj <- igraph::as_adjacency_matrix(
    graph = ug, sparse = FALSE, type = "upper"
  )
  sample <- f_sample[[m]](N = N, ug = ug)
  reduced <- as.data.frame(t(apply(sample, 3, function(M) {
    return(M[madj == 1])
  })))
  ggplot(stack(reduced)) + geom_density(aes(x = values, group = ind)) +
    xlab("") + ylab("") + ggtitle(title[m]) +
	theme(text = element_text(size = 20)) +
    ggsave(paste0(dir_plot, "/", exp, "_", m, ".pdf"), width = 7, height = 4)
}

# Chain adjacency matrix
Adj <- matrix(nrow = p, ncol = p, 0)
for (i in 2:p) {
  Adj[i - 1, i] <- 1
}

ug_chain <- igraph::graph_from_adjacency_matrix(Adj, mode = "undirected")
ug_random <- gmat::rgraph(p = p, d = d)
ug_chordal <- gRbase::triangulate(igraph::as_graphnel(ug_random))
ug_chordal <- igraph::graph_from_graphnel(ug_chordal, name = FALSE)

for (m in method) {
  plot_density(m = m, N = N, ug = ug_chain, exp = "chain")
  plot_density(m = m, N = N, ug = ug_random, exp = "random")
  plot_density(m = m, N = N, ug = ug_chordal, exp = "chordal")
}
