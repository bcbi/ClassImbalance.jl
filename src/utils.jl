function factor_columns(dat)
    p = size(dat, 2)
    is_factor = falses(p)
    for j = 1:p
        typ = eltype(dat[:, j])
        if !(typ <: Real)
            is_factor[j] = true
        end
    end
    indcs = find(is_factor)
    indcs
end

# @code_warntype factor_columns(d)


function factor_to_float(v::NullableArray)
    unique_cats = levels(v)         # unique categories
    sort!(unique_cats)
    cat_dictionary = Dict{Nullable{String}, Float64}()
    val = 1.0
    for k in unique_cats
        cat_dictionary[Nullable(k)] = val
        val += 1.0
    end
    n = length(v)
    res = zeros(n)
    for i = 1:n
        res[i] = cat_dictionary[v[i]]
    end
    res
end


function float_to_factor(v::NullableArray, levels)
    sort!(levels)
    str_vect = map(x -> levels[round(Int, x)], v)
    res = CategoricalArray(str_vect)
    res
end



function factor_to_float(v::DataArray)
    unique_cats = levels(v)         # unique categories
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


function float_to_factor(v::DataArray, levels)
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


function column_ranges(X::Array{T, 2}) where {T <: Real}
    p = size(X, 2)
    ranges = zeros(p)

    for j = 1:p
        ranges[j] = maximum(X[:, j]) - minimum(X[:, j])
    end
    ranges
end
