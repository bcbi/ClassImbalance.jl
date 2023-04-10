import Random
import StatsBase
import DataFrames
import Tables
import MLUtils

function random_undersampler(
        X,
        y::T;
        sampling_strategy::Union{AbstractFloat, String, Dict{A, S}} = "auto",
        random_state::Union{Nothing, S} = nothing,
        replacement::Bool = false
        ) where T <: AbstractVector where S <: Integer where A <: Any
    # check if X implements getobs
    @assert Tables.istable(X) "$X is not implementing the MLUtils.jl getobs interface"

    classes = unique(y)
    classcount = Dict(c => count(y .== c) for c in classes)

    # checking classes in y
    @assert length(classes) > 1 "$y must have more than one class"
    # checking sampling_strategy
    if typeof(sampling_strategy) <: String
        @assert sampling_strategy in ["auto", "not minority", "not majority", "all", "majority"] "sampling_strategy must be one of \"auto\", \"not minority\", \"not majority\", \"all\", \"majority\""
    elseif typeof(sampling_strategy) <: AbstractFloat
        @assert length(classes) == 2 "sampling_strategy of type float is supported only for binary classification"
        @assert 0 < sampling_strategy <= 1 "sampling_strategy must be between 0 and 1"
    elseif typeof(sampling_strategy) <: Dict
        @assert all(c in classes for c in keys(sampling_strategy)) "sampling_strategy must have keys that are classes in $y"
        @assert all(sampling_strategy[c] <= classcount[c] for c in keys(sampling_strategy)) "sampling_strategy must have values less than or equal to current number of samples for a particular class"
    end

    sampling_strategy = undersampling_strategy!(sampling_strategy, classes, classcount)

    if !isnothing(random_state)
        rng = Random.MersenneTwister(UInt(random_state))
    else
        rng = Random.GLOBAL_RNG
    end

    undersampled_idx = []
    for target_class in classes
        if target_class in keys(sampling_strategy)
            n_samples = sampling_strategy[target_class]
            target_class_idx = findall(y .== target_class)
            target_class_idx_sampled = StatsBase.sample(rng, target_class_idx, n_samples, replace=replacement)
            append!(undersampled_idx, target_class_idx_sampled)
        else
            append!(undersampled_idx, findall(y .== target_class))
        end
    end

    return MLUtils.getobs(X, undersampled_idx), MLUtils.getobs(y, undersampled_idx)
end
