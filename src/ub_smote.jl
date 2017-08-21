
function ub_smote(X, y, pct_over = 200, k = 5, pct_under = 200)
    dat = hcat(X, y)
    typ = eltype(y)
    minority_indcs = find(y .== one(typ))
    n, p = size(dat)

    new_exs = smote_exs(dat[minority_indcs, :], p, pct_over, k)
    majority_indcs = setdiff(1:size(X, 1), minority_indcs)

    # Get the undersample of the "majority class" examples
    n_majority = floor(Int, (pct_under/100) * size(new_exs, 1))
    sel_majority = sample(majority_indcs, n_majority, replace = true)

    # Final dataset (the undersample + the rare cases + the smoted exs)
    newdata = vcat(dat[sel_majority, :], dat[minority_indcs, :], new_exs)
    n_new = size(newdata, 1)

    # Shuffle the order of instances
    newdata = newdata[shuffle(1:n_new), :]
    X_new = newdata[:, 1:(end-1)]
    y_new = newdata[:, end]

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
    X_new, y_new = ub_smote(X, y, pct_over, k, pct_under)
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
