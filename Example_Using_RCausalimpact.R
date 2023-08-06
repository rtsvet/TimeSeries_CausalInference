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

getSymbols("NYSE:RHT",
           from = "2022/11/30",
           to = "2023/03/31",
           periodicity = "daily")

# Take all the interesting shares

# Alphabet shares dive after Google AI chatbot Bard flubs answer in ad
# By Martin Coulter and Greg Bensinger
# February 9, 2023 1:49 AM GMT+1Updated 6 months ago

my_comp_symbols <- c( "GOOG",  "AMZN", "AAPL", "MSFT", "NVDA", "META")
my_comp_symbols <- c( "GOOG",  "AMZN", "AAPL", "MSFT")


myStocks <-lapply(my_comp_symbols, function(x) {getSymbols(x, 
                                                             from ="2022/11/30", 
                                                             to = "2023/03/31",
                                                             periodicity = "daily",
                                                             auto.assign=FALSE)} )

names(myStocks) <- my_comp_symbols

# let's look at the apple
head(myStocks$AAPL)
plot.xts(myStocks$AAPL)

# We want only the adjusted stocks
adjustedPrices <- lapply(myStocks, Ad)

GOOG <- adjustedPrices$GOOG
plot.xts(GOOG)

stocks_df <- as.data.frame(adjustedPrices)

pre.period <- as.Date(c("2022-11-30", "2023-02-08"))
post.period <- as.Date(c("2023-02-09", "2023-03-30"))

impact <- CausalImpact(stocks_df, pre.period, post.period)

summary(impact, "report") # even better
plot(impact)

plot(impact, c("original"))

#### Lets see what going on compared to the stocks in the basked

library(ggplot2)

stocks_df$date <- row.names(stocks_df)  

# Convert to long format
library(reshape)
data_to_plot <- melt(stocks_df, id.vars = "date")
data_to_plot$date <- as.Date(data_to_plot$date)

# Plot the final data
ggplot(data_to_plot,                           
       aes(x = date,
           y = value,
           col = variable) ) + geom_line()

# Lets make a nrm. bucket for the share-movement in the pre period and see 
# how well it correlates to the chosen share
pre.period

library(dplyr)

# filter only the preperiod
data_pre.period <-  stocks_df %>% filter(date <= pre.period[2])

# calculate the normalized movements
data_pre.period$GOOG_norm <- data_pre.period$GOOG.Adjusted/data_pre.period$GOOG.Adjusted[1]
data_pre.period$BUCKET_norm <- (
  data_pre.period$AMZN.Adjusted +
    data_pre.period$AAPL.Adjusted +
    data_pre.period$MSFT.Adjusted
) /
  (
    data_pre.period$AMZN.Adjusted[1] +
      data_pre.period$AAPL.Adjusted[1] +
      data_pre.period$MSFT.Adjusted[1]
  )

# look visually at the correlation
plot(data_pre.period$GOOG_norm, data_pre.period$BUCKET_norm)
# add the regression line
abline(lm( data_pre.period$BUCKET_norm ~ data_pre.period$GOOG_norm), col = "red" )
grid(nx = NULL, ny = NULL)

cor(data_pre.period$GOOG_norm, data_pre.period$BUCKET_norm)
# correlation of 93% !!!

lm <- lm(data_pre.period$GOOG_norm ~  sqrt(data_pre.period$BUCKET_norm) )

summary(lm)

# R squared of 86% ! pretty good!

## lets play with some non linear models
library(nls2)

# fit a non-linear model of the form y = a * b^x
y <- data_pre.period$BUCKET_norm
x <- data_pre.period$GOOG_norm

model <- nls(y ~ a * b^x, start = list(a = 1, b = 1))

# plot the data and the fitted curve
ggplot(data.frame(x, y), aes(x, y)) +
  geom_point() +
  geom_smooth(method = "nls", formula = y ~ a * b^x,
              method.args = list(start = list(a = 1, b = 1)),
              se = FALSE)

summary(model)

library(modelr)

# calculate R-squared
rsquare(model, data.frame(x, y))
