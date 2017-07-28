using Distributions
using DataFrames
using RCall

cd("/Users/pstey/projects_code/ClassImbalance")

include("../src/smote_exs.jl")
include("../src/ub_smote.jl")

failed_comp = zeros(Int, 1, 3)

n = rand(100:2000)
pct_over = rand(100:1000)
pct_under = rand(100:1000)
n_majority = round(Int, 0.9n)
n_minority = round(Int, 0.1n)

X = rand(n, 10)
y = vcat(zeros(n_majority), ones(n_minority))
X = hcat(X, y)
# display(size(X))
# display(countmap(X[:, 11]))

X2, y2 = ub_smote(X[:, 1:10], X[:, 11], pct_over, 5, pct_under)
# display(length(y2))
# display(countmap(y2))
y2_counts = collect(values(countmap(y2)))


# Comparing to output from SMOTE() in the DMwR package
@rput n
@rput pct_over
@rput pct_under
@rput n_minority
@rput n_majority
R"""
library(DMwR)

# Create predictor variables
X <- matrix(rnorm(n*10), ncol = 10)
X <- cbind(1, X)
dat <- data.frame(X)

# Creat outcome variable
dat$y<- c(rep(0, n_majority), rep(1, n_minority))
dat$y <- as.factor(dat$y)

# Smote the data
dat2 <- SMOTE(y ~ ., dat, perc.over = pct_over, perc.under = pct_under)
nrow(dat2)
df <- data.frame(table(dat2$y))
y2_counts_r <- array(df[, 2])
"""
@rget dat2
@rget y2_counts_r
display(size(dat2, 1))
display(size(X2, 1))
display(y2_counts_r)
display(y2_counts)

if !(y2_counts_r == y2_counts)
    println("n: $n \npct_over: $pct_over \npct_under: $pct_under")
    failed_comp = vcat(failed_comp, [n, pct_over, pct_under]')
end













w1 = [1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0]

cases_needed(w1)
pct_needed(w1)




# An n = 100 and n1 = 45 breaks smote() without the HACK
# that was added in the smote_exs() function
n = 100
n1 = 10

X = randn(n, 10);
y = vcat(zeros(n - n1), ones(n1));
X2, y2 = smote(X, y, 5);

length(y2)
display(countmap(y2))


X = randn(150, 10);
y = vcat(zeros(130), ones(20));
X2, y2 = smote(X, y, 5)

length(y2)
display(countmap(y2))







# n = 120
# n0 = 60
# X = randn(n, 10);
# y = vcat(zeros(n0), ones(n - n0));
# X2, y2 = smote(X, y, 5)
#
# length(y2)
# countmap(y2)
