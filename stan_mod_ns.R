geostat_surv="

data{
  int Ns; //This is the number of sites
  int Nt; //This is the number of years
  
  int yr[Ns]; // What year each observation is associated with
  
  vector[Ns] elev; // Elevation
  
  int y[Ns];
  int N[Ns];
  
}

parameters{
  
  real<lower=0> sigma_site;
  real<lower=0> sigma;
  
  real beta_elev;
 
  vector[Ns] eps;
  vector[Nt] delta;
  
  real mu;
}

transformed parameters{
  vector<lower=0, upper=1>[Ns] p;
  vector[Ns] eta;
  
  for (s in 1:Ns){
      eta[s] = mu + eps[s] + delta[yr[s]] + beta_elev*elev[s];
  }
    
    p = inv_logit(eta);
}

model{
  //PRIORS 
  sigma_site ~ gamma(1,4);
  sigma ~ gamma(1,4);
  
  beta_elev ~ normal(0, 1/2.25);
  
  for(t in 1:Nt){
    delta[t] ~ normal(0, 1/2.25);
  }
  
  mu ~ normal(0, sigma);
  
  for(s in 1:Ns){
    eps[s] ~ normal(0, sigma_site);
  }
  
  //LIKELIHOOD
    for (s in 1:Ns){
      y[s] ~ binomial(N[s], p[s]);
    }
}
generated quantities {
  vector[Ns] y_new;
  for (s in 1:Ns)
    y_new[s] = binomial_rng(N[s], p[s]);
}

"


