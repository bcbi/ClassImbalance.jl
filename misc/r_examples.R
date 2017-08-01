library(DMwR)

n <- 1648
pct_over <- 180
pct_under <- 273
n_minority <- round(0.1*n)
n_majority <- round(0.9*n)

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
table(dat2$y)
