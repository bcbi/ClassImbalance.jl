module ClassImbalance

# using DataFrames
using DataTables
using NullableArrays
using CategoricalArrays     # NOTE: consider replacing these with pooled array
using Distributions

export smote, rose

include("utils.jl")
include("smote_exs.jl")
include("ub_smote.jl")
include("rose.jl")



end # module
