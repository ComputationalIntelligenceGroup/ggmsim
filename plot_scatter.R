library(ggplot2)

f_diagdom <- function(N, amat) {
  ug <- igraph::graph_from_adjacency_matrix(amat, mode = "undirected")
  sample <- gmat::diagdom(N = N, ug = ug, rfun = rnorm)
  return(array(apply(sample, MARGIN = 3, cov2cor), dim = dim(sample)))
}
f_port <- function(N, amat) {
  ug <- igraph::graph_from_adjacency_matrix(amat, mode = "undirected")
  return(gmat::port(N = N, ug = ug))
}
f_unif <- function(N, amat) { # random: h = 10000
  dag <- igraph::graph_from_adjacency_matrix(amat, mode = "directed")
  return(gmat::chol_mh(N = N, dag = dag, h = 1000, eps = 0.5))
}
f_sample <- c(
  "diagdom" = f_diagdom,
  "port" = f_port,
  "unif" = f_unif
)
title <- c(
  "diagdom" = "Diagonal dominance",
  "port" = "Partial orthogonalization",
  "unif" = "Uniform"
)
method <- names(title)

plot_scatter <- function(m, N, amat) {
  sample <- f_sample[[m]](N, amat)
  sample <- as.data.frame(gmat::vectorize(sample))
  ggplot(sample) + 
    geom_point(aes(x = V1, y = V3), size = 0.1) + 
    coord_fixed() +
    xlab("") + 
    ylab("") + 
    ggtitle(title[m]) +
    ggsave(paste0("plot_3var_", m, ".pdf"), width = 3.6, height = 3.4)
}

N <- 5000
amat <- matrix(nrow = 3, ncol = 3, data = 0)
amat[1,2] <- 1
amat[2,3] <- 1

for (m in method) {
	plot_scatter(m, N, amat)
}

