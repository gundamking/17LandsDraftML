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

for(z in 1:length(drafts)){
  if(z %% 1000 == 0){
    print(z)
  }
  targ = drafts[z]
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

for(i in 2:length(bins)){
  hits = which(mod_reg$predicted >= bins[i-1] & mod_reg$predicted <= bins[i])
  if(length(hits) > 0){
    counts[i] = length(hits)
    obs[i] = mean(mod_reg$y[hits])
  }
}
ok = which(counts > 5)
plot(bins[ok],obs[ok])
