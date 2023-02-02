library(rstan)
library(bridgesampling)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
# rstan doesn't seem to work with the every version of R, these install commands seemed to fix my issue
# install.packages("StanHeaders", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
# install.packages("rstan", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))


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

# Simulate audit to get intervals
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


data_coin = read.csv("data/merged.csv")

# log marginal likelihood under the null
log_marglik_0 <- sum(dbinom(x = data_coin$succes, size = 1, prob = 0.5, log = TRUE))

data <- list(
  N = length(data_coin$succes),
  y = data_coin$succes,
  Alpha = 5069,
  Beta = 4931,
  lower_bound = 0.5,
  theta0 = 0.5
)

data_hierarchical_person <- list(
  N = nrow(data_coin),
  K = length(unique(data_coin$factor_person)),
  y = data_coin$succes,
  map_k = data_coin$factor_person,
  theta0 = 0.5,
  Alpha = 5069,
  Beta = 4930,
  lower_bound = 0.5
)
data_hierarchical_just_coin <- list(
  N = nrow(data_coin),
  K = length(unique(data_coin$factor_coin)),
  y = data_coin$succes,
  map_k = data_coin$factor_coin,
  theta0 = 0.5,
  Alpha = 5069,
  Beta = 4930,
  lower_bound = 0.5
)

data_hierarchical_coin <- list(
  N = nrow(data_coin),
  K = length(unique(data_coin$factor_person)),
  C = length(unique(data_coin$factor_coin)),
  y = data_coin$succes,
  map_k = data_coin$factor_person,
  map_c = data_coin$factor_coin,
  theta0 = 0.5,
  Alpha = 5069,
  Beta = 4930,
  lower_bound = 0.5
)
# Stan models
# Simple model
model_simple <- stan_model(file = "models/simple.stan")
fit_simple <- sampling(model_simple, data = data, iter = 10000)
marglikSimple <- bridge_sampler(fit_simple)
# Hierarchical model with just coin
model_hierchical <- stan_model(file = "models/hierarchical_person.stan")
fitjustcoin <- sampling(model_hierchical, data = data_hierarchical_just_coin, iter = 10000)
marglikCoin <- bridge_sampler(fitjustcoin)
# Hierarchical model with person
model_hierchical <- stan_model(file = "models/hierarchical_person.stan")
fitPerson <- sampling(model_hierchical, data = data_hierarchical_person)
marglikPerson <- bridge_sampler(fitPerson)
# Hierarchical model with person and coin
model_Coin <- stan_model(file = "models/hierarchical_coin.stan")
fitCoin <- sampling(model_Coin, data = data_hierarchical_coin, iter = 15000, warmup = 5000)
marglikCombined  <- bridge_sampler(fitCoin)

# Compare the models
exp(marglikSimple$logml - log_marglik_0)
exp(marglikSimple$logml - marglikCombined)
exp(marglikCombined$logml - marglikPerson$logml)
exp(marglikCombined$logml - marglikPerson$logml)



auditdata <- read.csv("data/auditdata_fixed.csv")
# log marginal likelihood under the null
marglik_audit <- sum(dbinom(x = auditdata$error, size = 1, prob = 0.0001, log = TRUE))

data_error <- list(
  N = nrow(auditdata),
  y = auditdata$errors,
  Alpha = 1,
  Beta = 1,
  lower_bound = 0,
  theta0 = 0.00000001 # any error would be infinitely more likely than theta0 = 0
)

data_error <- list(
  y     = c(auditdata$errors),
  map_k = c(auditdata$succes)+1,
  N     = nrow(auditdata),
  K     = length(unique(auditdata$succes)),
  theta0 = 0.0001,
  Alpha = 1,
  Beta = 1,
  lower_bound = 0
)

data_person <- list(
  y     = c(auditdata$errors),
  map_k = c(auditdata$person_factor),
  N     = nrow(auditdata),
  K     = length(unique(auditdata$person_factor)),
  theta0 = 0.0001,
  Alpha = 1,
  Beta = 1,
  lower_bound = 0
)
# Stan models
# Simple model
model_simple <- stan_model(file = "models/simple.stan")
fit_simple <- sampling(model_simple, data = data_error, iter = 10000) 
marglik_audit_simple <- bridge_sampler(fit_simple)

# Hierarchical model with just success
model_error <- stan_model(file = "models/hierarchical_person.stan")
fit_error <- sampling(model_error, data = data_error, iter = 20000)
marglik_audit_error <- bridge_sampler(fit_error)

# Hierarchical model with person
model_person <- stan_model(file = "models/hierarchical_person.stan")
fit_person <- sampling(model_person, data = data_person, iter = 10000)
marglik_audit_person <- bridge_sampler(fit_person)

# Compare the models
exp(marglikaudit - marglik_audit_simple$logml)
exp(marglik_audit_simple$logml - marglik_audit_error$logml)
exp(marglik_audit_simple$logml - marglik_audit_person$logml)
