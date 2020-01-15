library("ggplot2")
library("RColorBrewer")

plot_map_reduce_cmp <- function(p, d, N, map = function(x) {
                                  return(x)
                                },
                                reduce, fname, show_sd = FALSE,
                                dir_name = "res", plot_title = "", plot_ylab = "", ...) {
  dir_len <- length(dir_name)
  methods <- c("diagdom", "port")
  exp_name <- outer(methods, p, paste, sep = "_")
  exp_fname <- matrix(paste0(exp_name, "_", d, ".rds"),
    ncol = 2,
    dimnames = list(p = p, method = methods), byrow = TRUE
  )

  res <- matrix(
    nrow = length(p), ncol = 2,
    dimnames = list(p = p, method = methods)
  )
  res_sd <- matrix(
    nrow = length(p), ncol = 2,
    dimnames = list(p = p, method = methods)
  )

  for (i in 1:length(p)) {
    sample <- array(dim = c(p[i], p[i], N * dir_len))
    for (m in methods) {
      for (k in 1:dir_len) {
        sample[, , ((k - 1) * N + 1):(k * N)] <-
          readRDS(file = paste0(dir_name[k], "/", exp_fname[i, m]))
      }
      mapd_mat <- apply(sample, MARGIN = 3, map, ...)
      res[i, m] <- reduce(mapd_mat)
      res_sd[i, m] <- sd(mapd_mat)
    }
  }

  wd <- getwd()
  dir.create(paste0(wd, "/plot_", dir_len), showWarnings = FALSE)

  df <- reshape2::melt(res)
  df$sd <- reshape2::melt(res_sd)$value

  pl <- ggplot(df, aes(x = p, y = value, group = method)) +
    xlab("Number of nodes") +
    ylab(plot_ylab) +
    ggtitle(plot_title)


  if (show_sd == TRUE) {
    pl <- pl +
      geom_ribbon(aes(ymin = value - sd, ymax = value + sd, fill = method),
        alpha = .3
      ) +
      scale_fill_manual(labels = c("DD", "PO"), values = c("green4", "blue"))
  }

  pl <- pl +
    geom_line(aes(color = method)) +
    geom_point(aes(color = method)) +
    scale_color_manual(labels = c("DD", "PO"), values = c("green4", "blue")) +
    theme(text = element_text(size = 20), legend.position = "bottom")

  ggsave(filename = fname, plot = pl, device = "pdf", path = paste0("plot_", dir_len, "/"))
}

plot_time <- function(p, d, method, fname, dir_name = "res", plot_title = "", ...) {
  d_len <- length(d)
  exp_name <- outer(p, d, paste, sep = "_")
  exp_fname <- matrix(paste0(exp_name, ".rds"), ncol = d_len)

  res <- matrix(
    nrow = length(p), ncol = d_len,
    dimnames = list(p = p, d = d)
  )

  for (i in 1:length(p)) {
    for (j in 1:length(d)) {
      time <- readRDS(file = paste0(dir_name, "/t_", method, "_", exp_fname[i, j]))
      res[i, j] <- as.double(time, unit = "secs")
    }
  }

  wd <- getwd()
  dir.create(paste0(wd, "/plot_", dir_name), showWarnings = FALSE)

  palette <- colorRampPalette(colors = c("black", "red"))
  colors <- palette(d_len)

  df <- reshape2::melt(res)
  df$d <- as.factor(df$d)

  pl <- ggplot(df, aes(x = p, y = value, group = d, color = d)) +
    geom_line() +
    geom_point() +
    theme(text = element_text(size = 20), legend.position = "bottom") +
    scale_color_manual(values = colors) +
    xlab("Number of nodes") +
    ylab("Execution time in seconds") +
    ggtitle(plot_title)

  ggsave(
    filename = fname, plot = pl, device = "pdf",
    path = paste0("plot_", dir_name, "/"),
    width = 7, height = 5
  )
}
