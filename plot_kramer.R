library("reshape2")
library("RColorBrewer")
library("ggplot2")

plot_kramer <- function(d, method = "port", dir_name, fname, plot_title, stat = "ppv") {

	methods <- c("adalasso", "lasso", "pls", "shrink", "ridge")
	ylab <- c("ppv" = "True discovery rate", "tpr" = "True positive rate")
	N <- seq(25, 200, 25)
	power <- array(dim = c(length(methods), length(N)),
							 dimnames = list(method = methods, N = N))

	for (method in methods) {
		power.raw <- readRDS(paste0(dir_name, "/", stat, ".", method))
		power[method, ] <- apply(X = power.raw, MARGIN = 2, mean)
	}

	palette <- colorRampPalette(colors = c("black", "red"))
	colpal <- brewer.pal(name = "Set1", n = length(N))

	df <- melt(power)
	df$method <- as.factor(df$method)

	pl <- ggplot(df, aes(x = N, y = value, group = method, color = method)) +
		geom_line() +
		geom_point() +
		theme(text = element_text(size = 20), legend.position = "bottom") +
		scale_color_manual(values = colpal) +
		xlab("Sample size") +
		ylab(ylab[stat]) +
		ylim(0, 1) +
		ggtitle(plot_title)

	dir.create(path = "plot_kramer/", showWarnings = FALSE)
	ggsave(filename = paste0("plot_kramer/", stat, "_", method, ".pdf"))
}

plot_kramer(d = 0.25, method = "port", dir_name = "res_kramer_port_0.25",
	plot_title = "Partial orthogonalization method", stat = "ppv")
plot_kramer(d = 0.25, method = "port", dir_name = "res_kramer_0.25",
	plot_title = "Diagonal dominance method", stat = "ppv")

plot_kramer(d = 0.25, method = "port", dir_name = "res_kramer_port_0.25",
	plot_title = "Partial orthogonalization method", stat = "tpr")
plot_kramer(d = 0.25, method = "port", dir_name = "res_kramer_0.25",
	plot_title = "Diagonal dominance method", stat = "tpr")

