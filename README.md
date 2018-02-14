# ClassImbalance

[![Build Status](https://travis-ci.org/bcbi/ClassImbalance.jl.svg?branch=master)](https://travis-ci.org/bcbi/ClassImbalance.jl)

[![Coverage Status](https://coveralls.io/repos/bcbi/ClassImbalance.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/bcbi/ClassImbalance.jl?branch=master)

[![codecov.io](http://codecov.io/github/bcbi/ClassImbalance.jl/coverage.svg?branch=master)](http://codecov.io/github/bcbi/ClassImbalance.jl?branch=master)

## Description
This is a package that implements some sampling-based methods of correcting for class imbalance in two-category classification problems. Portions of the SMOTE and ROSE algorithm are adaptations of the excellent R packages DMwR and ROSE.

## Installation
```julia
julia> Pkg.clone("https://github.com/bcbi/ClassImbalance.jl.git")
```

## SMOTE Example
```julia
julia> using ClassImbalance

julia> y = vcat(zeros(20), ones(180))

julia> X = hcat(rand(200, 10), y)

julia> X2, y2 = smote(X, y, k = 5, pct_under = 100, pct_over = 200)
```
