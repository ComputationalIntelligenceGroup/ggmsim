devtools::install_github("irenecrsn/gmat")

p <- seq(from = 10, to = 200, by = 10)
d <- c(0.0025, 0.005, 0.025, 0.05, 0.25, 0.5)
N <- 5000

exp_name <- outer(p, d, paste, sep = "_")
exp_fname <- matrix(paste0(exp_name, ".rds"), ncol = length(d))

wd <- getwd()

dir_name <- paste0("res_t")
dir.create(paste0(wd, "/", dir_name), showWarnings = FALSE)

for (i in 1:length(p)) {
  for (j in 1:length(d)) {
    ug <- gmat::rgraph(p = p[i], d = d[j])

    t_begin <- Sys.time()
    gmat::diagdom(N = N, p = p[i], d = d[j], ug = ug)
    t_end <- Sys.time()
    saveRDS(difftime(t_end, t_begin, unit = "secs"),
      file =
        paste0(dir_name, "/t_diagdom_", exp_fname[i, j])
    )

    t_begin <- Sys.time()
    gmat::port(N = N, p = p[i], d = d[j], ug = ug, zapzeros = TRUE)
    t_end <- Sys.time()
    saveRDS(difftime(t_end, t_begin, unit = "secs"),
      file =
        paste0(dir_name, "/t_port_", exp_fname[i, j])
    )
  }
}
