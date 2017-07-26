module ClassImbalance

using DataFrames
using NullableArrays
using CategoricalArrays     # NOTE: consider replacing these with pooled array

include("smote_exs.jl")
include("ub_smote.jl")


end # module
