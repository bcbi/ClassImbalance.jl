

# d = readtable("./data/people.csv", makefactors = true)

function factor_columns(dat::DataFrame)
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
    res = zeros(n)
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


function smote_obs(dat::DataFrame, pct = 200, k = 5)
    if pct < 1
        warn("Percent over-sampling cannot be less than 1.\n
              Setting `pct` to 1.")
        pct = 1
    end

    n, p = size(dat)

    # When pct < 100, only a percentage of cases will be SMOTEd
    if pct < 100
        n_needed = floor(Int, (pct/100) * n)
        indcs = sample(1:n, n_needed)
        X = X[indcs, :]
        pct = 100
    end

    # Calling function has outcome variable in last column
    factor_indcs = factor_columns(dat)

    X = zeros(n, p)

    for j = 1:p
        if j ∈ factor_indcs
            X[:, j] = factor_to_float(dat[:, j])
        else
            X[:, j] = convert(Array{Float64, 1}, dat[:, j])
        end
    end

    ranges = column_ranges(X)

    n_exs = round(Int, floor(pct/100))   # num. of artificial ex for each member of X
    X_new = zeros(n_exs * n, p)

    for i = 1:n

        # the k nearest neighbors of case X[i, ]
        xd = rscale(X, X[i, :], ranges)

        for col in factor_indcs
            xd[:, col] = map(x -> x == 0.0 ? 1.0 : 0.0, xd[:, col])
        end

        dd = xd.^2 * ones(p)
        last_idx = (length(dd) ≤ k + 1) ? length(dd) : (k + 1)         # HACK: Find out why `dd` is sometimes less than k+1
        #last_idx = k+1
        # Debugging:
        if last_idx < k+1
            warn("Constraint applied for (k + 1): $(k+1), and last_idx: $last_idx ")
        end
        k_nns = sortperm(dd)[2:last_idx]

        for l = 1:n_exs
            n_neighbors = (length(k_nns) == k) ? k : length(k_nns)
            neighbor = sample(1:n_neighbors)
            ex = zeros(p)

            # the attribute values of generated case
            difs = X[k_nns[neighbor], :] - X[i, :]
            X_new[(i - 1) * n_exs + l, :] = X[i, :] + rand() * difs

            # For each of the factor variables, sample at random the original value
            # of Person i or the value that one of Person i's nearest neighbors has.
            for col in factor_indcs
                X_new[(i - 1) * n_exs + l, col] = sample(vcat(X[k_nns[neighbor], col], X[i, col]))
            end
        end
    end

    X_synth = T()
    for j = 1:p
        if j ∈ factor_indcs
            X_synth[:, j] = float_to_factor(X_new[:, j], levels(dat[:, j]))
        else
            X_synth[:, j] = X_new[:, j]
        end
    end
    yval = String(dat[1, tgt].value)
    X_synth[:, tgt] = CategoricalArray(fill(yval, n_exs*n))
    return X_synth
end



# This version of the function is to be used when we have no factor
# variables. And it assumes input is simply a numeric matrix, where
# the last column is the outcome (or target) variable.
# NOTE: `pct` is the percent of positive examples relative to total
# sample size to be returned.
function smote_obs(X::Array{S, 2}, pct = 200, k = 5) where {S <: Real}
    if pct < 1
        warn("Percent over-sampling cannot be less than 1.\n
              Setting `pct` to 1.")
        pct = 1
    end

    n, p = size(X)

    # When pct < 100, only a percentage of cases will be SMOTEd
    if pct < 100
        n_needed = floor(Int, (pct/100) * n)
        indcs = sample(1:n, n_needed)
        X = X[indcs, :]
        pct = 100
    end

    ranges = column_ranges(X)

    n_exs = floor(Int, pct/100)   # num. of artificial ex for each member of X
    X_new = zeros(n_exs * n, p)

    for i = 1:n

        # The k nearest neighbors of case X[i, ]
        xd = rscale(X, X[i, :], ranges)

        dd = xd.^2 * ones(p)
        last_idx = (length(dd) ≤ k + 1) ? length(dd) : (k + 1)         # HACK: Find out why `dd` is sometimes less than k+1
        #last_idx = k+1
        # Debugging:
        if last_idx < k+1
            warn("Constraint applied for (k + 1): $(k + 1), and last_idx: $last_idx ")
        end

        k_nns = sortperm(dd)[2:last_idx]

        for l = 1:n_exs
            n_neighbors = (length(k_nns) == k) ? k : length(k_nns)
            neighbor = sample(1:n_neighbors)
            # ex = Array{Float64, 1}(p)

            # Xhe attribute values of generated case
            difs = X[k_nns[neighbor], :] - X[i, :]
            X_new[(i - 1) * n_exs + l, :] = X[i, :] + rand() * difs
        end
    end
    X_new
end

# m = 150
# X = rand(m, 10)
# y = ones(m)
# X = hcat(X, y)
#
# smote_obs(X, 11)




function cases_needed(y::Array{T, 1}, prop = 0.5) where {T <: Real}
    pos_val = one(T)
    n_minority = count(x -> x == pos_val, y)
    n = length(y)
    res = round(Int, (prop * n) - n_minority)
    res
end

function pct_needed(y::Array{T, 1}, prop = 0.5) where {T <: Real}
    numer = cases_needed(y, prop)
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
