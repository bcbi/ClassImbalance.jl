# ClassImbalance

[![Build Status](https://travis-ci.org/paulstey/ClassImbalance.jl.svg?branch=master)](https://travis-ci.org/paulstey/ClassImbalance.jl)

[![Coverage Status](https://coveralls.io/repos/paulstey/ClassImbalance.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/paulstey/ClassImbalance.jl?branch=master)

[![codecov.io](http://codecov.io/github/paulstey/ClassImbalance.jl/coverage.svg?branch=master)](http://codecov.io/github/paulstey/ClassImbalance.jl?branch=master)


## Installation
```julia
julia> Pkg.clone("https://github.com/bcbi/ClassImbalance.jl.git")
```

## SMOTE Example
```julia
julia> n_majority = 180

julia> n_minority = 20

julia> n = n_minority + n_majority

julia> X_tmp = rand(n, 10)

julia> y = vcat(zeros(n_majority), ones(n_minority))

julia> X = hcat(X_tmp, y)

julia> X2, y2 = smote(X, y, k = 5, over = 0.3, under = 0.2)
```
