geostat_surv="

data{
  int Ns; //This is the number of sites
  int Nt; //This is the number of years
  
  int yr[Ns]; // What year each observation is associated with
  
  vector[Ns] elev; // Elevation
  
  int y[Ns];
  int N[Ns];
  
  // matrix[Ns, Ns] D;
  
  int<lower=0> k ;   //Number of knots                    
  matrix[Ns,k] distPtoK; //distance from plots to knots
  matrix[k,k] distknots; //distance from knots to knots
  vector[k] murand; //Mean of random effect --A vector of zeros
}

parameters{
  
  real<lower=0> sigmaG; //random effect standard deviation growth
  real <lower=0> phiG; ///spatial decay growth
  vector[k] Gk; //random effect for each knot growth 
  
  real beta_elev;
  
  real<lower=0> sigma;
 
  vector[Nt] delta;
  
  real mu;
}

transformed parameters{
  //matrix[Ns, Ns] Sigma_site;
  vector<lower=0, upper=1>[Ns] p;
  vector[Ns] eta;
  
  vector[Ns] Gplot;
  Gplot= (sigmaG*exp(-phiG*distPtoK)) * inverse(sigmaG*exp(-phiG*distknots)) * (Gk); ///Calculate plot random effect from knots
  
  
  for (s in 1:Ns){
      eta[s] = mu + delta[yr[s]] + beta_elev*elev[s] + Gplot[s];
  }
    
    p = inv_logit(eta);
}
  

model{
  //PRIORS 
  sigmaG~normal(0,5);
  Gk~multi_normal(murand,sigmaG*exp(-phiG*distknots));
  
  sigma ~ gamma(1,4);
  
  beta_elev ~ normal(0, 1/2.25);
  
  for(t in 1:Nt){
    delta[t] ~ normal(0, 1/2.25);
  }
  
  mu ~ normal(0, sigma);
  
  
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


