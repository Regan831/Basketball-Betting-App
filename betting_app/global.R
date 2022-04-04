#Created by Ryan Egan 1/27/22
## LIBS ========================================================================
library(shiny)
library(tidyverse)
library(shinydashboard)
library(reactable)
library(dplyr)
library(rsconnect)
library(lubridate)
library(reticulate)
library(CalibratR)
# install_tensorflow(version = "2.4.1")
# virtualenv_create(envname = "py_dev",python = "python3")
# virtualenv_install(envname = "py_dev",c('pandas', 'numpy','sklearn'))

## SOURCE ======================================================================
## If you have any functions not in global.R or server.R, source it here.
source_python("./python_functions.py")

## REMOTE DATA =================================================================
current_year <- '2021-22'
team_avg <- read_csv("team_data.csv")
#
# team_avg %>%
#   filter(year == "2021-22") %>%
#   summarise_if(is_numeric, "mean") %>%
#   mutate(year = '2021-22', power_conf = 0) %>%
#   write_csv("avg_team_22.csv")

#NEW DAY STUFF

get_todays_odds()
# record_day_results()
# read_csv("team_data.csv") %>%
# filter(year == current_year) %>%
# mutate(value = round(map_dbl(Team, predict_wrapper),4)) %>%
# select(Team, Conference, value) %>%
# write_csv("team_rankings.csv")

todays_games <- read_csv("today_odds.csv")
all_games <- read_csv("df_bet_results.csv")
team_rankings <- read_csv("team_rankings.csv")


## VARS ========================================================================
## Primary reference table for the application filters. This needs to be a table
## so we can keep leverage the relationships between columns in server.R to
## update filter options from user input.

table_decorator <-
  JS(
    "function(settings, json) {",
    "$(this.api().table().header()).css({'background-color': '#5e3294', 'color': '#FFFFFF', 'text-align': 'center'});",
    "}"
  )
