# ClassImbalance.jl

<table>
    <tbody>
        <tr>
            <td>Repository status</td>
            <td><a href="https://www.repostatus.org/#active"><img src="https://www.repostatus.org/badges/latest/active.svg" alt="Project Status: Active – The project has reached a stable, usable state and is being actively developed." /></a></td>
        </tr>
        <tr>
            <td>Travis CI</td>
            <td><a href="https://travis-ci.org/bcbi/ClassImbalance.jl/branches">
            <img
            src="https://travis-ci.org/bcbi/ClassImbalance.jl.svg?branch=master"
            /></a></td>
        </tr>
        <tr>
            <td>CodeCov</td>
            <td><a
            href="https://codecov.io/gh/bcbi/ClassImbalance.jl/branch/master">
            <img
            src="https://codecov.io/gh/bcbi/ClassImbalance.jl/branch/master/graph/badge.svg"
            /></a></td>
        </tr>
        <tr>
            <td>Zenodo DOI</td>
            <td><a
            href="https://doi.org/10.5281/zenodo.3233061">
            <img src="https://zenodo.org/badge/DOI/10.5281/zenodo.3233061.svg"
            alt="DOI"></a></td>
        </tr>
    </tbody>
</table>

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
y = vcat(zeros(20), ones(180));
X = hcat(rand(200, 10), y);
X2, y2 = smote(X, y, k = 5, pct_under = 100, pct_over = 200)
```
