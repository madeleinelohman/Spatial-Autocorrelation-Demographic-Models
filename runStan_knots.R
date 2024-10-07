#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Set up
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
library(beepr)
library(prioritizr)
library(rstan)
library(sf)
library(fields)

setwd("/Users/madelienelohman/Desktop/geostat_pinon")
#setwd("/Users/madeleinelohman/Desktop/geostat_pinon")

source("data_prep.R")
source("mods/knotsStan.R")


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run model
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~
# Data
#~~~~~~~~~~~~
latlong <- cbind(pd2$long[match(td2$plot,pd2$plot)]/100000,
                 pd2$lat[match(td2$plot,pd2$plot)]/100000) 

latlong <- cbind(pd2$long/100000,
                 pd2$lat/100000) 

knots <- cover.design(latlong, nd=200, num.nn = 1000)[,1:2]
distknots <- as.matrix(dist(knots, diag=T, upper=T))#### Distance among knots
distPtoK <- as.matrix(dist(rbind(latlong,knots), diag=T, upper=T))[-c((length(latlong[,1])+1):length(rbind(latlong,knots)[,1])),-c(1:length(latlong[,1]))]  ###Distance from plots (P) to Knots (K) 



data=list("Ns"=nrow(pd2), 
          "y"=pd2$y,
          "N"=pd2$N,
          "Nt"=length(unique(pd2$yr)),
          "yr"=pd2$yr,
          "elev" = pd2$elev,
          "murand"=rep(0,length(knots[,1])),
          "k"=length(knots[,1]),
          "distknots"=distknots,
          "distPtoK"=distPtoK)

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
#par.geo <- c("rho", "mu", "beta_elev", "sigma", "sigma_site", "delta", "p", "eps")

#options(mc.cores = parallel::detectCores())

ni = 6000 

m <- stan(model_code=geostat_surv, data=data, 
          chains=3, iter=ni, init=initf2,
          cores=3)#, pars=par.geo)
beep()


save.image("trees_041024_ys.RData")
