import DataFrames

const RealOrMissing = Union{Missing, T} where T<:Real

function factor_columns(dat)
    p = size(dat, 2)
    is_factor = falses(p)
    for j = 1:p
        if !(eltype(dat[:, j]) <: RealOrMissing)
            is_factor[j] = true
        end
    end
    indcs = find(is_factor)

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
    str_vect = map(x -> levels[round(Int, x)], v)
    res = DataArray(str_vect)
    res
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
