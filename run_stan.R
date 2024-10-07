#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Set up
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
library(beepr)
library(prioritizr)
library(rstan)
library(sf)

setwd("/Users/madelienelohman/Desktop/geostat_pinon")
#setwd("/Users/madeleinelohman/Desktop/geostat_pinon")

source("data_prep.R")
source("mods/stan_mod_ys.R")


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run model
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~
# Data
#~~~~~~~~~~~~
# coords <- unique(st_coordinates(pd2))
# D <- dist(coords)
# 
# yrs <- sort(unique(pd2$Y2))
# n.years <- length(yrs)
# pd2$yr <- NA
# for(i in 1:n.years){
#   pd2$yr[which(pd2$Y2 == yrs[i])] <- i
# }

#pd2 <- pd2[-c(which(is.na(pd2$yr))),]

data=list("Ns"=nrow(pd2), 
          "y"=pd2$y,
          "D"=as.matrix(D),
          "N"=pd2$N,
          "Nt"=length(unique(pd2$yr)),
          "yr"=pd2$yr,
          "elev" = pd2$elev)

#~~~~~~~~~~~~
# Initial values
#~~~~~~~~~~~~
initf2 <- function(chain_id = 1) {
  list(p=rep(0.95, nrow(pd2)))
}


#~~~~~~~~~~~~
# Run model
#~~~~~~~~~~~~
### Random effect
# par.re <- c("sigma_site", "mu", "beta_elev", "sigma", "eps", "delta", "p")
### Geostatistical
par.geo <- c("rho", "mu", "beta_elev", "sigma", "sigma_site", "delta", "p", "eps")

#options(mc.cores = parallel::detectCores())
m <- stan(model_code=geostat_surv, data=data, 
          chains=2, iter=4000, init=initf2,
          cores=2, pars=par.geo)
beep()


save.image("trees_240924_ys.RData")
