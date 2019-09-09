source("plot_utils.R")

N <- 10
p <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 200, 250, 300, 400, 500, 750, 1000)
d <- c(0.0025, 0.005, 0.025, 0.05, 0.25, 0.5)
r <- 10
dir_name <- paste0("res_r", 1:r)

## Plot all scenarios with both methods (average)
plot_map_reduce(
  p = p, d = d, N = N, map = ext_abs_offdiag, reduce = mean, dir_name = dir_name,
  method = "port", fname = "port_avg_max_abs_offdiag.pdf", fext = max,
  show_sd = FALSE, plot_title = "Partial orthogonalization method",
  plot_ylab = "Average R"
)
plot_map_reduce(
  p = p, d = d, N = N, map = ext_abs_offdiag, reduce = mean, dir_name = dir_name,
  method = "diagdom", fname = "diagdom_avg_max_abs_offdiag.pdf",
  fext = max, show_sd = FALSE, plot_title = "Diagonal dominance method",
  plot_ylab = "Average R"
)

## Plot a comparison of sparsest vs densest scenario, with standard deviation
plot_map_reduce_cmp(
  p = p, d = d[1], N = N, map = ext_abs_offdiag, reduce = mean, dir_name = dir_name,
  plot_title = paste0("d = ", d[1]), show_sd = TRUE, plot_ylab = "Average R",
  fname = paste0("cmp_avg_max_abs_offdiag_", d[1], ".pdf")
)

plot_map_reduce_cmp(
  p = p, d = d[length(d)], N = N, map = ext_abs_offdiag, reduce = mean, dir_name = dir_name,
  plot_title = paste0("d = ", d[length(d)]), show_sd = TRUE, plot_ylab = "Average R",
  fname = paste0("cmp_avg_max_abs_offdiag_", d[length(d)], ".pdf")
)

## Plot condition numbers of port matrices
p <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
plot_map_reduce(
  p = p, d = d, N = N, map = kappa, reduce = median, dir_name = dir_name,
  method = "port", fname = "port_median_kappa.pdf",
  plot_title = "Different structure densities",
  plot_ylab = "Median of K", exact = TRUE
)

d <- c(0.0025, 0.005, 0.025, 0.05)
plot_map_reduce(
  p = p, d = d, N = N, map = kappa, reduce = median, dir_name = dir_name,
  method = "port", fname = "port_median_kappa_trimmed.pdf",
  plot_title = "Sparse graph structures",
  plot_ylab = "Median of K", exact = TRUE
)

## Plot time comparison results
p <- seq(from = 10, to = 200, by = 10)
d <- c(0.0025, 0.005, 0.025, 0.05, 0.25, 0.5)
plot_time(
  p = p, d = d, method = "port", fname = "time_port.pdf",
  dir_name = "res_t", plot_title = "Partial orthogonalization method"
)
plot_time(
  p = p, d = d, method = "diagdom", fname = "time_diagdom.pdf",
  dir_name = "res_t", plot_title = "Diagonal dominance method"
)
