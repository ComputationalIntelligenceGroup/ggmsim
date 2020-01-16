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

## Main contents
- `experiment_kramer.R` and `plot_kramer.R`: execute the experiment of 
```
 N. Krämer, J. Schäfer, and A.-L. Boulesteix. Regularized estimation of
 large-scale gene association networks using graphical Gaussian models.
 BMC Bioinformatics, 10(1):384, 2009,
```
whose results are included for comparison in Córdoba et al. (2018, 2019), and generate the 
corresponding figures.

- `experiment_pgm.R` and `plot_pgm.R`: execute the experiments and generate the
 figures in Córdoba et al. (2018), except for the Kramer et al. (2009) experiment.
- `plot_ext.R`: generate the figures in Córdoba et al. (2019).

The CRAN packages `gmat` and `ggplot2` are required for all the experiments
and plots, respectively. The generateds plots are stored in a directory 
`plot_[experiment-name]`, where `experiment-name` may be `pgm`, `ext` or `kramer`,
and which is newly created if it does not already exist.

## Remarks on generating the figures in Córdoba et al. (2018)
The Github R package `ggmexp` is required for these experiments and may be installed 
using the CRAN package `devtools` 
```R
devtools::install_github("irenecrsn/ggmexp")
```
Then source first file `experiment_pgm.R` and then `plot_pgm.R`. This 
experiment is computationally intensive. 

Note that
because `gmat::port()` and `gmat::diagdom()` have been modified since the
publication of Córdoba et al. (2018), some of its original graphics have been
affected. In particular:

- The results for the average off-diagonal/diagonal ratio statistic `R` has
  changed: matrices obtained with the partial orthogonalization method are more
  well conditioned, but their behaviour regarding `R` is more similar to those
  with dominant diagonal, although somewhat mitigated.
- Now the condition numbers and execution time for `gmat::port()` are lower.
- The results for the Kramer experiment with diagonally dominant matrices are
  slightly different since now the independent and identically distributed
  original random entries are generated with a Gaussian instead of a uniform
  distribution.

## Remarks on reproducing the Kramer et al. (2009) experiment
Source the file `experiment_kramer.R` and then `plot_kramer.R`. 
This experiment is computationally intensive, and requires additional R packages
to be executed: `doParallel`, `foreach`, `parcor`, `corpcor`, `MASS` and `reshape2`.

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
