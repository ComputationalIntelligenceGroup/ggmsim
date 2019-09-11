# Simulation of Gaussian graphical models

This repository contains the files for replicating the experiments described in
the papers:

- Córdoba I., Varando G., Bielza C., Larrañaga P. A partial orthogonalization
  method for simulating covariance and concentration graph matrices. _Proceedings
  of Machine Learning Research_ (PGM 2018), vol 72, pp. 61-72, 2018.
- Córdoba I., Varando G., Bielza C., Larrañaga P. Generating random Gaussian
  graphical models, _arXiv:1909.01062_, 2019.

The experiments are related with the analysis of four methods for sampling
partial correlation matrices, possibly constrained by an undirected graph:
- The traditional diagonal dominance method, implemented in many software
  packages, and also in `gmat::diagdom()`.
- Partial orthogonalization (Córdoba et al. 2018), implemented in `gmat::port()`
- Uniform sampling (Córdoba et al. 2019), implemented in `gmat::chol_mh()`.
- Uniform sampling combined with partial orthogonalization (Córdoba et al.
  2019), implemented in `gmat::port_chol()`.

The Gaussian graphical model learning experiment in the following paper

> N. Krämer, J. Schäfer, and A.-L. Boulesteix. Regularized estimation of
> large-scale gene association networks using graphical Gaussian models.
> BMC Bioinformatics, 10(1):384, 2009

has been used in Córdoba et al. (2018, 2019) to validate their proposal, and
the code for its replication is also available in this repository.

## Main contents

- `sim_experiment.R` and `time_experiment.R`: execute `gmat::port()` and
  `gmat::diagdom()` for different matrix dimensions and sample sizes, saving the
  generated samples and execution time, respectively.
- `plot.R`: generates the figures in Córdoba et al. (2018), except for the
  Kramer experiment.
- `plot_densities.R`: generates the density plots for the comparison
  between a random and a chordal graph in Córdoba et al. (2019).
- `plot_scatter.R`: generates the scatterplots for the chordal graph
  of 3 variables in Córdoba et al. (2019).
- `kramer_experiment.R`: replicates the experiments in Krämer and
  Schäfer (2009) whose results are included in Córdoba et al. (2018, 2019).
- `plot_kramer.R`: generates the plots corresponding to the Kramer
  experiment using the three methods.
- `opt`: folder containing scripts for running additional experiments. __Work in
  progress__

The following CRAN packages are required:
- For all the experiments: `gmat`.
- For all the plots: `ggplot2`, `RColorBrewer` and `reshape2`.

## Instructions for simulation and time experiments in Córdoba et al. (2018)

- R packages required: `doParallel`, `foreach`, `Matrix`.
- Run the following commands from a terminal (or source the files on an open R session)
	```bash
	Rscript sim_experiment.R
	Rscript time_experiment.R
	Rscript plot.R
	```
Both the simulation and time experiment are computationally intensive. Note that
because `gmat::port()` method has been modified to return partial correlation
matrices (see Córdoba et al., 2019), some graphics in Córdoba et al. (2018) have
been affected. In particular:
- The results for the average off-diagonal/diagonal ratio statistic `R` has
  changed: matrices obtained with the partial orthogonalization method are more
  well conditioned, but their behaviour regarding `R` is more similar to those
  with dominant diagonal, although somewhat mitigated.
- Now the condition numbers and execution time for `gmat::port()` are lower.

## Instructions for densities and scatterplots in Córdoba et al. (2019)
- Run the following commands from a terminal (or source the files on an open R session)
	```bash
	Rscript plot_densities.R
	Rscript plot_scatter.R
	```

## Instructions for reproducing the Kramer experiment
- R packages required: `doParallel`, `foreach`, `GeneNet`, `parcor` and `MASS`
- Run the following commands from a terminal (or source the files on an open R session)
	```bash
  	Rscript kramer_experiment.R
	Rscript plot_kramer.R
	```
This experiment is computationally intensive. The resulting graphics are stored
in `./plot_kramer/` (created from scratch if it does not already exist).

The performance statistics are calculated by the function in
`performance.pcor.R`, which is a modification of
[parcor::performance.pcor](https://github.com/cran/parcor/blob/master/R/performance.pcor.R):
- It solves a bug by calling `GeneNet::network.test.edges()` instead of
`GeneNet::ggm.test.edges()`, which does not exist in the newest version of
`GeneNet`.
- Variables `ppv` and `tpr` are initialized to `1` instead of `-Inf`, which we
  believe is more correct semantically and mathematically. For some learning
  methods such as `shrink` and `pls` this drastically affects their resulting
  plot. This is corrected in Córdoba et al. (2019), but not in Córdoba et al.
  (2018), where the plots reflect the original initialization of Kramer et al.
  (2009).
