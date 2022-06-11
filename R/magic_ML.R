setwd('/Users/ana_colombo/Downloads/')

x = read.csv('draft_data_public.SNC.PremierDraft.csv')



completed = which(x$event_match_losses ==3 | x$event_match_wins == 7)
pool = grep('pool',colnames(x))
cards = colnames(x)[pool]

drafts = unique(x$draft_id[completed])

targ = drafts[2]
y = x[which(x$draft_id==targ),]

deck = y[1,pool]*0
rate = y$event_match_wins[1]/sum(y$event_match_wins[1],y$event_match_losses[1])

picks = y$pick
picks2 = gsub(' ','.',picks)
picks2 = gsub('-','.',picks2)
picks2 = gsub("'",'.',picks2)
y$pick = picks2

for(i in 1:nrow(y)){
  if(y$pick_maindeck_rate[i]>0){
    hit = grep(y$pick[i],cards)
    deck[hit] = deck[hit] + y$pick_maindeck_rate[i]
  }
}


### populate matrix of decks and vector of win rates
DECKS = vector()
rates = vector()
user_rates = vector()
user_games = vector()

for(z in 1:length(drafts)){
  if(z %% 1000 == 0){
    print(z)
  }
  targ = drafts[z]
  y = x[which(x$draft_id==targ),]
  
  user_rates[z] = unique(y$user_game_win_rate_bucket)
  user_games[z] = unique(y$user_n_games_bucket)
  deck = y[1,pool]*0
  rate = y$event_match_wins[1]/sum(y$event_match_wins[1],y$event_match_losses[1])
  
  picks = y$pick
  picks2 = gsub(' ','.',picks)
  picks2 = gsub('-','.',picks2)
  picks2 = gsub("'",'.',picks2)
  y$pick = picks2
  
  for(i in 1:nrow(y)){
    if(y$pick_maindeck_rate[i]>0){
      hit = grep(y$pick[i],cards)
      deck[hit] = deck[hit] + y$pick_maindeck_rate[i]
    }
  }
  bad = is.na(deck)
  if(sum(bad == TRUE) == 0){
    DECKS = rbind(DECKS,deck)
    rates = c(rates,rate)
  }
}

library(randomForest)
library(pROC)


D = DECKS
labs = as.factor(rates >= 6/9)
mod = randomForest(labs ~., D,ntree=50)
auc(labs,mod$votes[,2])

calibrate.plot(y = labs2,p = mod2$votes[,2])


m = mod2$confusion[,1:10]
for(i in 1:nrow(m)){
  plot(density(m[i,1:10]))
}


results = as.numeric(colnames(m)[1:10])
plot(results,m[i,1:10]/sum(m[i,1:10]))


mod_reg = randomForest(rates ~., D, ntree=20)


preds = mod_reg$predicted
bad = which(is.na(preds))
preds = preds[-bad]

bins = seq(from=0,to=1,by=.01)
counts = vector()
obs = vector()

for(i in 1:length(bins)){
  hits = which(mod_reg$predicted >= bins[i]-.01 & mod_reg$predicted <= bins[i]+.01)
  if(length(hits) > 0){
    counts[i] = length(hits)
    obs[i] = mean(mod_reg$y[hits])
  }
}
ok = which(counts > 5)
sizes = counts[ok]/max(counts[ok])
sizes = log(1/sizes)
#par(mfrow=c(1,3))
plot(xlim=c(0,1),ylim=c(0,1),
     bins[ok],obs[ok],
     xlab='Predicted win rate',ylab='Observed win rate',
     pch=16,main='Predicting Deck Win Rate')
mtext(round(cor(bins[ok],obs[ok])^2,2))
abline(0,1,lty=3)
#abline(h=.66)
res = obs[ok]
p  = bins[ok]
lmmod = lm(res ~ p)
intercept = lmmod$coefficients[1]
slope = lmmod$coefficients[2]
p2 = p*slope + intercept

plot(xlim=c(0,1),ylim=c(0,1),
     p2,obs[ok],
     xlab='Predicted win rate',ylab='Observed win rate',
     pch=16,main='Predicting Deck Win Rate - Adjusted prediction bins')
mtext(round(cor(p2,obs[ok])^2,2))
abline(0,1)
plot(p2,p,xlim=c(0,1),ylim=c(0,1))
abline(0,1)

# Overlay random forest bins vs regression calibrated bins
res = obs[ok]
p  = bins[ok]
lmmod = lm(res ~ p)
intercept = lmmod$coefficients[1]
slope = lmmod$coefficients[2]
p2 = p*slope + intercept

plot(xlim=c(0,1),ylim=c(0,1),
     p,res,
     xlab='Predicted win rate',ylab='Observed win rate',
     pch=16,main='Predicting Deck Win Rate')
abline(0,1,lty=3)
points(p2,res,col=4)
### Predicted deck win rate with sliding window
bins = seq(from=0,to=1,by=.005)
counts = vector()
obs = vector()

for(i in 1:length(bins)){
  hits = which(mod_reg$predicted >= bins[i]-.005 & mod_reg$predicted <= bins[i]+.005)
  if(length(hits) > 0){
    counts[i] = length(hits)
    obs[i] = mean(mod_reg$y[hits])
  }
}
ok = which(counts > 50)
sizes = counts[ok]/max(counts[ok])
sizes = log(1/sizes)
plot(xlim=c(0,1),ylim=c(0,1),
     bins[ok],obs[ok],
     xlab='Predicted win rate',ylab='Observed win rate',
     pch=16,main='Predicting Deck Win Rate')
mtext(round(cor(bins[ok],obs[ok])^2,2))
abline(0,1,lty=3)

res = obs[ok]
p  = bins[ok]
lmmod = lm(res ~ p)
intercept = lmmod$coefficients[1]
slope = lmmod$coefficients[2]
p2 = p*slope + intercept

plot(xlim=c(0,1),ylim=c(0,1),
     p,res,
     xlab='Predicted win rate',ylab='Observed win rate',
     pch=16,main='Predicting Deck Win Rate')
abline(0,1,lty=3)
points(p2,res,col=4)

library(mlbench)

d <- cbind(p,res)
#op <- par(mfrow=c(1,2))
plot(d, asp=1,xlim=c(0,1),ylim=c(0,1))
abline(0,1)
angle <- pi/9
M <- matrix( c(cos(angle), -sin(angle), sin(angle), cos(angle)), 2, 2 )
d2 = as.matrix(d) %*% M
d2[,1]=d2[,1]+.3
points(d2, col="red",xlim=c(0,1),ylim=c(0,1))



####
write.csv(D,file='SNC_Decks.csv')
write.csv(rates,file='SNC_win_rates.csv')

bad = which(is.na(user_rates))
N = cbind(user_games,user_rates)
rats=rates[-bad]
N2=N[-bad,]

modx = randomForest(rats ~., N2)

D2 = cbind(D,N)[-bad,]
modxy = randomForest(rats ~., D2,ntree=50)

preds = modx$predicted
bad = which(is.na(preds))
#preds = preds[-bad]

bins = seq(from=0,to=1,by=.01)
counts = vector()
obsp = vector()

for(i in 2:length(bins)){
  hits = which(modx$predicted >= bins[i-1] & modx$predicted <= bins[i])
  if(length(hits) > 0){
    counts[i] = length(hits)
    obsp[i] = mean(modxy$y[hits])
  } else {
    obsp[i] = 0
    counts[i] = 0
  }
}
ok = which(counts > 5)
sizes = counts[ok]/max(counts[ok])
sizes = log(1/sizes)
plot(xlim=c(0,1),ylim=c(0,1),
     bins[ok],obs[ok],
     xlab='Predicted win rate',ylab='Observed win rate',
     pch=16)


###############
counts = vector()
obs = vector()

for(i in 2:length(bins)){
  hits = which(user_rates >= bins[i-1] & user_rates <= bins[i])
  if(length(hits) > 0){
    counts[i] = length(hits)
    obs[i] = mean(modx$y[hits])
  }
}
ok = which(counts > 5)
sizes = counts[ok]/max(counts[ok])
sizes = log(1/sizes)
plot(xlim=c(0,1),ylim=c(0,1),
     bins[ok],obs[ok],
     xlab='Predicted win rate',ylab='Observed win rate',
     pch=16)

################ can you use a deck list to predict the user win rate?
labs = as.factor(user_rates[-bad] )
mod_cat = randomForest(labs ~., D[-bad,],ntree=30)
auc(labs,mod_cat$votes[,2])
    
bins = seq(from=0,to=1,by=.01)
counts = vector()
obs = vector()
devs = vector()

for(i in 1:length(bins)){
  hits = which(mod_cat$predicted >= bins[i]-.01 & mod_cat$predicted <= bins[i]+.01)
  if(length(hits) > 0){
    counts[i] = length(hits)
    obs[i] = mean(mod_cat$y[hits])
    devs[i] = sd(mod_cat$y[hits])
  }
}
ok = which(counts > 5)
sizes = counts[ok]/max(counts[ok])
sizes = log(1/sizes)
plot(xlim=c(0,1),ylim=c(0,1),
     bins[ok],obs[ok],
     xlab='Predicted win rate',ylab='Observed win rate',
     pch=16,main='Predicting User Win Rates')
mtext(round(cor(bins[ok],obs[ok])^2,2))
abline(0,1,lty=3)

res = obs[ok]
p  = bins[ok]
lmmod = lm(res ~ p)
intercept = lmmod$coefficients[1]
slope = lmmod$coefficients[2]
p2 = p*slope + intercept

plot(xlim=c(0,1),ylim=c(0,1),
     p,res,
     xlab='Predicted win rate',ylab='Observed win rate',
     pch=16,main='Predicting Deck Win Rate')
abline(0,1,lty=3)
points(p2,res,col=4)
#abline(h=.66)


byclass = vector()
h = sort(unique(rats))
l = vector()
for(i in 1:length(h)){
  hits = which(rats == h[i])
  l[i] = length(hits)
  byclass[i] = mean(preds[hits])
}  
  
wins = c(0,1,2,3,4,5,6,7,7,7)
losses = c(3,3,3,3,3,3,3,2,1,0)
rates_to_wins = wins/(wins+losses)


estimates = vector()
confband = vector()
predicted1 = vector()
for(k in 1:length(bins)){
  hits = which(mod_reg$predicted >= bins[k-1] & mod_reg$predicted <= bins[k])
  if(length(hits) > 5){
    predicted1[k] = mean(mod_reg$predicted[hits])
    seen = mod_reg$y[hits]
    success = 0
    failure = 0
    for(i in 1:length(seen)){
      m = which(rates_to_wins == seen[i])
      success = success + wins[m]
      failure = failure + losses[m]
    }
    z=prop.test(success,success+failure,conf.level = .95)
    estimates[k] = z$estimate
    confband[k] = z$conf.int[[2]]-z$conf.int[[1]]
  } else {
    predicted1[k]=0
    estimates[k]=0
    confband[k]=9
  }

}
good= which(estimates > 0 & confband < .1)
plot(predicted1[good],estimates[good],xlim=c(0,1),ylim=c(0,1))
points(predicted1[good],estimates[good],col=4)

### distribution of wins given a win rate
wins = c(0,1,2,3,4,5,6,7,7,7)
losses = c(3,3,3,3,3,3,3,2,1,0)
outcomemat = expand.grid(c(1,0),c(1,0),c(1,0),c(1,0),c(0,1),c(0,1),c(0,1),c(1,0),c(1,0),c(1,0))
games = wins[i] + losses[i]
smallout = unique(outcomemat[,1:games])
if(wins[i] < 7){
  good= which(rowSums(smallout)==wins[i] & smallout[,ncol(smallout)]==0)
}
if(wins[i] == 7){
  good= which(rowSums(smallout)==wins[i] & smallout[,ncol(smallout)]==1)
}

winrate = .49
lossrate = 1 - winrate
probs = vector()
for(i in 1:length(losses)){
  games = wins[i] + losses[i]
  smallout = unique(outcomemat[,1:games])
  if(wins[i] < 7){
    good= which(rowSums(smallout)==wins[i] & smallout[,ncol(smallout)]==0)
  }
  if(wins[i] == 7){
    good= which(rowSums(smallout)==wins[i] & smallout[,ncol(smallout)]==1)
  }
  prob = winrate^wins[i]*lossrate^losses[i]*length(good)
  probs[i] = prob
}
barplot(probs)
mtext(sum(probs))
