# https://medium.com/@ThatShelbs/counterfactual-inference-using-time-series-data-83c0ef8f40a0
# https://opensource.googleblog.com/2014/09/causalimpact-new-open-source-package.html


### Example ###
# http://google.github.io/CausalImpact/CausalImpact.html 

library(CausalImpact)

set.seed(2)
x1 <- 100 + arima.sim(model = list(ar = 0.999), n = 100)
y <- 1.2 * x1 + rnorm(100)
y[71:100] <- y[71:100] + 10
data <- cbind(y, x1)

dim(data)

head(data)

matplot(data, type = "l")

# running the analisis
pre.period <- c(1, 70)
post.period <- c(71, 100)

impact <- CausalImpact(data, pre.period, post.period)

plot(impact)

# Printing a summary table
summary(impact)

summary(impact, "report") # even better
