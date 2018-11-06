library("doParallel")
library("foreach")
library("parallel")
library("gmat")

r <- 10
p <- c(10,20, 30, 40,50, 60, 70, 80, 90,100,125,150,200, 250,300,400,500,750,1000)
d <- c(0.0025, 0.005, 0.025, 0.05, 0.25, 0.5)
N <- 10


exp_name <- outer(p, d, paste, sep = "_")
exp_fname <- matrix(paste0(exp_name, ".rds"), ncol = length(d))

wd <- getwd()
n_cores <- detectCores() - 2

for (rep in 1:r) {
	dir_name <- paste0("res_r", rep)
	dir.create(paste0(wd, "/",dir_name), showWarnings = FALSE)
	
	cl <- makeCluster(n_cores, outfile = "") 
	registerDoParallel(cl)
	invisible(clusterEvalQ(cl = cl, {
							   rm(list = ls())
							   library("gmat")
							   }))
	
	foreach (i = 1:length(p)) %:% 
		foreach (j = 1:length(d)) %dopar% {
			
			ug <- .rgraph(p = p[i], d = d[j])
	
			sample <- diagdom(N = N, p = p[i], d = d[j], ug = ug)
			saveRDS(sample, file = paste0(dir_name,"/domdiag_", exp_fname[i, j]))
	
			sample <- port(N = N, p = p[i], d = d[j], ug = ug, zapzeros = TRUE)
			saveRDS(sample, file = paste0(dir_name,"/sqrt_", exp_fname[i, j]))
		}
	
	stopCluster(cl)
}

