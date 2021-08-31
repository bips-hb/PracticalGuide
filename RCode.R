################################################################################
### This is the R code from                                                  ###
### "A practical guide to causal discovery with cohort data"                 ###
### by Ryan M. Andrews, Ronja Foraita, Vanessa Didelez and Janine Witte      ###
################################################################################

### Load packages and data #####################################################

## Note that rtools40 needs to be installed on your computer for installing tpc
## and micd from GitHub.

## install required packages
#install.packages("pcalg")
#install.packages("bnlearn")
#devtools::install_github("bips-hb/tpc")
#devtools::install_github("bips-hb/micd")

## load required packages
library(bnlearn)
library(pcalg)
library(micd)
library(tpc)

## load cohort data and create cross-sectional version of the dataset
data("dat_cohort")
dat_cross <- dat_cohort[ ,1:14]

## load discretized data and create cross-sectional version of the dataset
data("dat_cohort_dis")
dat_cross_dis <- dat_cohort_dis[ ,1:14]


### Mixed data: pcalg ##########################################################

pcalg_fit_mix <- pc(suffStat = dat_cross, indepTest = mixCItest, alpha = 0.01,
                    labels = colnames(dat_cross), u2pd="relaxed",
                    skel.method = "stable", maj.rule = TRUE, solve.confl = TRUE)
mygraph <- function(pcgraph){
  g <- as.bn(pcgraph, check.cycles = FALSE)
  graphviz.plot(g, shape = "ellipse")
}
mygraph(pcalg_fit_mix)


### Mixed data: pcalg (discretized) ############################################

suffStat <- list(dm = dat_cross_dis, adaptDF = FALSE)
pcalg_fit_dis <- pc(suffStat = suffStat, indepTest = disCItest, alpha = 0.01,
                    labels = colnames(dat_cross_dis), u2pd = "relaxed",
                    skel.method = "stable", maj.rule = TRUE, solve.confl = TRUE)
mygraph(pcalg_fit_dis)


### Mixed data: bnlearn ########################################################

bnlearn_fit_mix <- pc.stable(dat_cross, test = "mi-cg", alpha = 0.01)
graphviz.plot(bnlearn_fit_mix, shape = "ellipse")


### Time-ordered data: pcalg ###################################################

## specify tiers: (1) country, sex; (2) FTO gene; (3) birth weight;
## (4) all t0 variables; (5) all t1 variables, (6) all t2 variables
tiers <- rep( c(1,2,3,4,5,6), times = c(2,1,1,10,10,10) )

pcalg_fit <- tpc(suffStat = dat_cohort, indepTest = mixCItest, alpha = 0.01, 
                 labels = colnames(dat_cohort), maj.rule = TRUE,
                 tiers = tiers,
                 context.all = c("country", "sex"),
                 context.tier = c("age_t0", "age_t1", "age_t2"))
mygraph(pcalg_fit)


### Time-ordered data: bnlearn #################################################

bl1 <- tiers2blacklist(split(names(dat_cohort), tiers))
bl2 <- data.frame(from = names(dat_cohort),
                  to = rep( c("age_t0","age_t1","age_t2"), each = 34 ))
bl3 <- data.frame(from = c("country","sex"), to = c("sex","country"))
bl <- rbind(bl1, bl2, bl3)
wl1 <- data.frame(from = rep( c("country","sex"), each = 29 ),
                  to = names(dat_cohort)[-c(1,2,5,15,25)])
wl2 <- data.frame(from = "age_t0",
                  to = c("bmi_t0","bodyfat_t0","fiber_t0", "media_devices_t0",
                       "media_time_t0","mvpa_t0","sugar_t0","wellbeing_t0"))
wl3 <- data.frame(from = "age_t1",
                  to = c("bmi_t1","bodyfat_t1","fiber_t1","media_devices_t1",
                       "media_time_t1","mvpa_t1","sugar_t1","wellbeing_t1"))
wl4 <- data.frame(from = "age_t2",
                  to = c("bmi_t2","bodyfat_t2","fiber_t2","media_devices_t2",
                       "media_time_t2","mvpa_t2","sugar_t2","wellbeing_t2"))
wl <- rbind(wl1, wl2, wl3, wl4)

# causal discovery
bnlearn_fit <- pc.stable(dat_cohort, alpha = 0.01,
                         blacklist = bl, whitelist = wl)
graphviz.plot(bnlearn_fit, shape = "ellipse")


### Missing data: pcalg (test-wise deletion) ###################################

## load incomplete data and create cross-sectional version of the dataset
data("dat_miss")
dat_miss_cross <- dat_miss[ ,1:14]

pcalg_fit_twd <- tpc(suffStat = dat_miss_cross, indepTest = mixCItwd,
                     alpha = 0.01, labels = colnames(dat_miss_cross),
                     maj.rule = TRUE,
                     tiers = tiers[1:14],
                     context.all = c("country", "sex"),
                     context.tier = c("age_t0"))

mygraph(pcalg_fit_twd)


### Missing data: pcalg (multiple imputation) ##################################

## install required package
# install.packages("mice")

## load required package
library(mice)

## generate multiply imputed data using random forest imputation
mi_object <- mice(dat_miss_cross, m = 10, method = "rf", print = FALSE)
mi_dat <- complete(mi_object, action = "all")

## apply PC
pcalg_fit_mi <- tpc(suffStat = mi_dat, indepTest = mixMItest,
                    alpha = 0.01, labels = colnames(dat_miss_cross),
                    maj.rule = TRUE,
                    tiers = tiers[1:14],
                    context.all = c("country", "sex"),
                    context.tier = c("age_t0"))

mygraph(pcalg_fit_mi)


### Missing data: bnlearn ######################################################

bl1 <- tiers2blacklist(split(names(dat_miss_cross), tiers[1:14]))
bl2 <- data.frame(from = names(dat_miss_cross), to = "age_t0")
bl3 <- data.frame(from = c("country","sex"), to = c("sex","country"))
bl <- rbind(bl1, bl2, bl3)
wl1 <- data.frame(from = rep( c("country","sex"), each = 11 ),
                  to = names(dat_miss_cross)[-c(1,2,5)])
wl2 <- data.frame(from = "age_t0",
                  to = c("bmi_t0","bodyfat_t0","fiber_t0", "media_devices_t0",
                       "media_time_t0","mvpa_t0","sugar_t0","wellbeing_t0"))
wl <- rbind(wl1, wl2)

bnlearn_fit_twd <- pc.stable(dat_miss_cross, alpha = 0.01,
                             blacklist = bl, whitelist = wl)
graphviz.plot(bnlearn_fit_twd, shape = "ellipse")
