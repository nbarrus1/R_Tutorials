#script title: Tutorial: Tidy Time Series Analysis: Part 3
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
library(timetk)
library(stringr)
library(forcats)

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

# Get data for total CRAN downloads
all_downloads <- cran_downloads(from = "2017-01-01", to = "2017-06-30") %>%
  tibble::as_tibble()


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

# Visualize the downloads
all_downloads %>%
  ggplot(aes(x = date, y = count)) +
  # Data
  geom_point(alpha = 0.5, color = palette_light()[[1]], size = 2) +
  # Aesthetics
  labs(title = "Total CRAN Packages: Daily downloads", x = "",
       subtitle = "2017-01-01 through 2017-06-30",
       caption = "Downloads data courtesy of cranlogs package") +
  scale_y_continuous(labels = scales::comma) +
  theme_tq() +
  theme(legend.position="none")

####--------------------------
####look at the functions####
#-----------------------------

# tidyquant Integrated functions
tq_mutate_fun_options() %>%
  glimpse()

#lag.xts function and how it works through timetk

set.seed(1)
my_time_series_tbl <- tibble(
  date   = seq.Date(ymd("2017-01-01"), length.out = 10, by = "day"),
  value  = 1:10 + rnorm(10)
)
my_time_series_tbl

# Bummer, man!
my_time_series_tbl %>%           
  lag.xts(k = 1:5)

# Success! Got our lags 1 through 5. One problem: no original values
my_time_series_tbl %>%
  timetk::tk_xts(silent = TRUE) %>%
  lag.xts(k = 1:5)

# Convert to xts
my_time_series_xts <- my_time_series_tbl %>%
  tk_xts(silent = TRUE)

# Get original values and lags in xts
my_lagged_time_series_xts <- 
  merge.xts(my_time_series_xts, lag.xts(my_time_series_xts, k = 1:5))

# Convert back to tbl
my_lagged_time_series_xts %>%
  tk_tbl()

####lag.xts through tq_mutate

# This is nice, we didn't need to coerce to xts and it merged for us
my_time_series_tbl %>%
  tq_mutate(
    select     = value,
    mutate_fun = lag.xts,
    k          = 1:5
  )

####-----------------------------
####lags in the tidyverse download data####
##-----------------------------

# Use tq_mutate() to get lags 1:28 using lag.xts()
k <- 1:28
col_names <- paste0("lag_", k)

tidyverse_lags <- tidyverse_downloads %>%
  tq_mutate(
    select     = count,
    mutate_fun = lag.xts,
    k          = 1:28,
    col_rename = col_names
  )
tidyverse_lags


# Calculate the autocorrelations and 95% cutoffs
tidyverse_count_autocorrelations <- tidyverse_lags %>%
  gather(key = "lag", value = "lag_value", -c(package, date, count)) %>%
  mutate(lag = str_sub(lag, start = 5) %>% as.numeric) %>%
  group_by(package, lag) %>%
  summarize(
    cor = cor(x = count, y = lag_value, use = "pairwise.complete.obs"),
    cutoff_upper = 2/(n())^0.5,
    cutoff_lower = -2/(n())^0.5
  )
tidyverse_count_autocorrelations


###visulaized the autocorrlation: ACF Plot

# Visualize the autocorrelations
tidyverse_count_autocorrelations %>%
  ggplot(aes(x = lag, y = cor, color = package, group = package)) +
  # Add horizontal line a y=0
  geom_hline(yintercept = 0) +
  # Plot autocorrelations
  geom_point(size = 2) +
  geom_segment(aes(xend = lag, yend = 0),linewidth = 1) +
  # Add cutoffs
  geom_line(aes(y = cutoff_upper), color = "red", linetype = 2) +
  geom_line(aes(y = cutoff_lower), color = "red", linetype = 2) +
  # Add facets
  facet_wrap(~ package, ncol = 3) +
  # Aesthetics
  expand_limits(y = c(-1, 1)) +
  scale_color_tq() +
  theme_tq() +
  labs(
    title = paste0("Tidyverse ACF Plot: Lags ", rlang::expr_text(k)),
    subtitle = "Appears to be a weekly pattern",
    x = "Lags"
  ) +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

#----------------------------------------
####Testing for autocorrelation trends####
#----------------------------------------

# Get the absolute autocorrelations
tidyverse_absolute_autocorrelations <- tidyverse_count_autocorrelations %>%
  ungroup() %>%
  mutate(
    lag = as_factor(as.character(lag)),
    cor_abs = abs(cor)
  ) %>%
  select(lag, cor_abs) %>%
  group_by(lag) 
tidyverse_absolute_autocorrelations


# Visualize boxplot of absolute autocorrelations

#break point will help us find outliers
break_point <- 1.5*IQR(tidyverse_absolute_autocorrelations$cor_abs) %>% signif(3)


tidyverse_absolute_autocorrelations %>%    
  ggplot(aes(x = fct_reorder(lag, cor_abs, .desc = TRUE) , y = cor_abs)) +
  # Add boxplot
  geom_boxplot(color = palette_light()[[1]]) +
  # Add horizontal line at outlier break point
  geom_hline(yintercept = break_point, color = "red") +
  annotate("text", label = paste0("Outlier Break Point = ", break_point), 
           x = 24.5, y = break_point + .03, color = "red") +
  # Aesthetics
  expand_limits(y = c(0, 1)) +
  theme_tq() +
  labs(
    title = paste0("Absolute Autocorrelations: Lags ", rlang::expr_text(k)),
    subtitle = "Weekly pattern is consistently above outlier break point",
    x = "Lags"
  ) +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1)
  )
