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

df_smote_obs_result = ClassImbalance.smote_obs(df,0.01,0)
df_smote_obs_result = ClassImbalance.smote_obs(df,300,0)

df_1 = DataFrames.DataFrame(x = ["a", "b", "c"])
df_2 = ClassImbalance.dataframe_to_matrix(df_1, [1], 3, 1)
df_3 = ClassImbalance.matrix_to_dataframe(df_2, df_1, [1])
Test.@test(all(df_1[:, 1] .== df_3[:, 1]))

num_rows = 1_000
x1 = randn(num_rows)
x2 = randn(num_rows)
x3 = randn(num_rows)
X = hcat(x1, x2, x3)
X_smote_obs_result = ClassImbalance.smote_obs(X, 0.01, 0)
X_smote_obs_result = ClassImbalance.smote_obs(X, 300, 0)

w1 = [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Test.@test(
    cases_needed(w1) == 3
    )
Test.@test(
    pct_needed(w1) == 100.0
    )
