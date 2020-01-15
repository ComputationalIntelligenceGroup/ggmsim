r <- 10
p <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 200, 250, 300, 400, 500, 750, 1000)
d <- c(0.0025, 0.005, 0.025, 0.05, 0.25, 0.5)
N <- 10

ggmexp::execute(p = p, d = d, r = r, ename = "diagdom",
								emethod = gmat::diagdom, N = N)
ggmexp::execute(p = p, d = d, r = r, ename = "port", 
								emethod = gmat::port, N = N)

p <- seq(from = 10, to = 200, by = 10)
d <- c(0.0025, 0.005, 0.025, 0.05, 0.25, 0.5)
N <- 5000

get_time <- function(method, ...) {
	t_begin <- Sys.time()
	method(...)
	t_end <- Sys.time()
	
	return(difftime(t_end, t_begin, unit = "secs"))
}

ggmexp::execute(p = p, d = d, r = r, ename = "t_diagdom",
								emethod = get_time, method = diagdom, N = N)
ggmexp::execute(p = p, d = d, r = r, ename = "t_port", 
								emethod = get_time, method = port, N = N)
