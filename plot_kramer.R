library("reshape2")
library("ggplot2")

# Experiment scenarios
density <- c("0.25", "0.05")
method <- c("diagdom", "port_chol")
stat <- c("ppv", "tpr")
algo <- c("adalasso", "lasso", "pls", "shrink", "ridge")
N <- seq(25, 200, 25)
estimate <- array(
  dim = c(length(algo), length(N), length(method), length(stat)),
  dimnames = list(algo = algo, N = N, method = method, stat = stat)
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
          estimate[algo[i], , m, s] <- apply(X = estimate.raw, MARGIN = 2, mean)
        }
	  }
	}
  }
  df <- melt(estimate)
  df$algo <- as.factor(df$algo)
  df$method <- as.factor(df$method)
  df$stat <- as.factor(df$stat)

  ggplot(df, aes(x = N, y = value, group = algo, color = algo)) +
  		  facet_grid(rows = vars(stat), cols = vars(method), scales = "free",
		  	labeller = labeller(stat = toupper)) +
          geom_line() +
          theme_bw() +
		  theme(legend.position = "bottom", legend.title = element_blank()) +
          xlab("Sample size") +
		  ylab("") +
          ggtitle(paste0("d = ", d)) +
          ggsave(
            filename = paste0("../mmsample/main/img/stats_", sub("\\.", "", d), ".pdf"),
			width = 7, height = 4
          )
  }
