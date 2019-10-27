# ClassImbalance.jl

<p>
<a
href="https://doi.org/10.5281/zenodo.3233061">
<img
src="https://zenodo.org/badge/DOI/10.5281/zenodo.3233061.svg"
alt="DOI">
</a>
</p>

<p>
<a
href="https://app.bors.tech/repositories/12287">
<img
src="https://bors.tech/images/badge_small.svg"
alt="Bors enabled">
</a>
<a
href="https://travis-ci.org/bcbi/ClassImbalance.jl/branches">
<img
src="https://travis-ci.org/bcbi/ClassImbalance.jl.svg?branch=master"/>
</a>
<a
href="https://codecov.io/gh/bcbi/ClassImbalance.jl/branch/master">
<img
src="https://codecov.io/gh/bcbi/ClassImbalance.jl/branch/master/graph/badge.svg"/>
</a>
</p>

## Description

This is a package that implements some sampling-based methods of correcting for class imbalance in two-category classification problems. Portions of the SMOTE and ROSE algorithm are adaptations of the excellent R packages DMwR and ROSE.

## Installation

To install ClassImbalance, open Julia and run the following two lines:
```julia
import Pkg
Pkg.add("ClassImbalance")
```

## SMOTE Example
```julia
import ClassImbalance;
y = vcat(ones(20), zeros(180)); # 0 = majority, 1 = minority
X = hcat(rand(200, 10), y);
X2, y2 = smote(X, y, k = 5, pct_under = 100, pct_over = 200)
```
