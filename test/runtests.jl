import ClassImbalance
import Random
import Test

Random.seed!(999) # seed the global random number generator

include("install_r.jl")

include("install_dmwr.jl")

Test.@testset "miscellaneous.jl" begin
    include("miscellaneous.jl")
end

Test.@testset "smote_example.jl" begin
    include("smote_example.jl")
end

Test.@testset "test_rose.jl" begin
    include("test_rose.jl")
end

Test.@testset "test_smote_exs.jl" begin
    include("test_smote_exs.jl")
end

Test.@testset "test_utils.jl" begin
    include("test_utils.jl")
end
