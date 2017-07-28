library(DMwR)

n <- 100
betas <- c(1, 2, 3, 4, 1)

# Create predictor variables
X <- matrix(rnorm(n*10), ncol = 10)
X <- cbind(1, X)
dat <- data.frame(X)

# Creat outcome variable
dat$y<- c(rep(1, 0.1*n), rep(0, 0.9*n))
dat$y <- as.factor(dat$y)

# Smote the data
dat2 <- SMOTE(y ~ ., dat)
nrow(dat2)
table(dat2$y)
