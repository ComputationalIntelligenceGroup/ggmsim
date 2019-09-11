library("ggplot2")

N <- 10
p <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 200, 250, 300, 400, 500, 750, 1000)
d <- c(0.0025, 0.005, 0.025, 0.05, 0.25, 0.5)
r <- 10
dir_name <- paste0("../res_r", 1:r)

## Plot eigenvalue frequencies for both methods
p <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 200, 250, 300, 400, 500, 750, 1000)
d <- c(0.0025, 0.005, 0.025, 0.05, 0.25, 0.5)


plot_eigendensity <- function(p, d, N, method, fname, dir_name = "res",
                              plot_title = "", ...) {
  d_len <- length(d)
  r <- length(dir_name)
  exp_fname <- paste0(p, "_", d, ".rds")

  eigen_vals <- array(dim = c(d_len, p * r * N), dimnames = list(d = d))
  sample <- array(dim = c(p, p, r * N))
  for (i in 1:d_len) {
    for (j in 1:r) {
      sample[, , ((j - 1) * N + 1):(j * N)] <-
        readRDS(file = paste0(dir_name[j], "/", method, "_", exp_fname[i]))
    }
    eigen_vals[i, ] <- apply(sample, MARGIN = 3, function(m) {
      return(eigen(m)$values)
    })
  }
  wd <- getwd()
  dir.create(paste0(wd, "/plot_", r), showWarnings = FALSE)

  palette <- colorRampPalette(colors = c("black", "red"))
  colors <- palette(d_len)

  df <- reshape2::melt(eigen_vals)
  df$d <- as.factor(df$d)

  pl <- ggplot(df, aes(x = value, group = d, colour = d)) +
    geom_density() +
    xlab("Eigenvalue") +
	ylab("") +
    ggtitle(plot_title) +
    scale_color_manual(values = colors)

  ggsave(filename = fname, plot = pl, device = "pdf", path = paste0("plot_", r, "/"))
}


for (i in 1:length(p)) {
  plot_eigendensity(
    p = p[i], d = d, N = N, dir_name = dir_name, method = "port",
    plot_title = paste0("Eigenvalue densities for p = ", p[i]),
    fname = paste0("eigden_port_", p[i], ".pdf")
  )
  plot_eigendensity(
    p = p[i], d = d, N = N, dir_name = dir_name, method = "diagdom",
    plot_title = paste0("Eigenvalue densities for p = ", p[i]),
    fname = paste0("eigden_diagdom_", p[i], ".pdf")
  )
}
