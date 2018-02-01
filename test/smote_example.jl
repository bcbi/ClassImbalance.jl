import Distributions
import DataFrames
import RCall
import StatsBase

function simulation_conditions()
    conds = Dict{Symbol, Int}()
    conds[:n] = rand(100:2000)
    conds[:pct_over] = rand(100:1000)
    conds[:pct_under] = rand(100:1000)
    prop_majority = rand(linspace(0.5, 0.99, 100))
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


function smote_counts_jl(sim_conditions)
    X = simdata(sim_conditions)
    pct_over = sim_conditions[:pct_over]
    pct_under = sim_conditions[:pct_under]
    X2, y2 = ClassImbalance._smote(X[:, 1:10], X[:, 11], 5, pct_over, pct_under)
    y2_counts = collect(values(StatsBase.countmap(y2)))
    return y2_counts
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
        library(DMwR)
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


function smote_comparison(sim_conditions)
    # Comparing to output from SMOTE() in the DMwR package
    X = simdata(sim_conditions)
    y2_counts = sort(smote_counts_jl(sim_conditions))
    y2_counts_r = sort(smote_counts_r(sim_conditions))

    # display(y2_counts_r)
    # display(y2_counts)

    if !(y2_counts_r == y2_counts)
        warn("n: $(sim_conditions[:n]) \npct_over: $(sim_conditions[:pct_over]) \npct_under: $(sim_conditions[:pct_under])")
        # failed_comp = vcat(failed_comp, [n, pct_over, pct_under]')
    end
end


function run_comparisons(m)
    for i = 1:m
        info("Simulation: $i")
        conds = simulation_conditions()
        smote_comparison(conds)
    end
end

run_comparisons(1000)
