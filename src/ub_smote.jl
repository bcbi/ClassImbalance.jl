
function ub_smote(X::Array{S, 2}, y, pct_over = 200, k = 5, pct_under = 200) where {S <: Real}

    dat = hcat(X, y)
    minority_indcs = find(y .== 1.0)
    n, p = size(dat)

    new_exs = smote_exs(dat[minority_indcs, :], p, pct_over, k)
    majority_indcs = setdiff(1:size(X, 1), minority_indcs)

    # Get the undersample of the "majority class" examples
    sel_majority = sample(majority_indcs,
                          floor(Int, (pct_under/100) * size(new_exs, 1)),
                          replace = true)

    # Final dataset (the undersample + the rare cases + the smoted exs)
    newdata = vcat(dat[sel_majority, :], dat[minority_indcs, :], new_exs)
    n_new = size(newdata, 1)

    # Shuffle the order of instances
    newdata = newdata[sample(1:n_new, n_new, replace = false), :]

    X_new = newdata[:, 1:(end-1)]
    y_new = newdata[:, end]

    return (X_new, y_new)
end



# n_change(n, n1) = 0.5n - n1                        # give us number of new positive cases needed for balanced data

function smote(X, y::Array{T, 1}, k::Int, pct_majority, pct_minority) where {T <: Real}
    pct_minority = pct_needed(y)
    # println("Percent oversampling: $pct_minority")
    n = length(y)
    pos_val = one(T)
    n1 = count(z -> z == pos_val, y)
    needed = n - (n1 + n1*(pct_minority/100))
    # println("Needed: $needed")
    pct_majority = needed/(n1 * pct_minority/100) * 100

    # println("Percent undersampling: $pct_majority")
    X_new, y_new = ub_smote(X, y, pct_minority, k, pct_majority)
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
