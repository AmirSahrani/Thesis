data {
  int<lower=0> N; // number of observations
  int y[N];       // 1 = success, 0 = failure
  int Alpha;
  int Beta;
  real lower_bound;
  real theta0;
}
parameters {
  real<lower=lower_bound, upper=1> theta; // probability of success
}
model {
   // note the distribution is standardizing constant for truncation above 0.5
  target += beta_lpdf(theta | Alpha, Beta) - beta_lccdf(theta0 | Alpha, Beta);
  
  for(n in 1:N){
    // a product (on log scale) of the Bernoulli trials
    target += bernoulli_lpmf(y[n] | theta);
  }
}
