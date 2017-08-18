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
julia> using ClassImbalance

julia> y = vcat(zeros(20), ones(180))

julia> X = hcat(rand(200, 10), y)

julia> X2, y2 = smote(X, y, k = 5, under = 0.3, over = 0.4)
```
