library("reshape2")
library("RColorBrewer")
library("ggplot2")

plot_kramer <- function(algorithm, dir_name, fname, plot_title, subtitle,
                        stat = "ppv") {

	methods <- c("adalasso", "lasso", "pls", "shrink", "ridge")
	ylab <- c("ppv" = "True discovery rate", "tpr" = "True positive rate")
	N <- seq(25, 200, 25)
	power <- array(dim = c(length(methods), length(N)),
							 dimnames = list(method = methods, N = N))

	for (method in methods) {
		power.raw <- readRDS(paste0(dir_name, "/", stat, ".", method, ".rds"))
		power[method, ] <- apply(X = power.raw, MARGIN = 2, mean)
	}

	palette <- colorRampPalette(colors = c("black", "red"))
	colpal <- brewer.pal(name = "Set1", n = length(N))

	df <- melt(power)
	df$method <- as.factor(df$method)

	pl <- ggplot(df, aes(x = N, y = value, group = method, color = method)) +
		geom_line() +
		geom_point() +
		theme(text = element_text(size = 20), legend.position = "bottom",
		      legend.title = element_blank()) +
		scale_color_manual(values = colpal) +
		xlab("Sample size") +
		ylab(ylab[stat]) +
		ylim(0, 1) +
		ggtitle(plot_title, subtitle = subtitle)

	dir.create(path = "plot_kramer/", showWarnings = FALSE)
	ggsave(filename = paste0("plot_kramer/", stat, "_", algorithm, ".pdf"))
}

# Experiment scenarios
densities <- c("0.25", "0.05")
stats <- c("ppv", "tpr")
methods <- c("diagdom", "port", "port_chol")
titles <- c("diagdom" = "Diagonal dominance",
			"port" = "Partial orthogonalization",
			"port_chol" = "Uniform + partial orthogonalization")

for (d in densities) {
  for (method in methods) {
    for (s in stats) {
	    dir_name <- paste0("res_kramer_", method, "_", d)
		# Only plot if the experiment has been run
		if (file.exists(dir_name)) {
			plot_kramer(algorithm = paste0(method, "_", d),
				dir_name = dir_name,
				plot_title = titles[method],
				subtitle = paste0("d = ", d),
				stat = s)
		}
    }
  }
}

