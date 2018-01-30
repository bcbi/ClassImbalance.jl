import Base.Test
import ClassImbalance

Base.Test.@testset "All Tests" begin
    Base.Test.@testset "miscellaneous.jl" begin
        include("miscellaneous.jl")
    end
    Base.Test.@testset "smote_example.jl" begin
        #include("smote_example.jl")
    end
    Base.Test.@testset "test_utils.jl" begin
        include("test_utils.jl")
    end
end

