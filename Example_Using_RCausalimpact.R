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


### -----------------------
library(quantmod) 

# https://financetrain.com/downloading-stock-data-in-r-using-quantmod

getSymbols("RH",
           from = "2022/11/30",
           to = "2023/03/31",
           periodicity = "daily")

# Take all the interesting shares

# Alphabet shares dive after Google AI chatbot Bard flubs answer in ad
# By Martin Coulter and Greg Bensinger
# February 9, 20231:49 AM GMT+1Updated 6 months ago

my_comp_symbols <- c( "GOOG", "META", "AMZN", "AAPL", "MSFT", "NVDA")

myStocks <-lapply(my_comp_symbols, function(x) {getSymbols(x, 
                                                             from ="2022/11/30", 
                                                             to = "2023/03/31",
                                                             periodicity = "daily",
                                                             auto.assign=FALSE)} )

names(myStocks) <- my_comp_symbols

# let's look at the apple
head(myStocks$AAPL)

# We want only the adjusted stocks
adjustedPrices <- lapply(myStocks, Ad)


