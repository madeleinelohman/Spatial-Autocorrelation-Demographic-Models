library(beepr)
library(prioritizr)
library(rstan)
library(gstat)
library(sf)

post <- rstan::extract(m)
m@model_pars


#~~~~~~~~~~~~~~~~~~~
# Convergence
#~~~~~~~~~~~~~~~~~~~
conv <- summary(m)$summary
summary(conv[,10])
hist(conv[,10])

which(conv > 1.1, arr.ind=T)

#~~~~~~~~~~~~~~~~~~~
# Bayes p
#~~~~~~~~~~~~~~~~~~~
length(which(rowMeans(post$y_new) > mean(pd2$y))) / ni
length(which(apply(post$y_new, 1, sd) > sd(pd2$y))) / ni
length(which(apply(post$y_new, 1, quantile, probs=0.25) < quantile(pd2$y, probs=0.25))) / ni
length(which(apply(post$y_new, 1, quantile, probs=0.75) > quantile(pd2$y, probs=0.75))) / ni

#~~~~~~~~~~~~~~~~~~~
# p
#~~~~~~~~~~~~~~~~~~~
hist(post$p)

#~~~~~~~~~~~~~~~~~~~
# sigma space
#~~~~~~~~~~~~~~~~~~~
hist(post$sigma_site)

#~~~~~~~~~~~~~~~~~~~
# sigma
#~~~~~~~~~~~~~~~~~~~
hist(post$sigma)

#~~~~~~~~~~~~~~~~~~~
# delta
#~~~~~~~~~~~~~~~~~~~
for(i in 1:n.years){
  hist(post$delta[,i], main=paste("Year =", yrs[i]))
  Sys.sleep(0.4)
}


#~~~~~~~~~~~~~~~~~~~
# mu
#~~~~~~~~~~~~~~~~~~~
hist(post$mu)
hist(plogis(post$mu))


#~~~~~~~~~~~~~~~~~~~
# beta
#~~~~~~~~~~~~~~~~~~~
hist(post$beta_elev)
summary(post$beta_elev)
plot(post$beta_elev, type="l")


#~~~~~~~~~~~~~~~~~~~
# Predicted data
#~~~~~~~~~~~~~~~~~~~
hist(post$y_new)
pred <- post$y_new
sse <- NA
for(s in 1:ncol(pred)){
  sse[s] <- sum((pred[,s] - pd2$y[s])^2)
}
summary(sse)
hist(sse)

#~~~~~~~~~~~~~~~~~~~
# Starting plots
#~~~~~~~~~~~~~~~~~~~
res <- data.frame(plot=pd2$plot, 
                  mean=colMeans(post$p), 
                  t(apply(post$p, 2, quantile, probs=c(0.025, .975))),
                  st_coordinates(pd2))
colnames(res) <- c("plot", "mean", "q2.5", "q97.5", "X", "Y")
res$sse <- sse
res$pred <- colMeans(pred)
res <- st_as_sf(res, coords=c("X", "Y"), remove=F)
st_crs(res) <- st_crs(pd2)
res$CRI_width <- res$q97.5 - res$q2.5


ggplot(res, aes(color = mean)) +
  geom_sf(data=us.want, fill=NA, color="grey50", size=0.25) +
  geom_sf() + 
  theme_classic()

ggplot(res, aes(color = CRI_width)) +
  geom_sf(data=us.want, fill=NA, color="grey50", size=0.25) +
  geom_sf() + 
  theme_classic()


ggplot(res, aes(color = sse)) +
  geom_sf(data=us.want, fill=NA, color="grey50", size=0.25) +
  geom_sf() + 
  theme_classic()







library(gstat)

res$resid <- pd2$y - res$pred

v <- variogram(resid ~ 1, res)
plot(v)








