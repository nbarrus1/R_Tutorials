#script title: Tutorial: Tidy Time Series Analysis: Part 2
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
  labs(title = "tidyverse packages: Daily downloads", x = "",
       subtitle = "2017-01-01 through 2017-06-30",
       caption = "Downloads data courtesy of cranlogs package") +
  facet_wrap(~ package, ncol = 3, scale = "free_y") +
  scale_color_tq() +
  theme_tq() +
  theme(legend.position="none")


#--------------------------------------
######Look at what rolling functions are available in zoo and TTR packages#####
####and look at tq_mutate####
#--------------------------------------
# "roll" functions from zoo
tq_mutate_fun_options()$zoo %>%
  stringr::str_subset("^roll")

# "run" functions from TTR
tq_mutate_fun_options()$TTR %>%
  stringr::str_subset("^run")

# Condensed function options... lot's of 'em
tq_mutate_fun_options() %>%
  str()

#-------------------------------
###rolling averages####
#--------------------------------


#use 30 day rolling mean and 90 which is "fast" and "slow" can help with 
#understanding momentum and if trends are likely to continue

# Rolling mean
tidyverse_downloads_rollmean <- tidyverse_downloads %>%
  tq_mutate(
    # tq_mutate args
    select     = count,
    mutate_fun = rollapply, 
    # rollapply args
    width      = 30,
    align      = "right",
    FUN        = mean,
    # mean args
    na.rm      = TRUE,
    # tq_mutate args
    col_rename = "mean_30"
  ) %>%
  tq_mutate(
    # tq_mutate args
    select     = count,
    mutate_fun = rollapply,
    # rollapply args
    width      = 90,
    align      = "right",
    FUN        = mean,
    # mean args
    na.rm      = TRUE,
    # tq_mutate args
    col_rename = "mean_90"
  )

###figure 2 momentum with points

# ggplot
tidyverse_downloads_rollmean %>%
  ggplot(aes(x = date, y = count, color = package)) +
  # Data
  geom_point(alpha = 0.1) +
  geom_line(aes(y = mean_30), color = palette_light()[[1]], linewidth = 1) +
  geom_line(aes(y = mean_90), color = palette_light()[[2]], linewidth = 1) +
  facet_wrap(~ package, ncol = 3, scale = "free_y") +
  # Aesthetics
  labs(title = "tidyverse packages: Daily Downloads", x = "",
       subtitle = "30 and 90 Day Moving Average") +
  scale_color_tq() +
  theme_tq() +
  theme(legend.position="none")

####figure 3 momentum without points

tidyverse_downloads_rollmean %>%
  ggplot(aes(x = date, color = package)) +
  # Data
  # geom_point(alpha = 0.5) +  # Drop "count" from plots
  geom_line(aes(y = mean_30), color = palette_light()[[1]], linetype = 1, size = 1) +
  geom_line(aes(y = mean_90), color = palette_light()[[2]], linetype = 1, size = 1) +
  facet_wrap(~ package, ncol = 3, scale = "free_y") +
  # Aesthetics
  labs(title = "tidyverse packages: Daily downloads", x = "", y = "",
       subtitle = "Zoomed In: 30 and 90 Day Moving Average") +
  scale_color_tq() +
  theme_tq() +
  theme(legend.position="none")


#--------------------------------------------
####custom functions###
#--------------------------------------------

#custom function that gets more than just mean

# Custom function to return mean, sd, 95% conf interval
custom_stat_fun_2 <- function(x, na.rm = TRUE) {
  # x     = numeric vector
  # na.rm = boolean, whether or not to remove NA's
  
  m  <- mean(x, na.rm = na.rm)
  s  <- sd(x, na.rm = na.rm)
  hi <- m + 2*s
  lo <- m - 2*s
  
  ret <- c(mean = m, stdev = s, hi.95 = hi, lo.95 = lo) 
  return(ret)
}

# Roll apply using custom stat function
tidyverse_downloads_rollstats <- tidyverse_downloads %>%
  tq_mutate(
    select     = count,
    mutate_fun = rollapply, 
    # rollapply args
    width      = 30,
    align      = "right",
    by.column  = FALSE,
    FUN        = custom_stat_fun_2,
    # FUN args
    na.rm      = TRUE
  )
tidyverse_downloads_rollstats



####figure 4 looking at the data with the variablility


tidyverse_downloads_rollstats %>%
  ggplot(aes(x = date, color = package)) +
  # Data
  geom_point(aes(y = count), color = "grey40", alpha = 0.5) +
  geom_ribbon(aes(ymin = lo.95, ymax = hi.95), alpha = 0.4) +
  geom_point(aes(y = mean), linetype = 3, size = 1, alpha = 0.5) +
  facet_wrap(~ package, ncol = 3, scale = "free_y") +
  # Aesthetics
  labs(title = "tidyverse packages: Volatility and Trend", x = "",
       subtitle = "30-Day Moving Average with 95% Confidence Interval Bands (+/-2 Standard Deviations)") +
  scale_color_tq(theme = "light") +
  theme_tq() +
  theme(legend.position="none")
