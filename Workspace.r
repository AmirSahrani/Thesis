library(rstan)
library(bridgesampling)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Should be ran in a loop using 1 observation each loop, since it's log scale output should be added up to get the final log likelihood
binomial_test <- function(x, n , theta0, alpha, beta, truncated = TRUE) {

  # log marginal likelihood under the null
  log_marglik_h0 <- sum(dbinom(x = x, size = n, prob = theta0, log = TRUE))
  # return(log_marglik_h0)

  if (truncated) {
    # numerical integration when the parameter is truncted above theta0
    log_marglik_h1 <- log(integrate(
      f = function(theta) {
        exp(
          dbinom(x, n, theta, log = TRUE) + # log likelihood
            dbeta(theta, alpha, beta, log = TRUE) - # log prior
            pbeta(theta0, alpha, beta, lower.tail = FALSE, log.p = TRUE)) # log standardizing constant for the prior
      },
      lower = theta0,
      upper = 1
    )$value)
  } else {
    # conjugate result otherwise
    log_marglik_h1 <- extraDistr::dbbinom(x, n, alpha, beta, log = TRUE)
  }

  # compute on log scale
  logBF_10 <- log_marglik_h1 - log_marglik_h0

  # return the exponentiated Bayes factor
  return(exp(logBF_10))
}

# rstan doesn't seem to work with the every version of R, these install commands seemed to fix my issue
# install.packages("StanHeaders", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
# install.packages("rstan", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))


Real_data= read.delim("decoded.csv", header = FALSE, sep = ",")
Real_data$V1
log_marglik_0 <- 
data <- list(
  N = length(Real_data),
  y = Real_data,
  Alpha = 5069,
  Beta = 4930,
  lower_bound = 0.5,
  theta0 = 0.5
)

model_simple <- stan_model(file = "simple.stan")
fit_simple <- sampling(model_simple, data = data)
marglik_2 <- bridge_sampler(fit_simple)

#Alternatively this is the analytical solution
log_likelihood <- 0
for (i in 1:length(coinflips)){
  log_likelihood <- log_likelihood + binomial_test(coinflips[i], 1,0.5,5069,4930,truncated = FALSE)

}

data_hierarchical <- list(
  N = length(coinflips),
  K = 6,
  y = coinflips,
  map_k = people,
  theta0 = 0.5,
  Alpha = 5069,
  Beta = 4930,
  mu_k = 0,
  lower_bound = 0.5,
  sigma_mean = 0,
  sigma_std = 0.01
)


model_hierchical <- stan_model(file = "hierarchical_person.stan")
fitPerson <- sampling(model_hierchical, data = data_hierarchical)
marglikPerson <- bridge_sampler(fitPerson)


data_hierarchical_coin <- list(
  N = length(coinflips),
  K = 10,
  y = coinflips,
  map_k = people,
  map_c = coins,
  theta0 = 0.5,
  Alpha = 5069,
  Beta = 4930,
  mu_k = 0,
  sigma_k = 0.01,
  mu_c = 0,
  sigma_c = 0.01
)


model_Coin <- stan_model(file = "Hieractical_coin.stan")
fitCoin <- sampling(model_Coin, data = data_hierarchical_coin)
marglikCoin  <- bridge_sampler(fitCoin)
samples = c(100,200,300,400,500,600,700,800,900,1000)
errorrate = c(0.005,0.01,0.015,0.02,0.025,0.03,0.035,0.04)
error_matrix = matrix(0, nrow = length(samples), ncol = length(errorsrate), dimnames = list(samples,errorsrate)) 
est_means = c()
est_intervals_lower = c()
est_intervals_upper = c()
all_means = c()
all_intervals_lower = c()
all_intervals_upper = c()
counter = 0
model_error <- stan_model(file = "simple.stan")
for (i in 1:length(samples)){
    for (j in 1:length(errorrate)){
      counter <- counter + 1 
      for (x in 1:1){
      errors = rbinom(1500000,1,errorrate[j])
      errors_sample = errors[c(sample(1:length(errors), samples[i]), replace = FALSE)]

      ## ERROR ESTIMATION

      data_error <- list(
        N = length(errors_sample),
        y = errors_sample,
        Alpha = 1,
        Beta = 1,
        lower_bound = 0,
        theta0 = 0.00000001 # any error would be infinitely more likely than theta0 = 0
      )
      # fit_error <- sampling(model_error, data = data_error)
      all_means[x] <- (1+sum(errors_sample))/(1+sum(errors_sample)+1+samples[i]-sum(errors_sample))
      all_intervals_lower[x] <- qbeta(0.025, 1+sum(errors_sample), 1+samples[i]-sum(errors_sample))
      all_intervals_upper[x] <- qbeta(0.975, 1+sum(errors_sample), 1+samples[i]-sum(errors_sample))
    }  
    est_means[counter] <- mean(all_means)
    est_intervals_lower[counter] <- mean(all_intervals_lower)
    est_intervals_upper[counter] <- mean(all_intervals_upper)
  }
}

# est_means_trunc=est_means[1:88]
# est_intervals_lower_trunc=est_intervals_lower[1:88]
# est_intervals_upper_trunc=est_intervals_upper[1:88]

#Alternatively this is the analytical solution
# binomial_test(sum(errors), length(errors),0.001,2,100,truncated = FALSE)
split_means = split(est_means, rep(1:8,length(samples)))
split_intervals_lower = split(est_intervals_lower, rep(1:8,length(samples)))
split_intervals_upper = split(est_intervals_upper, rep(1:8,length(samples)))
layout(matrix(c(1,2,3,4,5,6,7,8), nrow = 2, ncol = 4, byrow = TRUE))
for (i in 1:8){
  plot(split_means[[i]],xaxt = "n", main = paste("Error rate:", errorrate[i]),ylim = c(0,0.05))
  abline(h = errorrate[i], col = "blue")
  axis(1, at = 1:11, labels = samples[1:11])
  points(split_intervals_lower[[i]], col = "red", pch = 4)
  points(split_intervals_upper[[i]], col = "red", pch = 4)
  for (j in 1:length(split_intervals_lower[[i]])){
    if (split_intervals_upper[[i]][j] - split_intervals_lower[[i]][j] < 0.04){
    segments(j,split_intervals_lower[[i]][j], j,split_intervals_upper[[i]][j], col = "red")
    }
  }

}

coinflips = rbinom(10000,1,0.51)
# for (i in 1:length(coinflips)){
#   if (coinflips[i] == 1)
#     errors[i] = rbinom(1,1,0.6)
# }
coinflips = coinflips + errors
coinflips = ifelse(coinflips == 2, 0, coinflips)
data_errorBias <- list(
  N = length(errors),
  K = 2,
  y = coinflips,
  map_k = errors+1,
  Alpha = 2,
  Beta = 100,
  mu_k = 0.001,
  theta0 = 0.001,
  lower_bound = 0,
  sigma_mean = 0.001,
  sigma_std = 0.01
)



model_errorBias <- stan_model(file = "hierarchical_person.stan")
fit_errorBias <- sampling(model_errorBias, data = data_errorBias)
fit_errorBias
marglik_Bias <- bridge_sampler(fit_errorBias)
