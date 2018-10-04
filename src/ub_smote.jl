import Random
import StatsBase

function _smote(X::Array, y, k = 5, pct_over = 200, pct_under = 200)
    typ = eltype(y)
    minority_indcs = findall(y .== one(typ))
    n, p = size(X)

    X_synthetic = smote_obs(X[minority_indcs, :], pct_over, k)
    n_synthetic = size(X_synthetic, 1)
    majority_indcs = setdiff(1:size(X, 1), minority_indcs)

    # Get the undersample of the "majority class" examples
    n_majority = floor(Int, (pct_under/100) * n_synthetic)
    sel_majority = StatsBase.sample(majority_indcs, n_majority, replace = true)

    # Final dataset (the undersample + the rare cases + the smoted exs)
    #newdata = vcat(X[sel_majority, :], X[minority_indcs, :], synth_obs)


    # Shuffle the order of instances
    X_new = vcat(X[sel_majority, :], X[minority_indcs, :], X_synthetic)  #newdata[:, 1:(end-1)]
    y_new = vcat(y[sel_majority], y[minority_indcs], ones(typ, n_synthetic))

    n_new = size(X_new, 1)
    indcs = Random.shuffle(1:n_new)
    X_new = X_new[indcs, :]
    y_new = y_new[indcs]
    return (X_new, y_new)
end


function _smote(X::DataFrames.DataFrame, y, k = 5, pct_over = 200, pct_under = 200)
    typ = eltype(y)
    minority_indcs = findall(y .== one(typ))
    n, p = size(X)

    X_synthetic = smote_obs(X[minority_indcs, :], pct_over, k, names(X))
    n_synthetic = size(X_synthetic, 1)
    majority_indcs = setdiff(1:size(X, 1), minority_indcs)

    # Get the undersample of the "majority class" examples
    n_majority = floor(Int, (pct_under/100) * n_synthetic)
    sel_majority = StatsBase.sample(majority_indcs, n_majority, replace = true)

    # Final dataset (the undersample + the rare cases + the smoted exs)
    #newdata = vcat(X[sel_majority, :], X[minority_indcs, :], synth_obs)


    # Shuffle the order of instances
    X_new = vcat(X[sel_majority, :], X[minority_indcs, :], X_synthetic)  #newdata[:, 1:(end-1)]
    y_new = vcat(y[sel_majority], y[minority_indcs], ones(typ, n_synthetic))

    n_new = size(X_new, 1)
    indcs = Random.shuffle(1:n_new)
    X_new = X_new[indcs, :]
    y_new = y_new[indcs]
    return (X_new, y_new)
end



# n_change(n, n1) = 0.5n - n1                        # give us number of new positive cases needed for balanced data




"""
    smote(X, y, k, under, over)
This function implements the SMOTE algorithm for generating synthetic
cases to re-balance the proportion of positive and negative observations.
The `pct_under` and `pct_over` parameters control the proportion of under-sampling
of the majority class and the proportion of over-sampling the minority class.
Note that `pct_under` controls undersampling by selecting pct_under/100 observations
for each _newly created_ minority class observation. The value of `k` allows
us determine who is considered a "neighbor" when generating synthetic cases.
"""
function smote(X, y; k = 5, pct_under = 50, pct_over = 200)
    # over = pct_needed(y)
    # # println("Percent oversampling: $over")
    # n = length(y)
    # pos_val = one(eltype(y))
    # n1 = count(z -> z == pos_val, y)
    # needed = n - (n1 + n1*(over/100))
    # # println("Needed: $needed")
    # under = needed/(n1 * over/100) * 100

    # println("Percent undersampling: $under")
    X_new, y_new = _smote(X, y, k, pct_over, pct_under)
    return (X_new, y_new)
end



# n = 120
# n0 = 60
# X = randn(n, 10);
# y = vcat(zeros(n0), ones(n - n0));
# X2, y2 = smote(X, y, 5)
#
# length(y2)
# countmap(y2)
