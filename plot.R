source("plot_utils.R")

N <- 10
p <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 200, 250, 300, 400, 500, 750, 1000)
d <- c(0.0025, 0.005, 0.025, 0.05, 0.25, 0.5)
r <- 10

dname <- "plot"
dir.create(path = dname, showWarnings = FALSE)
max_abs_offdiag <- function(mat) {
	return(max(0, abs((mat / diag(mat))[upper.tri(mat) & mat != 0])))
}

## Plot all scenarios with both methods (average)
pl <- ggmexp::plot_experiment(p = p, d = d, r = r, N = N, map = max_abs_offdiag, 
															reduce = mean, ename = "port",
															plot_title = "Partial orthogonalization",
															plot_ylab = "Average R")
ggsave(filename = "port_avg_max_abs_offdiag.pdf", plot = pl, device = "pdf", 
			 path = dname)

pl <- ggmexp::plot_experiment(p = p, d = d, r = r, N = N, map = max_abs_offdiag, 
															reduce = mean, ename = "diagdom", 
															plot_title = "Diagonal dominance", 
															plot_ylab = "Average R")
ggsave(filename = "diagdom_avg_max_abs_offdiag.pdf", plot = pl, device = "pdf", 
			 path = dname)

## Plot a comparison of sparsest vs densest scenario, with standard deviation
pl <- ggmexp::plot_comparison(
  p = p, d = d[1], N = N, map = max_abs_offdiag, reduce = mean,
  ename = c("diagdom", "port"),
  plot_title = paste0("d = ", d[1]), show_sd = TRUE, plot_ylab = "Average R"
)
ggsave(filename = paste0("cmp_avg_max_abs_offdiag_", d[1], ".pdf"), plot = pl, 
			 device = "pdf", path = dname)

pl <- ggmexp::plot_comparison(
  p = p, d = d[length(d)], N = N, map = max_abs_offdiag, reduce = mean, 
  ename = c("diagdom", "port"),
  plot_title = paste0("d = ", d[length(d)]), show_sd = TRUE, plot_ylab = "Average R"
)
ggsave(filename = paste0("cmp_avg_max_abs_offdiag_", d[length(d)], ".pdf"), plot = pl, 
			 device = "pdf", path = dname)


## Plot condition numbers of port matrices
p <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
pl <- ggmexp::plot_experiment(p = p, d = d, N = N, map = kappa, reduce = median, 
												ename = "port", plot_title = "Different structure densities",
												plot_ylab = "Median of K", exact = TRUE)
ggsave(filename = "port_median_kappa.pdf", plot = pl, device = "pdf", 
			 path = dname)

d <- c(0.0025, 0.005, 0.025, 0.05)
pl <- ggmexp::plot_experiment(p = p, d = d, N = N, map = kappa, reduce = median, 
												ename = "port", plot_title = "Sparse graph structures",
												plot_ylab = "Median of K", exact = TRUE)
ggsave(filename = "port_median_kappa_trimmed.pdf", plot = pl, device = "pdf", 
			 path = dname)

## Plot time comparison results
r <- 1
p <- seq(from = 10, to = 200, by = 10)
d <- c(0.0025, 0.005, 0.025, 0.05, 0.25, 0.5)
pl <- ggmexp::plot_experiment(p = p, d = d, r = r, N = N, 
															reduce = function(x){return(x)}, ename = "t_port",
															plot_title = "Partial orthogonalization",
															plot_ylab = "Execution time in seconds")
ggsave(filename = "time_port.pdf", plot = pl, device = "pdf", 
			 path = dname)

pl <- ggmexp::plot_experiment(p = p, d = d, r = r, N = N, 
															reduce = function(x){return(x)}, ename = "t_diagdom",
															plot_title = "Diagonal dominance",
															plot_ylab = "Execution time in seconds")
ggsave(filename = "time_port.pdf", plot = pl, device = "pdf", 
			 path = dname)
