dh <- dashboardHeader(
    title = "Ryan's Betting"
)

## Dashboard Sidebar ===========================================================
sb <- dashboardSidebar(
    width = "250",
    sidebarMenu(
        ## Navigational menu. These are shown in the order listed.
        id = "current_tab", ## This is how to define the tab variable.
        ## style = "position: fixed; overflow: visible;",
        # fluidRow(
        #     div(
        #         # img(src = "ah_logo.png", style = "width:80%"),
        #         style = "text-align:center; padding:10px"
        #     )
        # ),
        menuItem(
            "Today's Best Bets",
            tabName = "best_bets",
            icon = icon("door-open")
        ),
        menuItem(
            "Current Day",
            tabName = "current",
            icon = icon("door-open")
        ),
        menuItem(
            "History",
            tabName = "history",
            icon = icon("door-open")
        ),
        menuItem(
            "History HEAT Model",
            tabName = "history_heat",
            icon = icon("door-open")
        ),
        menuItem(
            "History Charts",
            tabName = "graphs",
            icon = icon("door-open")
        ),
        menuItem(
            "Team Rankings",
            tabName = "rank",
            icon = icon("door-open")
        )
    )
) ## Dashboard Sidebar
db <- dashboardBody(
    tags$script(HTML("$('body').addClass('fixed');")),
    tabItems(
        ## Entries are in the same order as shown in the application.

        ## ---- current day ----
        tabItem(
            tabName = "current",
            fluidRow(
                box(
                    width = 12,
                    reactableOutput("todays_games_table")
                )
            )
        ), ## END current day

        ## ---- todays best bets ----
        tabItem(
            tabName = "best_bets",
            fluidRow(
                box(
                    width = 12,
                    reactableOutput("best_bets_table")
                )
            )
        ), ## END  todays best bets

        ## ---- history ----
        tabItem(
            tabName = "history",
            fluidRow(
                box(
                    width = 12,
                    reactableOutput("all_games_table")
                )
            )
        ), ## END history

        ## ---- history ----
        tabItem(
            tabName = "history_heat",
            fluidRow(
                box(
                    width = 12,
                    reactableOutput("all_games_recent_table")
                )
            )
        ), ## END history

        ## ---- graphs ----
        tabItem(
            tabName = "graphs",
            sidebarLayout(

                # Sidebar panel for inputs ----
                sidebarPanel(
                    dateRangeInput("date",
                                "Date:",
                                start  = "2022-01-23",
                                end    = Sys.Date(),
                                min    = "2022-01-23",
                                max    = Sys.Date()),

                    br(),
                    sliderInput("expected_value", label = h3("Expected Value"), min = 0,
                                max = 2, value = c(0, 2), step=0.01)

                ),

                # Main panel for displaying outputs ----
                mainPanel(
                    fluidRow(
                        valueBoxOutput("roi_box", width = 4),
                        valueBoxOutput("bet_amount_box", width = 4),
                        valueBoxOutput("return_amount_box", width = 4)
                    ),

                    # Output: Tabset w/ plot, summary, and table ----
                    tabsetPanel(type = "tabs",
                                tabPanel("Plot", plotOutput("plot")),
                                tabPanel("Plot Heat Model", plotOutput("plot_recent")),
                                tabPanel("Reliability", plotOutput("reliability_curve")),
                                tabPanel("Table", tableOutput("table")),
                                tabPanel("Table Heat Model", tableOutput("table_recent")),
                                tabPanel("Table NN Model", tableOutput("table_nn"))
                    )
                )
            )
        ), ## END graphs
        ## ---- ranking ----
        tabItem(
            tabName = "rank",
            fluidRow(
                box(
                    width = 12,
                    reactableOutput("team_rankings_table")
                )
            )
        ) ## END Ranking
    ) ## Tab Items
) ## Dashboard Body
ui <- dashboardPage(
    header = dh,
    sidebar = sb,
    body = db,
    skin = "green",
    title = "Ryan's Betting Guide"
)

