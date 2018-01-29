using Base.Test
using ClassImbalance

Base.Test.@testset "All Tests" begin
    Base.test.@testset "miscellaneous.jl" begin
        include("miscellaneous.jl")
    end
    Base.test.@testset "simdata.jl" begin
        include("simdata.jl")
    end
    Base.test.@testset "smote_example.jl" begin
        include("smote_example.jl")
    end
    Base.test.@testset "test_utils.jl" begin
        include("test_utils.jl")
    end
end

