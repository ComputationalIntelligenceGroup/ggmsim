# Simulation of covariance and concentration graph matrices

This repository contains the files for replicating the experiments described in
the paper

> Córdoba I., Varando G., Bielza C., Larrañaga P. A partial orthogonalization
> method for simulating covariance and concentration graph matrices. Proceedings
> of Machine Learning Research (PGM 2018), vol 72, pp. 61-72, 2018.

They are mainly concerned with the method of partial orthogonalization (Córdoba
et al. 2018), implemented in `gmat::port()`, as well as the traditional diagonal
dominance method, implemented in many software packages, and also in
`gmat::diagdom()`.

The experiments in the following paper

> N. Krämer, J. Schäfer, and A.-L. Boulesteix. Regularized estimation of
> large-scale gene association networks using graphical Gaussian models.
> BMC Bioinformatics, 10(1):384, 2009

have also been used in Córdoba et al. (2018) to validate both approaches, and
the code for its replication is also available in this repository.

## Contents

- `sim_experiment.R`: script that executes both methods for different matrix
  dimensions and sample sizes, saving the generated samples.
- `time_experiment.R`: script that executes both methods for different matrix
  dimensions and sample sizes, measuring and saving their execution time.
- `kramer_experiment.R`: script that replicates the experiments in Krämer and
  Schäfer (2009) whose results are also included in Córdoba et al. (2018).
- `performance.pcor.R`: same as [parcor::performance.pcor](https://github.com/cran/parcor/blob/master/R/performance.pcor.R), but calling `GeneNet::network.test.edges()` instead of `GeneNet::ggm.test.edges()`, which does not exist in the newest version of `GeneNet`. This file can be safely ignored as it will be removed when/if `parcor` is fixed.
- `plot_utils.R`: utility functions for plotting.
- `plot.R`: script that generates the plots describing the results of both the
  simulation and time experiments.
- `plot_kramer.R`: script that generates the plots corresponding to the Kramer
  experiment.
- `opt`: folder containing scripts for running additional experiments. __Work in
  progress__

## Instructions for simulation and time experiments

- R packages required: `doParallel`, `foreach`, `gmat`, `ggplot2`, `Matrix` and
  `reshape2`.
- Run the following commands from a terminal (or source the files on an open R session)
	```bash
	Rscript sim_experiment.R
	Rscript time_experiment.R
	Rscript plot.R
	```
Both the simulation and time experiment are computationally intensive.

## Instructions for reproducing the Kramer experiment
- R packages required: `GeneNet`, `parcor`, `gmat`, `MASS` and `reshape2`
- The instructions bellow are for the most dense scenario in Kramer et al.
  (2009). For different sparsity scenarios, simply change `0.25` below to the
  desired sparsity level. As an example, `0.05` is the sparsest scenario in Kramer
  et al. (2009), and it is also analysed in Córdoba et al. (2019).

### Diagonally dominant matrices
- Launch the file `kramer_experiment.R`.
	```bash
  	Rscript kramer_experiment.R
	```
This will output the results for matrices simulated using the diagonal dominance
method, using function `GeneNet::ggm.simulate.pcor`.

### Partial orthogonalization method
- Change the [matrix simulation
  line](https://github.com/irenecrsn/spdug/blob/aa78d6e8dde987d1b49a69502ee99e56211e28e6/kramer_experiment.R#L79)
  in `kramer_experiment.R` to the following code
  	```R
  	true.pcor <- gmat::port(p = p, d = d)[, , 1]
	# necessary because of the high condition numbers
 	while(eigen(true.pcor)$values[p] < 0) {
		true.pcor <- gmat::port(p = p, d = d)[, , 1]
 	}
	```
- Change `res_kramer_0.25/` in [these
  lines](https://github.com/irenecrsn/spdug/blob/aa78d6e8dde987d1b49a69502ee99e56211e28e6/kramer_experiment.R#L160-L162)
  of `kramer_experiment.R` to `res_kramer_port_0.25`.
- Relaunch the `kramer_experiment.R` script.
### Uniform sampling combined with partial orthogonalization
- Start again from the original `kramer_experiment.R` file in the repository.
- Change the [matrix simulation
  line](https://github.com/irenecrsn/spdug/blob/aa78d6e8dde987d1b49a69502ee99e56211e28e6/kramer_experiment.R#L79)
  in `kramer_experiment.R` to the following code
	```R
	true.pcor <- gmat::port_chol(p = p, d = d)[, , 1]
	```
- Change `res_kramer_0.25/` in [these
  lines](https://github.com/irenecrsn/spdug/blob/aa78d6e8dde987d1b49a69502ee99e56211e28e6/kramer_experiment.R#L160-L162)
  of `kramer_experiment.R` to `res_kramer_port_chol_0.25`.
- Relaunch the `kramer_experiment.R` script.
### Plotting the results
- Launch `plot_kramer.R`.
	```bash
	Rscript plot_kramer.R
	```
