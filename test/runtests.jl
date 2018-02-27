import Base.Test
import ClassImbalance
import RCall

# install R packages
try
    r_dmwr_package = RCall.rimport("DMwR")
catch
    RCall.reval("install.packages(\"DMwR\", repos = \"https://cran.r-project.org/\")")
    r_dmwr_package = RCall.rimport("DMwR")
end
try
    r_rose_package = RCall.rimport("ROSE")
catch
    RCall.reval("install.packages(\"ROSE\", repos = \"https://cran.r-project.org/\")")
    r_rose_package = RCall.rimport("ROSE")
end

srand(999) # seed the global random number generator

Base.Test.@testset "All Tests" begin
    Base.Test.@testset "miscellaneous.jl" begin
        include("miscellaneous.jl")
    end
    Base.Test.@testset "smote_example.jl" begin
        include("smote_example.jl")
    end
    Base.Test.@testset "test_utils.jl" begin
        include("test_utils.jl")
    end
end

