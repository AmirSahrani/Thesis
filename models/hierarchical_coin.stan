data {
  int<lower=0> N; // number of observations
  int<lower=0> K; // number of tossers
  int<lower=0> C; // number of coins
  int y[N];       // 1 = success, 0 = failure
  int map_c[N];
  int map_k[N];   // mapping from tossers to outcomes
  int Alpha;
  int Beta;
  real theta0;
  real lower_bound;
}
parameters {
  real<lower=lower_bound, upper=1> theta; // probability of success
  real<lower=0> sigma_gamma_k;    // standard deviation of the distribution of tossers (on logistic scale), must be positive
  real<lower=0> sigma_gamma_c;
  real gamma_k[K];                // difference of each individual tosser from the probability of success (on logistic scale)
  real gamma_c[C];
}
model {
  // prior distribution on the overal probability of success
  target += beta_lpdf(theta | Alpha, Beta) - beta_lccdf(theta0 | Alpha, Beta);

  // prior distribution on the standard deviation of the distribution of tossers -- the smaller the value, the more similar the tossers are
  // we would probably not expect to see large differences from the overall distribution
  target += normal_lpdf(sigma_gamma_k | 0, 0.01) - normal_lccdf(0 | 0, 0.01);

  target += normal_lpdf(sigma_gamma_c | 0, 0.01) - normal_lccdf(0 | 0, 0.01);

  // hierarchical prior distribution on difference of each individual tosser from the probability of success (on logistic scale)
  // we assume that the tossers are centered around the overall probability of success (therefore the distribution is centered at 0)
  for(k in 1:K){
    target += normal_lpdf(gamma_k[k] | 0, sigma_gamma_k);
  }

  for(c in 1:C){
    target += normal_lpdf(gamma_c[c] | 0, sigma_gamma_c);
  }

  for(n in 1:N){
    // contruct the tosser specific parameter, i.e., the overall probability of succcess + deviation (including the transformations)
    real logit_mu_k_c = logit(theta) + gamma_k[map_k[n]] + gamma_c[map_c[n]];

    // a product (on log scale) of the Bernoulli trials, including the back transformation
    target += bernoulli_lpmf(y[n] | inv_logit(logit_mu_k_c));
  }
}
