## SERVER ======================================================================
server <- function(input, output, session) {

## App Body ================================================================
## Roughly in order of how the user will find/interact with things.

    ## Tables ================================================
    theme <- reactableTheme(color = "hsl(0, 0%, 87%)", backgroundColor = "hsl(220, 13%, 18%)",
                            borderColor = "hsl(0, 0%, 22%)", stripedColor = "rgba(255, 255, 255, 0.04)",
                            highlightColor = "rgba(255, 255, 255, 0.06)", inputStyle = list(backgroundColor = "hsl(0, 0%, 24%)"),
                            selectStyle = list(backgroundColor = "hsl(0, 0%, 24%)"),
                            pageButtonHoverStyle = list(backgroundColor = "hsl(0, 0%, 24%)"),
                            pageButtonActiveStyle = list(backgroundColor = "hsl(0, 0%, 28%)"))

    output$todays_games_table <- renderReactable(reactable(todays_games, filterable = TRUE, searchable = TRUE, resizable = TRUE,
                                                        paginationType = "jump", showPageSizeOptions = TRUE, highlight = TRUE,
                                                        showSortable = TRUE, defaultSorted = c("date"), defaultPageSize = 75,
                                                        columns = list(away_team = colDef(name = "Away Team"),
                                                                       away_odds_ml = colDef(name = "Away Team Odds"),
                                                                       exp_win_away = colDef(name = "Away Team Chance of Winning"),
                                                                       exp_value_away = colDef(name = "Expected Value Away", style = function(value) {
                                                                           color <- if (value > 0) {
                                                                               "#008000"
                                                                           } else if (value < 0) {
                                                                               "#e00000"
                                                                           }
                                                                           list(fontWeight = 600, color = color)}),
                                                                       home_team = colDef(name = "Home Team"),
                                                                       home_odds_ml = colDef(name = "Home Team Odds"),
                                                                       exp_win_home = colDef(name = "Home Team Chance of Winning"),
                                                                       exp_value_home = colDef(name = "Expected Value Home", style = function(value) {
                                                                           color <- if (value > 0) {
                                                                               "#008000"
                                                                           } else if (value < 0) {
                                                                               "#e00000"
                                                                           }
                                                                           list(fontWeight = 600, color = color)}),
                                                                       date = colDef(name = "Date")
                                                                      ),
                                                        theme = theme))
    todays_bets_home <- todays_games %>%
        mutate(Team = home_team,  Odds = home_odds_ml, "Win Probability" = exp_win_home * 100, Value = exp_value_home, Location = "Home",
               "Value Heat Model" = exp_value_home_recent, "Win Probability Heat Model" = exp_win_home_recent * 100) %>%
               # "Value NN Model" = exp_value_home_nn, "Win Probability NN Model" = exp_win_home_nn * 100) %>%
        select(Team, game_time, Odds, "Win Probability",Value,Location,"Win Probability Heat Model","Value Heat Model")

    todays_bets_away <- todays_games %>%
        mutate(Team = away_team,  Odds = away_odds_ml, "Win Probability" = exp_win_away * 100, Value = exp_value_away, Location = "Away",
               "Value Heat Model" = exp_value_away_recent, "Win Probability Heat Model" = exp_win_away_recent * 100) %>%
               # "Value NN Model" = exp_value_away_nn, "Win Probability NN Model" = exp_win_away_nn * 100) %>%
        select(Team, game_time, Odds, "Win Probability",Value,Location,"Win Probability Heat Model","Value Heat Model")

    todays_bets <- todays_bets_home %>%
        rbind(todays_bets_away)

    output$best_bets_table <- renderReactable(reactable(todays_bets, filterable = TRUE, searchable = TRUE, resizable = TRUE,
                                                           paginationType = "jump", showPageSizeOptions = TRUE, highlight = TRUE,
                                                           showSortable = TRUE, defaultSorted = c("Value"),defaultSortOrder = "desc",
                                                            defaultPageSize = 75,
                                                           columns = list(Team = colDef(name = "Team"),
                                                                          game_time = colDef(name = "Time"),
                                                                          Odds = colDef(name = "Odds"),
                                                                          Location = colDef(name = "Location"),
                                                                          "Win Probability" = colDef(name = "Win Probability"),
                                                                          Value = colDef(name = "Value", style = function(value) {
                                                                              color <- if (value > 0) {
                                                                                  "#008000"
                                                                              } else if (value < 0) {
                                                                                  "#e00000"
                                                                              }
                                                                              list(fontWeight = 600, color = color)}),
                                                                          "Win Probability Heat Model" = colDef(name = "Win Probability Heat Model"),
                                                                          "Value Heat Model" = colDef(name = "Value Heat Model", style = function(value) {
                                                                              color <- if (value > 0) {
                                                                                  "#008000"
                                                                              } else if (value < 0) {
                                                                                  "#e00000"
                                                                              }
                                                                              list(fontWeight = 600, color = color)})
                                                           ),
                                                           theme = theme))

    df_history_table <- all_games %>% select(away_team,home_team,exp_value_away,exp_value_home, away_odds_ml, home_odds_ml,date,bet,expected_return,return,result) %>% tibble()
    output$all_games_table <- renderReactable(reactable(df_history_table, filterable = TRUE, searchable = TRUE, resizable = TRUE,
                            paginationType = "jump", showPageSizeOptions = TRUE, highlight = TRUE,
                            showSortable = TRUE, defaultSorted = c("date"),
                            columns = list(away_team = colDef(name = "Away Team"),
                                           away_odds_ml = colDef(name = "Away Team Odds"),
                                           exp_value_away = colDef(name = "Expected Value Away"),
                                           home_team = colDef(name = "Home Team"),
                                           home_odds_ml = colDef(name = "Home Team Odds"),
                                           exp_value_home = colDef(name = "Expected Value Home"),
                                           date = colDef(name = "Date"),
                                           bet = colDef(name = "Bet"),
                                           expected_return = colDef(name = "Expected Return", defaultSortOrder = "desc", aggregate = "sum", format = list(aggregated = colFormat(suffix = " (sum)", digits = 3)), cell = function(value) {
                                               if (value >= .2) {
                                                   classes <- "tag num-high"
                                               } else if (value >= 0) {
                                                   classes <- "tag num-med"
                                               } else {
                                                   classes <- "tag num-low"
                                               }
                                               value <- format(value, nsmall = 1)
                                               span(class = classes, value)
                                           }, footer = function(values) {
                                               div(tags$b("Sum: "), round(sum(values), 1))
                                           }),
                                           return = colDef(name = "Actual Return", defaultSortOrder = "desc", aggregate = "sum", format = list(aggregated = colFormat(suffix = " (sum)", digits = 3)), cell = function(value) {
                                               if (value > 0) {
                                                   classes <- "tag num-high"
                                               } else if (value == 0) {
                                                   classes <- "tag num-med"
                                               } else {
                                                   classes <- "tag num-low"
                                               }
                                               value <- format(value, nsmall = 1)
                                               span(class = classes, value)
                                           }, footer = function(values) {
                                               div(tags$b("Sum: "), round(sum(values), 1))
                                           })
                                           , result = colDef(name = "Winning Team")),
                            theme = theme))

    df_history_recent_table <- all_games %>% select(away_team,home_team,exp_value_away_recent,exp_value_home_recent, away_odds_ml, home_odds_ml,date,bet_recent,expected_return_recent,return_recent,result) %>% tibble()
    output$all_games_recent_table <- renderReactable(reactable(df_history_recent_table, filterable = TRUE, searchable = TRUE, resizable = TRUE,
                                                        paginationType = "jump", showPageSizeOptions = TRUE, highlight = TRUE,
                                                        showSortable = TRUE, defaultSorted = c("date"),
                                                        columns = list(away_team = colDef(name = "Away Team"),
                                                                       away_odds_ml = colDef(name = "Away Team Odds"),
                                                                       exp_value_away_recent = colDef(name = "Expected Value Away"),
                                                                       home_team = colDef(name = "Home Team"),
                                                                       home_odds_ml = colDef(name = "Home Team Odds"),
                                                                       exp_value_home_recent = colDef(name = "Expected Value Home"),
                                                                       date = colDef(name = "Date"),
                                                                       bet_recent = colDef(name = "Bet"),
                                                                       return_recent = colDef(name = "Actual Return", defaultSortOrder = "desc"),
                                                                       result = colDef(name = "Winning Team")),
                                                        theme = theme))

    team_rankings <- team_rankings %>% arrange(desc(value)) %>% rowid_to_column("rank")

    output$team_rankings_table <- renderReactable(reactable(team_rankings, filterable = TRUE, searchable = TRUE, resizable = TRUE,
                                                            paginationType = "jump", showPageSizeOptions = TRUE, highlight = TRUE,
                                                            showSortable = TRUE, defaultSorted = c("value"), defaultSortOrder = "desc",
                                                            defaultPageSize = 400,
                                                            columns = list(rank = colDef(name = "Rank", width = 60),
                                                                            Team = colDef(name = "Team", width = 200),
                                                                           Conference = colDef(name = "Conference", width = 200),
                                                                           value = colDef(name = "Strength", width = 120)),
                                                            theme = theme))
    ## PLOTS ================================================
    #creating the valueBoxOutput content
    output$roi_box <- renderValueBox({
        valueBox(
            paste0(formatC(roi(), format = "f", digits = 1), "%")
            ,paste("Return on investment")
            ,icon = icon("stats",lib='glyphicon')
            ,color = "green")
    })

    output$bet_amount_box <- renderValueBox({
        valueBox(
            paste0("$", formatC(bet(), format = "f", digits = 2))
            ,paste("Total amount bet")
            ,icon = icon("stats",lib='glyphicon')
            ,color = "green")
    })

    output$return_amount_box <- renderValueBox({
        valueBox(
            paste0("$", formatC(return_amt(), format = "f", digits = 2))
            ,paste("Total profit")
            ,icon = icon("stats",lib='glyphicon')
            ,color = "green")
    })


    # Generate a plot of the data ----
    # Also uses the inputs to build the plot label. Note that the
    # dependencies on the inputs and the data reactive expression are
    # both tracked, and all expressions are called in the sequence
    # implied by the dependency graph.
    output$plot <- renderPlot({
        all_games %>%
            filter(between(as_date(strptime(date, "%m-%d-%Y")) ,as.Date(as.numeric(input$date[1]),origin="1970-01-01"), as.Date(as.numeric(input$date[2]),origin="1970-01-01"))) %>%
            filter((input$expected_value[1] <= exp_value_away & input$expected_value[2] >= exp_value_away) | (input$expected_value[1] <= exp_value_home & input$expected_value[2] >= exp_value_home)) %>%
            group_by(date) %>%
            summarise(sum = sum(return)) %>%
            mutate(cv = cumsum(sum)) %>%
            add_row(cv = 0, date="01-23-2022") %>%
            ggplot(aes(x = date, y = cv, group = 1)) +
                geom_point() +
                geom_line()
    })

    output$plot_recent <- renderPlot({
        all_games %>%
            filter(between(as_date(strptime(date, "%m-%d-%Y")) ,as.Date(as.numeric(input$date[1]),origin="1970-01-01"), as.Date(as.numeric(input$date[2]),origin="1970-01-01"))) %>%
            filter((input$expected_value[1] <= exp_value_away_recent & input$expected_value[2] >= exp_value_away_recent) | (input$expected_value[1] <= exp_value_home_recent & input$expected_value[2] >= exp_value_home_recent)) %>%
            group_by(date) %>%
            summarise(sum = sum(return_recent)) %>%
            mutate(cv = cumsum(sum)) %>%
            add_row(cv = 0, date="01-23-2022") %>%
            ggplot(aes(x = date, y = cv, group = 1)) +
            geom_point() +
            geom_line()
    })

    all_games_home <- all_games %>%
        filter(result != 0) %>%
        mutate(result = result - 1, `Win Prob` = exp_win_home) %>%
        select(result, `Win Prob`)

    all_games_away <- all_games %>%
        filter(result != 0) %>%
        mutate(result = if_else(result == 2,0,1), `Win Prob` = exp_win_away) %>%
        select(result, `Win Prob`)

    all_games_reliability <- all_games_home %>%
        rbind(all_games_away)

    df_reliability_curve <-
        all_games %>%
        filter(result != 0) %>%
        mutate(result = result -1)

    output$reliability_curve <- renderPlot({
        reliability_diagramm(all_games_reliability$result,all_games_reliability$`Win Prob`, plot_rd=TRUE, bins = 20)
    })

    # Generate a summary of the data ----
    output$summary <- renderPrint({
        summary(all_games %>% group_by(date))
    })

    # Generate an HTML table view of the data ----
    output$table <- renderTable({
        all_games %>%
            filter(between(as_date(strptime(date, "%m-%d-%Y")) ,as.Date(as.numeric(input$date[1]),origin="1970-01-01"), as.Date(as.numeric(input$date[2]),origin="1970-01-01"))) %>%
            filter((input$expected_value[1] <= exp_value_away & input$expected_value[2] >= exp_value_away) | (input$expected_value[1] <= exp_value_home & input$expected_value[2] >= exp_value_home)) %>%
            group_by(date) %>%
            summarise('Bet' = sum(bet), 'Expected Profit' = sum(expected_return),Profit = sum(return),) %>%
            mutate('Cumulative Profit'  = cumsum(Profit), ROI = Profit/Bet)
    })

    output$table_recent <- renderTable({
        all_games %>%
            filter(between(as_date(strptime(date, "%m-%d-%Y")) ,as.Date(as.numeric(input$date[1]),origin="1970-01-01"), as.Date(as.numeric(input$date[2]),origin="1970-01-01"))) %>%
            filter((input$expected_value[1] <= exp_value_away_recent & input$expected_value[2] >= exp_value_away_recent) | (input$expected_value[1] <= exp_value_home_recent & input$expected_value[2] >= exp_value_home_recent)) %>%
            group_by(date) %>%
            summarise('Bet' = sum(bet_recent), 'Expected Profit' = sum(expected_return_recent),Profit = sum(return_recent),) %>%
            mutate('Cumulative Profit'  = cumsum(Profit), ROI = Profit/Bet)
    })

    output$table_nn <- renderTable({
        all_games %>%
            filter(between(as_date(strptime(date, "%m-%d-%Y")) ,as.Date(as.numeric(input$date[1]),origin="1970-01-01"), as.Date(as.numeric(input$date[2]),origin="1970-01-01"))) %>%
            filter((input$expected_value[1] <= exp_value_away_nn & input$expected_value[2] >= exp_value_away_nn) | (input$expected_value[1] <= exp_value_home_nn & input$expected_value[2] >= exp_value_home_nn)) %>%
            group_by(date) %>%
            summarise('Bet' = sum(bet_nn), 'Expected Profit' = sum(expected_return_nn),Profit = sum(return_nn),) %>%
            mutate('Cumulative Profit'  = cumsum(Profit), ROI = Profit/Bet)
    })

    roi <- function() {
        roi_games <- all_games %>%
            filter(between(as_date(strptime(date, "%m-%d-%Y")) ,as.Date(as.numeric(input$date[1]),origin="1970-01-01"), as.Date(as.numeric(input$date[2]),origin="1970-01-01"))) %>%
            filter((input$expected_value[1] <= exp_value_away & input$expected_value[2] >= exp_value_away) | (input$expected_value[1] <= exp_value_home & input$expected_value[2] >= exp_value_home)) %>%
            summarise(sum(return) / sum(bet))

        round(roi_games[[1]] *100, 2)
    }

    return_amt <- function() {
        return <- all_games %>%
            filter(between(as_date(strptime(date, "%m-%d-%Y")) ,as.Date(as.numeric(input$date[1]),origin="1970-01-01"), as.Date(as.numeric(input$date[2]),origin="1970-01-01"))) %>%
            filter((input$expected_value[1] <= exp_value_away & input$expected_value[2] >= exp_value_away) | (input$expected_value[1] <= exp_value_home & input$expected_value[2] >= exp_value_home)) %>%
            summarise(sum(return))

        round(return[[1]], 2)
    }

    bet <- function() {
        bet <- all_games %>%
            filter(between(as_date(strptime(date, "%m-%d-%Y")) ,as.Date(as.numeric(input$date[1]),origin="1970-01-01"), as.Date(as.numeric(input$date[2]),origin="1970-01-01"))) %>%
            filter((input$expected_value[1] <= exp_value_away & input$expected_value[2] >= exp_value_away) | (input$expected_value[1] <= exp_value_home & input$expected_value[2] >= exp_value_home)) %>%
            summarise(sum(bet))

        round(bet[[1]], 2)
    }
}
