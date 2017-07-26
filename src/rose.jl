
function numeric_columns(dat)
    p = ncol(dat)
    is_numeric = falses(p)
    for j = 1:p
        typ = eltype(dat[:, j])
        if typ <: Real && typ ≠ Bool
            is_numeric[j] = true
        end
    end
    res = find(is_numeric)
    res
end


function fill_diagonal!(X, diag_elems)
    p = size(X, 2)
    for i = 1:p
        X[i, i] = diag_elems[i]
    end
end


function rose_real(X, n, ids_class, ids_generation, h_mult = 1)
    p = size(X, 2)
	n_new = length(ids_generation)
	cons_kernel = (4/((p+2) * n))^(1/(p+4))

		if p ≠ 1
            sd_mat = eye(p)
            sd_vect = std(X[ids_class, :], 2)
            fill_diagonal!(sd_mat, sd_vect)
			H = h_mult * cons_kernel * sd_mat
		else
			H = h_mult * cons_kernel * std(X[ids_class, :])
        end
	X_new_num = randn(n_new, p) * H
	Xnew_num = Xnew_num + X[ids_generation, :]
	Xnew_num
end


function rose_sampling(X, y, prop, indcs_maj, indcs_min, y_majority, y_minority, h_mult_maj, h_mult_min)
    n = size(X, 1)
    n_minority = sum(rand(Binomial(1, prop), n))
	n_majority = n - n_minority

	indcs_maj_new = sample(indcs_maj, n_majority, replace = true)
	indcs_min_new = sample(indcs_min, n_minority, replace = true)

	numeric_cols = numeric_columns(X)

	# Create  X
    indcs = vcat(indcs_maj_new, indcs_min_new)
	X_new = X[indcs, :]
    if length(numeric_cols) > 0
        X_new[1:n_majority, numeric_cols] = rose_real(X[:, numeric_cols], length(indcs_maj), indcs_maj, indcs_maj_new, h_mult_maj)
        X_new[(n_majority + 1):n, numeric_cols] = rose_real(X[:, numeric_cols], length(indcs_min), indcs_min, indcs_min_new, h_mult_min)
    end

	# Create y
    y_new = similar(y)
    y_new[1:n_majority] = y_majority
    y_new[(n_majority + 1):n] = y_minority

	res = (X_new, y_new)
	res
end


"""
    classlabel(y)
Given a column from a DataFrame, this function returns the majority/minority class label.
"""
function classlabel(y::Array{T, 1}, labeltype = :minority) where T
    count_dict = countmap(y)
    if length(count_dict) > 2
        error("There are more than two classes in the target variable.")
    elseif length(count_dict) < 2
        error("There is only one class in the target variable.")
    end
    labels = keys(count_dict)
    counts = values(count_dict)
    func = (labeltype == :majority) ? :indmax : :indmin
    indx = eval(func)(counts)
    res = collect(labels)[indx]
    res
end





function rose(dat::DataFrame, y_column::Symbol, prop::Float64 = 0.5, h_mult_maj = 1, h_mult_min = 1)
    majority_label = classlabel(dat[y_column], :majority)
    minority_label = classlabel(dat[y_column], :minority)

    indcs_maj = find(dat[y_column] .== majority_label)
    indcs_min = find(dat[y_column] .== minority_label)
    p = size(dat, 2)
    y_indx = findfirst(names(dat) .== y_column)
    X_indcs = setdiff(1:p, y_indx)
    X_new, y_new = rose_sampling(dat[:, X_indcs], dat[:y_column], indcs_maj, indcs_min, prop, h_mult_maj, h_mult_min)
    res = X_new
    res[:y_column] = y_new
    res
end
