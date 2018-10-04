import Distributions
import DataFrames
import RCall
import StatsBase

function simulation_conditions()
    conds = Dict{Symbol, Int}()
    conds[:n] = rand(100:2000)
    conds[:pct_over] = rand(100:1000)
    conds[:pct_under] = rand(100:1000)
    prop_majority = rand(range(0.5, stop=0.99, length=100))
    conds[:n_majority] = round(Int, prop_majority * conds[:n])
    conds[:n_minority] = conds[:n] - conds[:n_majority]
    return conds
end


function simdata(sim_conditions)
    X = rand(sim_conditions[:n], 10)
    y = vcat(zeros(sim_conditions[:n_majority]), ones(sim_conditions[:n_minority]))
    X = hcat(X, y)
    return X
end

function smote_counts_jl_array(sim_conditions)
    Xy_array = simdata(sim_conditions)
    pct_over = sim_conditions[:pct_over]
    pct_under = sim_conditions[:pct_under]
    X2_array, y2_array = ClassImbalance._smote(
        Xy_array[:, 1:10],
        Xy_array[:, 11],
        5,
        pct_over,
        pct_under,
        )
    y2_counts_array = collect(values(StatsBase.countmap(y2_array)))
    return y2_counts_array
end

function smote_counts_jl_df(sim_conditions)
    Xy_array = simdata(sim_conditions)
    pct_over = sim_conditions[:pct_over]
    pct_under = sim_conditions[:pct_under]
    X = DataFrames.DataFrame()
    p = size(Xy_array, 2)
    @assert(p >= 2)
    for j = 1:(p - 1)
        column_name = Symbol(string("x", j))
        X[column_name] = Xy_array[:, j]
    end
    y = Xy_array[:, end]
    X2, y2 = ClassImbalance._smote(
        X,
        y,
        5,
        pct_over,
        pct_under,
        )
    y2_counts_df = collect(values(StatsBase.countmap(y2)))
    return y2_counts_df
end

function smote_counts_r(sim_conditions)
    n = sim_conditions[:n]
    pct_over = sim_conditions[:pct_over]
    pct_under = sim_conditions[:pct_under]
    n_minority = sim_conditions[:n_majority]
    n_majority = sim_conditions[:n_minority]
    RCall.@rput n
    RCall.@rput pct_over
    RCall.@rput pct_under
    RCall.@rput n_minority
    RCall.@rput n_majority
    RCall.R"""
        library("DMwR")
        X <- matrix(rnorm(n*10), ncol = 10)
        X <- cbind(1, X)
        dat <- data.frame(X)

        dat$y <- c(rep(0, n_majority), rep(1, n_minority))
        dat$y <- as.factor(dat$y)

        dat2 <- SMOTE(y ~ ., dat, perc.over = pct_over, perc.under = pct_under)
        df <- data.frame(table(dat2$y))
        y2_counts_r <- array(df[, 2])
    """
    RCall.@rget dat2
    RCall.@rget y2_counts_r
    return y2_counts_r
end

function smote_comparison_array(sim_conditions)
    # Comparing to output from SMOTE() in the DMwR package
    # Xy = simdata(sim_conditions)
    y2_counts_array = sort(smote_counts_jl_array(sim_conditions))
    y2_counts_r  = sort(smote_counts_r(sim_conditions))

    @info(string("y2_counts_r: "), y2_counts_r)
    @info(string("y2_counts_array: "), y2_counts_array)

    count_1_error_absolute =
        abs(abs(y2_counts_array[1]) - abs(y2_counts_r[1]))
    count_2_error_absolute =
        abs(abs(y2_counts_array[2]) - abs(y2_counts_r[2]))
    sum_error_absolute =
        abs(abs(sum(abs.(y2_counts_array))) - abs(sum(abs.(y2_counts_r))))

    count_1_error_relative_julia_percent =
        count_1_error_absolute/abs(y2_counts_array[1])*100.0
    count_1_error_relative_r_percent =
        count_1_error_absolute/abs(y2_counts_r[1])*100.0
    count_2_error_relative_julia_percent =
        count_2_error_absolute/abs(y2_counts_array[2])*100.0
    count_2_error_relative_r_percent =
        count_2_error_absolute/abs(y2_counts_r[2])*100.0
    sum_error_relative_julia_percent =
        sum_error_absolute/abs(sum(abs.(y2_counts_array)))*100.0
    sum_error_relative_r_percent =
        sum_error_absolute/abs(sum(abs.(y2_counts_r)))*100.0

    if !all(y2_counts_array .== y2_counts_r)
        @warn(
            string(
                "The counts from our smote function did not exactly match ",
                "the counts from R ",
                "(y2_counts_array was not equal to y2_counts_r).",
                ),
            y2_counts_array,
            y2_counts_r,
            sim_conditions,
            )
        @warn(
            string("Difference between counts: "),
            count_1_error_absolute,
            count_2_error_absolute,
            sum_error_absolute,
            count_1_error_relative_julia_percent,
            count_1_error_relative_r_percent,
            count_2_error_relative_julia_percent,
            count_2_error_relative_r_percent,
            sum_error_relative_julia_percent,
            sum_error_relative_r_percent,
            )
    end

    if count_1_error_relative_julia_percent > 1.0
        @warn(
            "count_1_error_relative_julia_percent: ",
            count_1_error_relative_julia_percent,
            )
        error("count_1_error_relative_julia_percent > 1.0")
    end
    if count_1_error_relative_r_percent > 1.0
        @warn(
            "count_1_error_relative_r_percent: ",
            count_1_error_relative_r_percent,
            )
        error("count_1_error_relative_r_percent > 1.0")
    end
    if count_2_error_relative_julia_percent > 1.0
        @warn(
            "count_2_error_relative_julia_percent: ",
            count_2_error_relative_julia_percent,
            )
        error("count_2_error_relative_julia_percent > 1.0")
    end
    if count_2_error_relative_r_percent > 1.0
        @warn(
            "count_2_error_relative_r_percent: ",
            count_2_error_relative_r_percent,
            )
        error("count_2_error_relative_r_percent > 1.0")
    end
    if sum_error_relative_julia_percent > 1.0
        @warn(
            "sum_error_relative_julia_percent: ",
            sum_error_relative_julia_percent,
            )
        error("sum_error_relative_julia_percent > 1.0")
    end
    if sum_error_relative_r_percent > 1.0
        @warn(
            "sum_error_relative_r_percent: ",
            sum_error_relative_r_percent,
            )
        error("sum_error_relative_r_percent > 1.0")
    end

    status = all(y2_counts_array .== y2_counts_r)

    return status
end

function smote_comparison_df(sim_conditions)
    # Comparing to output from SMOTE() in the DMwR package
    # Xy = simdata(sim_conditions)
    y2_counts_df = sort(smote_counts_jl_df(sim_conditions))
    y2_counts_r  = sort(smote_counts_r(sim_conditions))

    @info(string("y2_counts_r: "), y2_counts_r)
    @info(string("y2_counts_df: "), y2_counts_df)

    count_1_error_absolute =
        abs(abs(y2_counts_df[1]) - abs(y2_counts_r[1]))
    count_2_error_absolute =
        abs(abs(y2_counts_df[2]) - abs(y2_counts_r[2]))
    sum_error_absolute =
        abs(abs(sum(abs.(y2_counts_df))) - abs(sum(abs.(y2_counts_r))))

    count_1_error_relative_julia_percent =
        count_1_error_absolute/abs(y2_counts_df[1])*100.0
    count_1_error_relative_r_percent =
        count_1_error_absolute/abs(y2_counts_r[1])*100.0
    count_2_error_relative_julia_percent =
        count_2_error_absolute/abs(y2_counts_df[2])*100.0
    count_2_error_relative_r_percent =
        count_2_error_absolute/abs(y2_counts_r[2])*100.0
    sum_error_relative_julia_percent =
        sum_error_absolute/abs(sum(abs.(y2_counts_df)))*100.0
    sum_error_relative_r_percent =
        sum_error_absolute/abs(sum(abs.(y2_counts_r)))*100.0

    if !all(y2_counts_df .== y2_counts_r)
        @warn(
            string(
                "The counts from our smote function did not exactly match ",
                "the counts from R ",
                "(y2_counts_df was not equal to y2_counts_r).",
                ),
            y2_counts_df,
            y2_counts_r,
            sim_conditions,
            )
        @warn(
            string("Difference between counts: "),
            count_1_error_absolute,
            count_2_error_absolute,
            sum_error_absolute,
            count_1_error_relative_julia_percent,
            count_1_error_relative_r_percent,
            count_2_error_relative_julia_percent,
            count_2_error_relative_r_percent,
            sum_error_relative_julia_percent,
            sum_error_relative_r_percent,
            )
    end

    if count_1_error_relative_julia_percent > 1.0
        @warn(
            "count_1_error_relative_julia_percent: ",
            count_1_error_relative_julia_percent,
            )
        error("count_1_error_relative_julia_percent > 1.0")
    end
    if count_1_error_relative_r_percent > 1.0
        @warn(
            "count_1_error_relative_r_percent: ",
            count_1_error_relative_r_percent,
            )
        error("count_1_error_relative_r_percent > 1.0")
    end
    if count_2_error_relative_julia_percent > 1.0
        @warn(
            "count_2_error_relative_julia_percent: ",
            count_2_error_relative_julia_percent,
            )
        error("count_2_error_relative_julia_percent > 1.0")
    end
    if count_2_error_relative_r_percent > 1.0
        @warn(
            "count_2_error_relative_r_percent: ",
            count_2_error_relative_r_percent,
            )
        error("count_2_error_relative_r_percent > 1.0")
    end
    if sum_error_relative_julia_percent > 1.0
        @warn(
            "sum_error_relative_julia_percent: ",
            sum_error_relative_julia_percent,
            )
        error("sum_error_relative_julia_percent > 1.0")
    end
    if sum_error_relative_r_percent > 1.0
        @warn(
            "sum_error_relative_r_percent: ",
            sum_error_relative_r_percent,
            )
        error("sum_error_relative_r_percent > 1.0")
    end

    status = all(y2_counts_df .== y2_counts_r)

    return status
end

function run_comparisons_array(m)
    num_success = 0
    num_failure = 0
    for i = 1:m
        @info("Array simulation: $i")
        conds = simulation_conditions()
        sim_was_success = smote_comparison_array(conds)
        if sim_was_success
            num_success += 1
        else
            num_failure += 1
        end
    end

    @info(
        "Result of running array simulations: ",
        m,
        num_success,
        num_failure,
        )
    if !(num_success + num_failure == m)
        error("!(num_success + num_failure == m)")
    end
    percent_failure = num_failure/m*100.0
    @info(
        "percent_failure: ",
        percent_failure,
        )
    Test.@test(percent_failure < 1.0)
end

function run_comparisons_df(m)
    num_success = 0
    num_failure = 0
    for i = 1:m
        @info("DataFrame simulation: $i")
        conds = simulation_conditions()
        sim_was_success = smote_comparison_df(conds)
        if sim_was_success
            num_success += 1
        else
            num_failure += 1
        end
    end

    @info(
        "Result of running DataFrame simulations: ",
        m,
        num_success,
        num_failure,
        )
    if !(num_success + num_failure == m)
        error("!(num_success + num_failure == m)")
    end
    percent_failure = num_failure/m*100.0
    @info(
        "percent_failure: ",
        percent_failure,
        )
    Test.@test(percent_failure < 1.0)
end

run_comparisons_array(1000)

run_comparisons_df(1000)
