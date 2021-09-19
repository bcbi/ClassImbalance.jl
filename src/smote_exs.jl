import DataFrames
import StatsBase

# d = readtable("./data/people.csv", makefactors = true)

# Convert DataFrames.DataFrame or DataTable object to matrix
function dataframe_to_matrix(dat, factor_indcs, n, p)
    X = zeros(n, p)

    for j = 1:p
        if j ∈ factor_indcs
            X[:, j] = factor_to_float(dat[:, j])
        else
            X[:, j] = convert(Array{Float64, 1}, dat[:, j])
        end
    end
    X
end

# Convert matrix to DataFrames.DataFrame or DataTable object
function matrix_to_dataframe(X_new::Array{Float64, 2}, dat::DataFrames.DataFrame, factor_indcs::Array{Int, 1})
    X_synth = DataFrames.DataFrame()
    p = size(X_new, 2)
    for j = 1:p
        if j ∈ factor_indcs
            X_synth[:, Symbol(:x, j)] = float_to_factor(X_new[:, j],
                                            DataFrames.levels(dat[:, j]))
        else
            X_synth[:, Symbol(:x, j)] = X_new[:, j]
        end
    end
    X_synth
end

function smote_obs(dat::DataFrames.DataFrame, pct = 200, k = 5, column_names = names(dat))
    if pct < 1
        @warn("Percent over-sampling cannot be less than 1. Setting `pct` to 1.")
    end
    if pct < 1
        pct = 1
    end

    if k < 1
        @warn("k cannot be less than 1. Setting `k` to 1.")
    end
    if k < 1
        k = 1
    end

    n, p = size(dat)

    # Calling function has outcome variable in last column
    factor_indcs = factor_columns(dat)
    X = dataframe_to_matrix(dat, factor_indcs, n, p)

    # When pct < 100, only a percentage of cases will be SMOTEd
    if pct < 100
        n_needed = max(k + 1, floor(Int, (pct/100) * n))
    end
    indcs = Colon()
    if pct < 100
        indcs = StatsBase.sample(1:n, n_needed)
    end
    X = X[indcs, :]
    if pct < 100
        # @info(
        #     string("pct is < 100, so only a percentage of cases will be SMOTEd"),
        #     pct,
        #     k,
        #     k+1,
        #     n,
        #     n_needed,
        #     )
    end
    if pct < 100
        pct = 100
    end

    n, p = size(X)

    ranges = column_ranges(X)

    n_obs = round(Int, floor(pct/100))   # num. of artificial ex for each member of X
    X_new = zeros(n_obs * n, p)

    for i = 1:n
        # the k nearest neighbors of case X[i, ]
        xd = rscale(X, X[i, :], ranges)

        for col in factor_indcs
            xd[:, col] = map(x -> x == 0.0 ? 1.0 : 0.0, xd[:, col])
        end

        dd = xd.^2 * ones(p)
        last_idx = (length(dd) ≤ k + 1) ? length(dd) : (k + 1)         # HACK: Find out why `dd` is sometimes less than k+1
        #last_idx = k+1

        if last_idx < k+1
            @warn(
                string("Constraint applied. "),
                i,
                k,
                k+1,
                last_idx,
                )
        end
        k_nns = sortperm(dd)[2:last_idx]

        for l = 1:n_obs
            n_neighbors = (length(k_nns) == k) ? k : length(k_nns)
            neighbor = StatsBase.sample(1:n_neighbors)

            # the attribute values of generated case
            difs = X[k_nns[neighbor], :] - X[i, :]
            X_new[(i - 1) * n_obs + l, :] = X[i, :] + rand() * difs

            # For each of the factor variables, sample at random the original value
            # of Person i or the value that one of Person i's nearest neighbors has.
            for col in factor_indcs
                X_new[(i - 1) * n_obs + l, col] = StatsBase.sample(vcat(X[k_nns[neighbor], col], X[i, col]))
            end
        end
    end
    X_newdf = matrix_to_dataframe(X_new, dat, factor_indcs)
    DataFrames.rename!(X_newdf, column_names)
    X_newdf
end

# This version of the function is to be used when we have no factor
# variables. And it assumes input is simply a numeric matrix, where
# the last column is the outcome (or target) variable.
# NOTE: `pct` is the percent of positive examples relative to total
# sample size to be returned.
function smote_obs(X::Array{S, 2}, pct = 200, k = 5) where {S <: Real}
    if pct < 1
        @warn("Percent over-sampling cannot be less than 1. Setting `pct` to 1.")
    end
    if pct < 1
        pct = 1
    end

    if k < 1
        @warn("k cannot be less than 1. Setting `k` to 1.")
    end
    if k < 1
        k = 1
    end

    n, p = size(X)

    # When pct < 100, only a percentage of cases will be SMOTEd
    if pct < 100
        n_needed = max(k + 1, floor(Int, (pct/100) * n))
    end
    indcs = Colon()
    if pct < 100
        indcs = StatsBase.sample(1:n, n_needed)
    end
    X = X[indcs, :]
    if pct < 100
        # @info(
        #     string("pct is < 100, so only a percentage of cases will be SMOTEd"),
        #     pct,
        #     k,
        #     k+1,
        #     n,
        #     n_needed,
        #     )
    end
    if pct < 100
        pct = 100
    end

    n, p = size(X)

    ranges = column_ranges(X)
    n_obs = floor(Int, pct/100)   # num. of artificial ex for each member of X
    X_new = zeros(n_obs * n, p)

    for i = 1:n
        # The k nearest neighbors of case X[i, ]
        xd = rscale(X, X[i, :], ranges)

        dd = xd.^2 * ones(p)
        last_idx = (length(dd) ≤ k + 1) ? length(dd) : (k + 1)         # HACK: Find out why `dd` is sometimes less than k+1
        #last_idx = k+1

        if last_idx < k+1
            @warn(
                string("Constraint applied. "),
                i,
                k,
                k+1,
                last_idx,
                )
        end

        k_nns = sortperm(dd)[2:last_idx]

        for l = 1:n_obs
            n_neighbors = (length(k_nns) == k) ? k : length(k_nns)
            neighbor = nothing
            neighbor = StatsBase.sample(convert(Array, 1:n_neighbors))
            difs = X[k_nns[neighbor], :] - X[i, :]
            X_new[(i - 1) * n_obs + l, :] = X[i, :] + rand() * difs
        end
    end
    return X_new
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
