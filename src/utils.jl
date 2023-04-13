# Some of the code in this file is taken from PredictMD:
# https://github.com/bcbi/PredictMD.jl
# https://predictmd.net

import DataFrames

const RealOrMissing = Union{DataFrames.Missing, T} where T<:Real

function factor_columns(dat)
    p = size(dat, 2)
    is_factor = falses(p)
    for j = 1:p
        if !(eltype(dat[:, j]) <: RealOrMissing)
            is_factor[j] = true
        end
    end
    indcs = findall(is_factor)

    indcs
end

# @code_warntype factor_columns(d)

function factor_to_float(v::T) where T <: AbstractArray
    unique_cats = unique(v)         # unique categories
    sort!(unique_cats)
    cat_dictionary = Dict{String, Float64}()
    val = 1.0
    for k in unique_cats
        cat_dictionary[k] = val
        val += 1.0
    end
    n = length(v)
    res = zeros(n)
    for i = 1:n
        res[i] = cat_dictionary[v[i]]
    end
    res
end

function float_to_factor(v::T, levels::S) where T <: AbstractArray where S <: AbstractVector
    sort!(levels)
    str_vect = map(x -> levels[convert(Int, x)], v)
    result = Array(str_vect)
    return result
end

# This function behaves a bit like R's scale()
# function when it's called with MARGIN = 2.
function rscale(X, center, scale)
    n, p = size(X)
    res = zeros(n, p)
    for i = 1:n
        for j = 1:p
            res[i, j] = (X[i, j] - center[j])/scale[j]
        end
    end
    res
end

function column_ranges(X::T) where T <: AbstractMatrix
    p = size(X, 2)
    ranges = zeros(p)

    for j = 1:p
	ranges[j] = maximum(X[:, j]) - minimum(X[:, j])
    end
    ranges
end

# The `calculate_smote_pct_under` function is taken from PredictMD:
# https://github.com/bcbi/PredictMD.jl
# https://predictmd.net

function calculate_smote_pct_under(
        ;
        pct_over::Real = 0,
        minority_to_majority_ratio::Real = 0,
        )
    if pct_over < 0
        error("pct_over must be >=0")
    end
    if minority_to_majority_ratio <= 0
        error("minority_to_majority_ratio must be >0")
    end
    result = 100*minority_to_majority_ratio*(100+pct_over)/pct_over
    return result
end

function undersampling_strategy!(
        sampling_strategy::String,
        classes::T,
        classcount::Dict{A, S},
        ) where T <: AbstractVector where S <: Integer where A <: Any
    mincount = minimum(values(classcount))
    maxcount = maximum(values(classcount))

    if sampling_strategy == "majority"
        sampling_strategy = Dict(c => mincount for c in classes if classcount[c] == maxcount)
    elseif sampling_strategy == "auto" || sampling_strategy == "not minority"
        sampling_strategy = Dict(c => mincount for c in classes if classcount[c] != mincount)
    elseif sampling_strategy == "not majority"
        sampling_strategy = Dict(c => mincount for c in classes if classcount[c] != maxcount)
    elseif sampling_strategy == "all"
        sampling_strategy = Dict(c => mincount for c in classes)
    end
end
