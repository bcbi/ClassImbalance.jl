using ClassImbalance
using Base.Test


function countdict(x)
    typ = eltype(x)
    cnts = Dict{typ, Int}()
    n = length(x)
    for i = 1:n
        cnts[x[i]] = get(cnts, x[i], 0) + 1
    end
    cnts
end


X = rand(200, 10)
y = vcat(zeros(180), ones(20))

X2, y2 = smote(X, y, k = 5, pct_over = 200, pct_under = 200)

cnts = countdict(y2)

@test cnts[0.0] == 80
@test cnts[1.0] == 60



df = DataTable(hcat(X, y))
X3, y3 = smote(df[:, 1:9], df[:, 10], k = 5, pct_over = 300, pct_under = 300)

cnts = countdict(y3)

@test cnts[0.0] == 180
@test cnts[1.0] == 80
