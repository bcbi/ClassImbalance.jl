module ClassImbalance

using DataFrames
using NullableArrays
using CategoricalArrays     # NOTE: consider replacing these with pooled array
using Distributions

include("smote_exs.jl")
include("ub_smote.jl")


end # module
