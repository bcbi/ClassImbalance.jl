

# d = readtable("./data/people.csv", makefactors = true)

function factor_cols(dat::DataFrame)
    p = size(dat, 2)
    are_factors = falses(p)
    for j = 1:p
        if isa(dat[:, j], NullableCategoricalArray)
            are_factors[j] = true
        end
    end
    indcs = find(are_factors)
    indcs
end

# @code_warntype factor_cols(d)


function factor_to_float(v)
    unique_cats = levels(v)         # unique categories
    sort!(unique_cats)
    cat_dictionary = Dict{Nullable{String}, Float64}()
    val = 1.0
    for k in unique_cats
        cat_dictionary[Nullable(k)] = val
        val += 1.0
    end
    n = length(v)
    res = Array{Float64, 1}(n)
    for i = 1:n
        res[i] = cat_dictionary[v[i]]
    end
    res
end


function float_to_factor(v, levels)
    sort!(levels)
    str_vect = map(x -> levels[Int(round(x))], v)
    res = CategoricalArray(str_vect)
    res
end


# This function behaves a bit like R's scale()
# function when it's call with MARGIN = 2.
function rscale(X, center, scale)
    n, p = size(X)
    res = Array{Float64, 2}(n, p)
    for i = 1:n
        for j = 1:p
            res[i, j] = (X[i, j] - center[j])/scale[j]
        end
    end
    res
end


function column_ranges(X::Array{T, 2}) where {T <: Real}
    p = size(X, 2)
    ranges = Array{Float64,1}(p)

    for j = 1:p
        ranges[j] = maximum(X[:, j]) - minimum(X[:, j])
    end
    ranges
end


function smote_exs(dat::DataFrame, tgt::Symbol, pct = 200, k = 5)
    n, m = size(dat)
    T = Array{Float64, 2}(n, m-1)

    # HACK: We assume outcome var is last column
    factor_indcs = factor_cols(dat)[1:end-1]

    for j = 1:size(T, 2)
        if j ∈ factor_indcs
            T[:, j] = factor_to_float(dat[:, j])
        else
            T[:, j] = convert(Array{Float64, 1}, dat[:, j])
        end
    end

    # when pct < 100, only a percentage of cases will be SMOTEd
    if pct < 100
        n_needed = round(Int, (pct/100)*n)
        idx = sample(1:n, n_needed)
        T = T[idx, :]
        pct = 100
    end
    n, p = size(T)
    # display(T)
    ranges = column_ranges(T)

    n_exs = round(Int, floor(pct/100))   # num. of artificial ex for each member of T
    xnew = Array{Float64, 2}(n_exs*n, p)

    for i = 1:n

        # the k nearest neighbors of case T[i, ]
        xd = rscale(T, T[i, :], ranges)

        for col in factor_indcs
            xd[:, col] = map(x -> x == 0.0 ? 1.0 : 0.0, xd[:, col])
        end

        dd = xd.^2 * ones(p)
        k_nns = sortperm(dd)[2:(k+1)]

        for l = 1:n_exs
            neighbor = sample(1:k)
            ex = Array{Float64, 1}(p)

            # the attribute values of generated case
            difs = T[k_nns[neighbor], :] - T[i, :]
            xnew[(i - 1)*n_exs + l, :] = T[i, :] + rand()*difs

            # For each of factor variable, sample at random the original value
            # of Person i or the value that one of Person i's nearest neighbors has.
            for col in factor_indcs
                xnew[(i - 1)*n_exs + l, col] = sample(vcat(T[k_nns[neighbor], col], T[i, col]))
            end
        end
    end

    new_cases = DataFrame()
    for j = 1:p
        if j ∈ factor_indcs
            new_cases[:, j] = float_to_factor(xnew[:, j], levels(dat[:, j]))
        else
            new_cases[:, j] = xnew[:, j]
        end
    end
    yval = String(dat[1, tgt].value)
    new_cases[:, tgt] = CategoricalArray(repeat([yval], inner = n_exs*n))
    return new_cases
end



# This version of the function is to be used when we have no factor
# variables. And it assumes input is simply a numeric matrix, where
# the last column is the outcome (or target) variable.
# NOTE: `pct` is the percent of positive examples relative to total
# sample size to be returned.
function smote_exs(dat::Array{S, 2}, tgt::Int, pct = 200, k = 5) where {S <: Real}
    if pct < 1
        warn("Percent over-sampling cannot be less than 1\n
              Setting `pct` to 1.")
        pct = 1
    end

    n, m = size(dat)
    T = Array{Float64, 2}(n, m-1)

    for j = 1:size(T, 2)
        T[:, j] = convert(Array{Float64,1}, dat[:, j])
    end

    # When pct < 100, only a percentage of cases will be SMOTEd
    if pct < 100
        n_needed = round(Int, (pct/100)*n)
        idx = sample(1:n, n_needed)
        T = T[idx, :]
        pct = 100
    end

    n, p = size(T)
    # display(T)
    ranges = column_ranges(T)

    n_exs = round(Int, pct/100)   # num. of artificial ex for each member of T
    xnew = Array{Float64, 2}(n_exs*n, p)

    for i = 1:n

        # The k nearest neighbors of case T[i, ]
        xd = rscale(T, T[i, :], ranges)

        dd = xd.^2 * ones(p)
        last_idx = (length(dd) + 1 ≤ k) ? (k+1) : length(dd)        # HACK: Find out why `dd` is sometimes less than k+1
        k_nns = sortperm(dd)[2:last_idx]

        for l = 1:n_exs
            n_neighbors = (length(k_nns) == k) ? k : length(k_nns)
            neighbor = sample(1:n_neighbors)
            ex = Array{Float64, 1}(p)

            # The attribute values of generated case
            difs = T[k_nns[neighbor], :] - T[i, :]
            xnew[(i - 1)*n_exs + l, :] = T[i, :] + rand()*difs
        end
    end
    # Find what the minority class is in outcome
    yval = dat[1, tgt]
    new_cases = hcat(xnew, repeat([yval], inner = n_exs*n))
    return new_cases
end

# m = 150
# X = rand(m, 10)
# y = ones(m)
# X = hcat(X, y)
#
# smote_exs(X, 11)




function cases_needed(y::Array{T, 1}, prop = 0.5) where {T <: Real}
    pos_val = one(T)
    n_minority = count(x -> x == pos_val, y)
    n = length(y)
    res = round(Int, (prop * n) - n_minority)
    res
end

function pct_needed(y::Array{T, 1}, prop) where {T <: Real}
    numer = cases_needed(y)
    denom = count(x -> x == 1, y)
    res = 100 * numer/denom
    res
end


# w1 = [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0]
#
# cases_needed(w1)
# pct_needed(w1)
#
#
#
# X = randn(100, 10)
# y = vcat(zeros(90), ones(10))
# ub_smote(X, y)
