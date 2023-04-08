import DataFrames
import Distributions
import LinearAlgebra
import Statistics
import StatsBase
import Random
import Tables

function random_undersampler(
        X,
        y::T;
        sampling_strategy::Union{AbstractFloat, String, Dict{Any, Int}} = "auto",
        random_state=nothing
        ) where T <: AbstractVector
    # check if X implements getobs
    @assert Tables.istable(X) "$X is not implementing the MLUtils.jl getobs interface"

    classes = unique(y)
    classpos = Dict(c => findall(y .== c) for c in classes)
    classcount = Dict(c => length(classpos[c]) for c in classes)

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

    X_new = DataFrames.DataFrame(X)
    y_new = copy(y)
end