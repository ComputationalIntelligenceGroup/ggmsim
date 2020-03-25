r <- 10
p <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 200, 250, 300, 400, 500, 750, 1000)
d <- c(0.0025, 0.005, 0.025, 0.05, 0.25, 0.5)
N <- 10

execute_experiment <- function(r, ename, emethod, ...) {
	for (repetition in 1:r) {
		dir.create(ename, showWarnings = FALSE)

		emethod(repetition = repetition, ...)
	}
}

execute_experiment(p = p, d = d, r = r, ename = "diagdom",
								emethod = gmat::diagdom, N = N)
execute_experiment(p = p, d = d, r = r, ename = "port", 
								emethod = gmat::port, N = N)

r <- 1
p <- seq(from = 10, to = 200, by = 10)
d <- c(0.0025, 0.005, 0.025, 0.05, 0.25, 0.5)
N <- 5000

get_time <- function(p, d, method, ...) {
	t_begin <- Sys.time()
	method(p, d, ...)
	t_end <- Sys.time()
	
	return(as.double(difftime(t_end, t_begin, unit = "secs"), unit = "secs"))
}

execute_experiment(p = p, d = d, r = r, ename = "time_diagdom",
								emethod = get_time, method = gmat::diagdom, N = N)
execute_experiment(p = p, d = d, r = r, ename = "time_port", 
								emethod = get_time, method = gmat::port, N = N)
