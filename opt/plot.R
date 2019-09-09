source("../plot_utils.R")

N <- 10
p <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 200, 250, 300, 400, 500, 750, 1000)
d <- c(0.0025, 0.005, 0.025, 0.05, 0.25, 0.5)
r <- 10
dir_name <- paste0("../res_r", 1:r)

## Plot eigenvalue frequencies for both methods
p <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 200, 250, 300, 400, 500, 750, 1000)
d <- c(0.0025, 0.005, 0.025, 0.05, 0.25, 0.5)

for (i in 1:length(p)) {
  plot_eigen_freqpol(
    p = p[i], d = d, N = N, dir_name = dir_name, method = "port", bin_fun = nclass.Sturges,
    plot_title = paste0("Eigenvalue frequencies for p = ", p[i]),
    fname = paste0("eigfreq_port_", p[i], ".pdf")
  )
  plot_eigen_freqpol(
    p = p[i], d = d, N = N, dir_name = dir_name, method = "diagdom", bin_fun = nclass.Sturges,
    plot_title = paste0("Eigenvalue frequencies for p = ", p[i]),
    fname = paste0("eigfreq_diagdom_", p[i], ".pdf")
  )
}
