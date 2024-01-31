#script title: Tutorial: Tidy Time Series Analysis: Part !
#First created: 1/31/2024
#purpose: the prupose of this scripts is to work through the tidy time series
#blog inorder to get an idea of what timeseries analyses are all about.


#----------------------------
##general start to scripting##
#----------------------------

rm(list = ls())

######github#####
#note, only needed after 90 days from 1/16/2024

#  usethis::create_github_token()  
#  gitcreds::gitcreds_set()

#####check for r updates#####
#note, updateing may take some time so plan accordingly

require(installr)

check.for.updates.R()

#updateR() #only if needed

#######check for package updates#####
#note, updateing may take some time so plan accordingly

old.packages()

update.packages()

#----------------------------
####load packages####
#----------------------------

library(tidyverse)
library(tidyquant)
library(cranlogs)
theme_set(theme_bw(base_size=15))


#----------------------------
####get the data####
#-----------------------------

# Various tidyverse packages corresponding to my stickers :)
pkgs <- c(
  "tidyr", "lubridate", "dplyr", 
  "broom", "tidyquant", "ggplot2", "purrr", 
  "stringr", "knitr"
)

# Get the downloads for the individual packages
tidyverse_downloads <- cran_downloads(
  packages = pkgs, 
  from     = "2017-01-01", 
  to       = "2017-06-30") %>%
  tibble::as_tibble() %>%
  group_by(package)

tidyverse_downloads

#-----------------------------------
######first visualization####
#-----------------------------------

# Visualize the package downloads
tidyverse_downloads %>%
  ggplot(aes(x = date, y = count, color = package)) +
  geom_point() +
  labs(title = "tidyverse packages: Daily downloads", x = "") +
  facet_wrap(~ package, ncol = 3, scale = "free_y") +
  scale_color_tq() +
  theme_tq() +
  theme(legend.position="none")

#------------------------------------
####What kind of grouping f(x)ns are in xts####
#-------------------------------------

# "apply" functions from xts
tq_transmute_fun_options()$xts %>%
  stringr::str_subset("^apply")

#---------------------------------------
####Weekly aggregations####
#---------------------------------------

#notes, aggregating will reduce noise and the effect of outliers

#weekly aggregations with tq_transmutate

?tq_transmute

mean_tidyverse_downloads_w <- tidyverse_downloads %>%
  tq_transmute(
    select     = count,
    mutate_fun = apply.weekly, 
    FUN        = mean,
    na.rm      = TRUE,
    col_rename = "mean_count"
  )
mean_tidyverse_downloads_w

#second graph: graph of the weekly aggegations

mean_tidyverse_downloads_w %>%
  ggplot(aes(x = date, y = mean_count, color = package)) +
  geom_point() +
  geom_smooth(method = "loess") + 
  labs(title = "tidyverse packages: Average daily downloads by week", x = "", 
       y = "Mean Daily Downloads by Week") +
  facet_wrap(~ package, ncol = 3, scale = "free_y") +
  expand_limits(y = 0) + 
  scale_color_tq() +
  theme_tq() +
  theme(legend.position="none")

#------------------------
####custom f(x)ns
#------------------------

###cudtom funciton to get mean, sd, and quantiles

# Custom function to return mean, sd, quantiles
custom_stat_fun <- function(x, na.rm = TRUE, ...) {
  # x     = numeric vector
  # na.rm = boolean, whether or not to remove NA's
  # ...   = additional args passed to quantile
  c(mean    = mean(x, na.rm = na.rm),
    stdev   = sd(x, na.rm = na.rm),
    quantile(x, na.rm = na.rm, ...)) 
}

#test the custome function

# Testing custom_stat_fun
options(digits = 4)
set.seed(3366)
nums  <- c(10 + 1.5*rnorm(10), NA)
probs <- c(0, 0.025, 0.25, 0.5, 0.75, 0.975, 1)
custom_stat_fun(nums, na.rm = TRUE, probs = probs)

####using the custom fxn in tidy aggregations

# Applying the custom function by week
stats_tidyverse_downloads_w <- tidyverse_downloads %>%
  tq_transmute(
    select = count,
    mutate_fun = apply.weekly, 
    FUN = custom_stat_fun,
    na.rm = TRUE,
    probs = probs
  )
stats_tidyverse_downloads_w


#third plot: visualizing the custom function (mean and variation)

stats_tidyverse_downloads_w %>%
  ggplot(aes(x = date, y = `50%`, color = package)) +
  # Ribbon
  geom_ribbon(aes(ymin = `25%`, ymax = `75%`), 
              color = palette_light()[[1]], fill = palette_light()[[1]], alpha = 0.5) +
  # Points
  geom_point() +
  geom_smooth(method = "loess", se = FALSE) + 
  # Aesthetics
  labs(title = "tidyverse packages: Median daily downloads by week", x = "",
       subtitle = "Range of 1st and 3rd quartile to show volatility",
       y = "Median Daily Downloads By Week") +
  facet_wrap(~ package, ncol = 3, scale = "free_y") +
  expand_limits(y = 0) + 
  scale_color_tq(theme = "dark") +
  theme_tq() +
  theme(legend.position="none")


###understanding the relationship between mean and sd

stats_tidyverse_downloads_w %>%
  ggplot(aes(x = stdev, y = mean, color = package)) +
  geom_point() +
  geom_smooth(method = "lm") + 
  labs(title = "tidyverse packages: Mean vs standard deviation of daily downloads by week") +
  facet_wrap(~ package, ncol = 3, scale = "free") +
  scale_color_tq() +
  theme_tq() +
  theme(legend.position="none")
