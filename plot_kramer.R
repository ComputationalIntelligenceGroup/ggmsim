library("reshape2")
library("RColorBrewer")
library("ggplot2")

# Experiment scenarios
density <- c("0.25", "0.05")
title <- c(
  "diagdom" = "Diagonal dominance",
  "port" = "Partial orthogonalization",
  "port_chol" = "Uniform + partial orthogonalization"
)
method <- names(title)
ylab <- c(
  "ppv" = "True discovery rate",
  "tpr" = "True positive rate",
  "MSE" = "Mean squared error",
  "selected" = "Significant edges"
)
stat <- names(ylab)
algo <- c("adalasso", "lasso", "pls", "shrink", "ridge")
N <- seq(25, 200, 25)
estimate <- array(
  dim = c(length(algo), length(N)),
  dimnames = list(algo = algo, N = N)
)
dir_plot <- "plot_kramer"

dir.create(path = dir_plot, showWarnings = FALSE)

for (d in density) {
  for (m in method) {
    for (s in stat) {
      dir_exp <- paste0("res_kramer_", m, "_", d)
      # Only plot if the experiment has been run
      if (file.exists(dir_exp)) {
        for (i in 1:length(algo)) {
          estimate.raw <- readRDS(paste0(dir_exp, "/", s, ".", algo[i], ".rds"))
          estimate[algo[i], ] <- apply(X = estimate.raw, MARGIN = 2, mean)
        }

        palette <- colorRampPalette(colors = c("black", "red"))
        colpal <- brewer.pal(name = "Set1", n = length(N))

        df <- melt(estimate)
        df$algo <- as.factor(df$algo)

        ggplot(df, aes(x = N, y = value, group = algo, color = algo)) +
          geom_line() +
          geom_point() +
          theme(
            text = element_text(size = 20), legend.position = "bottom",
            legend.title = element_blank()
          ) +
          scale_color_manual(values = colpal) +
          xlab("Sample size") +
          ylab(ylab[s]) +
          # ylim(0, 1) +
          ggtitle(title[m], subtitle = paste0("d = ", d)) +
          ggsave(filename = paste0(dir_plot, "/", s, "_", m, "_", d, ".pdf"))
      }
    }
  }
}
