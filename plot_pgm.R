N <- 10
p <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 200, 250, 300, 400, 500, 750, 1000)
d <- c(0.0025, 0.005, 0.025, 0.05, 0.25, 0.5)
r <- 10

dname <- "plot_pgm"
dir.create(path = dname, showWarnings = FALSE)
max_abs_offdiag <- function(mat) {
	return(max(0, abs((mat / diag(mat))[upper.tri(mat) & mat != 0])))
}


plot_experiment <- function(p, d, r, N, map = function(x) {
	return(x)
}, reduce, show_sd = FALSE, ename, 
plot_title = "", plot_ylab = "", ...) {
	data <- matrix(
		nrow = length(p), ncol = length(d),
		dimnames = list(p = p, d = d)
	)
	data_sd <- matrix(
		nrow = length(p), ncol = length(d),
		dimnames = list(p = p, d = d)
	)
	
	
	for (i in 1:length(p)) {
		exp_res <- array(dim = c(p[i], p[i], N[i] * r))
		for (j in 1:length(d)) {
			for (rep in 1:r) {
				exp_res[, , ((rep - 1) * N[i] + 1):(rep * N[i])] <-
					readRDS(file = paste0(ename, "_r", rep, "/", p[i], "_", d[j], ".rds"))
			}
			mapd_mat <- apply(X = exp_res, MARGIN = 3, FUN = map, ...)
			data[i, j] <- reduce(mapd_mat)
			data_sd[i, j] <- stats::sd(mapd_mat)
		}
	}
	
	wd <- getwd()
	dir.create(paste0(wd, "/plot_", r), showWarnings = FALSE)
	
	palette <- grDevices::colorRampPalette(colors = c("black", "red"))
	colors <- palette(length(d))
	
	df <- data %>% as.tbl_cube(met_name = "data") %>% as_tibble()
	df$d <- as.factor(df$d)
	df_sd <- data_sd %>% as.tbl_cube(met_name = "data_sd") %>% as_tibble()
	df$data_sd <- df_sd$data_sd
	
	pl <- ggplot(df, aes(x = p, y = data, group = d, color = d)) +
		geom_line() +
		geom_point() +
		theme(text = element_text(size = 20), legend.position = "bottom") +
		scale_color_manual(values = colors) +
		xlab("Number of nodes") + 
		ylab(plot_ylab) +
		ggtitle(plot_title)
	
	if (show_sd == TRUE) {
		pl <- pl +
			geom_ribbon(aes(ymin = data - data_sd, ymax = data + data_sd, fill = ename),
									alpha = .3) +
			scale_fill_manual(labels = ename, values = colors)  
	}
	
	return(pl)
}

plot_comparison <- function(p, d, r, N, map = function(x) {
	return(x)
},
reduce, ename, show_sd = FALSE, plot_title = "", plot_ylab = "", ...) {
	data <- matrix(
		nrow = length(p), ncol = length(ename),
		dimnames = list(p = p, ename = ename)
	)
	data_sd <- matrix(
		nrow = length(p), ncol = length(ename),
		dimnames = list(p = p, ename = ename)
	)
	
	for (i in 1:length(p)) {
		sample <- array(dim = c(p[i], p[i], N[i] * r))
		for (m in ename) {
			for (k in 1:r) {
				sample[, , ((k - 1) * N[i] + 1):(k * N[i])] <-
					readRDS(file = paste0(m, "_r", k, "/", p[i], "_", d, ".rds"))
			}
			mapd_mat <- apply(sample, MARGIN = 3, map, ...)
			data[i, m] <- reduce(mapd_mat)
			data_sd[i, m] <- stats::sd(mapd_mat)
		}
	}
	
	df <- data %>% as.tbl_cube(met_name = "data") %>% as_tibble()
	df$ename <- as.factor(df$ename)
	df_sd <- data_sd %>% as.tbl_cube(met_name = "data_sd") %>% as_tibble()
	df$data_sd <- df_sd$data_sd
	
	palette <- grDevices::colorRampPalette(colors = c("green4", "blue"))
	colors <- palette(length(ename))
	
	pl <- ggplot(df, aes(x = p, y = data, group = ename)) +
		geom_line(aes(color = ename)) +
		geom_point(aes(color = ename)) +
		scale_color_manual(labels = ename, values = colors) +
		theme(text = element_text(size = 20), legend.position = "bottom") +
		xlab("Number of nodes") +
		ylab(plot_ylab) +
		ggtitle(plot_title)
	
	if (show_sd == TRUE) {
		pl <- pl +
			geom_ribbon(aes(ymin = data - data_sd, ymax = data + data_sd, fill = ename),
									alpha = .3) +
			scale_fill_manual(labels = ename, values = colors)
	}
	
	
	return(pl)
}

## Plot all scenarios with both methods (average)
pl <- plot_experiment(p = p, d = d, r = r, N = N, map = max_abs_offdiag, 
															reduce = mean, ename = "port",
															plot_title = "Partial orthogonalization",
															plot_ylab = "Average R")
ggplot2::ggsave(filename = "port_avg_max_abs_offdiag.pdf", plot = pl, device = "pdf", 
			 path = dname)

pl <- plot_experiment(p = p, d = d, r = r, N = N, map = max_abs_offdiag, 
															reduce = mean, ename = "diagdom", 
															plot_title = "Diagonal dominance", 
															plot_ylab = "Average R")
ggplot2::ggsave(filename = "diagdom_avg_max_abs_offdiag.pdf", plot = pl, device = "pdf", 
			 path = dname)

## Plot a comparison of sparsest vs densest scenario, with standard deviation
pl <- plot_comparison(
  p = p, d = d[1], r = r, N = N, map = max_abs_offdiag, reduce = mean,
  ename = c("diagdom", "port"),
  plot_title = paste0("d = ", d[1]), show_sd = TRUE, plot_ylab = "Average R"
)
ggplot2::ggsave(filename = paste0("cmp_avg_max_abs_offdiag_", d[1], ".pdf"), plot = pl, 
			 device = "pdf", path = dname)

pl <- plot_comparison(
  p = p, d = d[length(d)], r = r, N = N, map = max_abs_offdiag, reduce = mean, 
  ename = c("diagdom", "port"),
  plot_title = paste0("d = ", d[length(d)]), show_sd = TRUE, plot_ylab = "Average R"
)
ggplot2::ggsave(filename = paste0("cmp_avg_max_abs_offdiag_", d[length(d)], ".pdf"), plot = pl, 
			 device = "pdf", path = dname)


## Plot condition numbers of port matrices
p <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
pl <- plot_experiment(p = p, d = d, N = N, r = 10, map = kappa, reduce = median, 
												ename = "port", plot_title = "Different structure densities",
												plot_ylab = "Median of K", exact = TRUE)
ggplot2::ggsave(filename = "port_median_kappa.pdf", plot = pl, device = "pdf", 
			 path = dname)

d <- c(0.0025, 0.005, 0.025, 0.05)
pl <- plot_experiment(p = p, d = d, N = N, r = 10, map = kappa, reduce = median, 
												ename = "port", plot_title = "Sparse graph structures",
												plot_ylab = "Median of K", exact = TRUE)
ggplot2::ggsave(filename = "port_median_kappa_trimmed.pdf", plot = pl, device = "pdf", 
			 path = dname)

## Plot time comparison results
r <- 1
p <- seq(from = 10, to = 200, by = 10)
d <- c(0.0025, 0.005, 0.025, 0.05, 0.25, 0.5)
N <- 5000

pl <- plot_experiment(p = p, d = d, r = r, N = N, 
															reduce = mean, ename = "time_port",
															plot_title = "Partial orthogonalization",
															plot_ylab = "Execution time in seconds")
ggplot2::ggsave(filename = "time_port.pdf", plot = pl, device = "pdf", 
			 path = dname)

pl <- plot_experiment(p = p, d = d, r = r, N = N, 
															reduce = mean, ename = "time_diagdom",
															plot_title = "Diagonal dominance",
															plot_ylab = "Execution time in seconds")
ggplot2::ggsave(filename = "time_diagdom.pdf", plot = pl, device = "pdf", 
			 path = dname)
