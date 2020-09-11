library(ggplot2)

# Scatterplot for the chordal graph of 3 variables

f_diagdom <- function(N, amat) {
  ug <- igraph::graph_from_adjacency_matrix(amat, mode = "undirected")
  return(gmat::diagdom(N = N, ug = ug, rfun = rnorm))
}
f_port <- function(N, amat) {
  ug <- igraph::graph_from_adjacency_matrix(amat, mode = "undirected")
  return(gmat::port(N = N, ug = ug))
}
f_unif <- function(N, amat) {
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

dir_plot <- "plot_ext"
dir.create(path = dir_plot, showWarnings = FALSE)

plot_scatter <- function(m, N, amat) {
  sample <- f_sample[[m]](N, amat)
  sample <- as.data.frame(gmat::vectorize(sample))
  ggplot(sample) + 
    geom_point(aes(x = V1, y = V3), size = 0.1) + 
    coord_fixed() +
    xlab("") + 
    ylab("") + 
    ggtitle(title[m]) +
	theme_bw() +
	theme(text = element_text(size = 14)) +
    ggsave(paste0(dir_plot, "/", m, ".pdf"), width = 3.6, height = 3.4)
}

N <- 5000
amat <- matrix(nrow = 3, ncol = 3, data = 0)
amat[1,2] <- 1
amat[2,3] <- 1

for (m in method) {
	plot_scatter(m, N, amat)
}


# Comparison between a random and a chordal graph
p <- 50
d <- 0.05
N <- 5000

f_diagdom <- function(N, ug) {
	return(gmat::diagdom(N = N, ug = ug, rfun = rnorm))
}
f_port <- function(N, ug) {
	return(gmat::port(N = N, ug = ug))
}
f_port_chol <- function(N, ug) {
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
	"port_chol" = "Uniform (+ partial orthogonalization)"
)
method <- names(f_sample)

plot_density <- function(m, N, ug, exp) {
	madj <- igraph::as_adjacency_matrix(
		graph = ug, sparse = FALSE, type = "upper"
	)
	sample <- f_sample[[m]](N = N, ug = ug)
	reduced <- as.data.frame(t(apply(sample, 3, function(M) {
		return(M[madj == 1])
	})))
	ggplot(stack(reduced)) + geom_density(aes(x = values, group = ind, color =
	ind)) +
		xlab("") + ylab("") + ggtitle(title[m]) +
		theme_bw() +
		theme(text = element_text(size = 20), legend.position = "none") +
		ggsave(paste0(dir_plot, "/", exp, "_", m, ".pdf"), width = 7, height = 6)
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

