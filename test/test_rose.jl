import ClassImbalance
import DataFrames
import StatsBase
import Test

df = DataFrames.DataFrame()
num_rows = 1_000
df[:x1] = randn(num_rows)
df[:x2] = StatsBase.sample(["a", "b"], num_rows)
df[:x3] = randn(num_rows)
df[:x4] = StatsBase.sample(["d", "e", "f"], num_rows)
df[:x5] = randn(num_rows)
df[:x6] = StatsBase.sample(["g", "h", "i", "j"], num_rows)
df[:y] = StatsBase.sample([0,1], num_rows)

df_rose_result = ClassImbalance.rose(df,:y,)

df = DataFrames.DataFrame()
num_rows = 1_000
df[:x1] = randn(num_rows)
df[:y] = StatsBase.sample([0,1], num_rows)

df_rose_result = ClassImbalance.rose(df,:y,)

Test.@test_throws(
    ErrorException,
    ClassImbalance.classlabel([0,0,0,0,0,0,0,0]),
    )

Test.@test_throws(
    ErrorException,
    ClassImbalance.classlabel([1,1,1,1,1,1,1,1,1]),
    )

Test.@test_throws(
    ErrorException,
    ClassImbalance.classlabel([0,0,0,0,1,1,1,1,2,2,2,2,]),
    )
