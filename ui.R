library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(DT)
library(visNetwork)  # For dynamic schema visualization

source("default_schemas.R")
source("visualization.R")

dashboardPage(
  dashboardHeader(
    title = "Database Design Dashboard"
  ),

  dashboardSidebar(
    sidebarMenu(
      id = "sidebar",
      menuItem("Default Schemas", tabName = "default_schemas", icon = icon("layer-group")),
      menuItem("Add Tables", tabName = "manage_tables", icon = icon("table")),
      menuItem("Manage Relationships", tabName = "relationship", icon = icon("arrows-up-down-left-right")),
      menuItem("Export Design", tabName = "export_design", icon = icon("file-export"))
      )
  ),
  
  dashboardBody(
    tabItems(
      # Tab 1: Default Schemas with Dynamic Visualization
      tabItem(tabName = "default_schemas",
              fluidRow(
                box(
                  title = "Manual Table Creation",
                  width = 12,  # Full horizontal width
                  status = "warning",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  div(
                    style = "text-align: center;",
                    p("If you want to create tables manually,  visit the 'Add Tables' tab."),
                    actionButton("go_to_create_tables", "Add Tables", icon = icon("arrow-right"))
                  )
                  )
                ),
              fluidRow(
              box(
                title = "Select Default Schemas",
                width = 12,
                solidHeader = TRUE,  # Adds a solid header to the box
                status = "success",  # Changes the header color (options: primary, success, info, warning, danger)
                div(
                  selectInput(
                    "schema_choice",
                    "Choose Schema",
                    choices = names(schemas)
                  )
                )
              )),
              verbatimTextOutput("schema_description") %>% 
                tagAppendAttributes(style = "white-space: pre-wrap; font-size: 14px; max-width: 100%; word-wrap: break-word; border: 5px solid black;"),  # Schema description
              h3("Schema Diagram"),
              visNetworkOutput("schema_visualization"),  # Dynamic schema visualization
              h3("Tables Preview"),
              DTOutput("schema_tables_preview"),  # Table preview
              h3("Relationships Preview"),
              DTOutput("schema_relationships_preview"),  # Relationships preview
              actionButton("load_schema", "Load Schema")
      ),
      
      # Tab 2: Manage Tables
      tabItem(tabName = "manage_tables",
              h2("Add Tables"),
              box(
                title = "Create New Table",
                width = 12,
                solidHeader = TRUE,
                actionButton(inputId = "init_table", label = "Create New Table", icon = icon("right-to-bracket")),
                uiOutput("dynamic_ui"),
                actionButton(inputId = "commit_table", label = "Load Table to Database", icon = icon("check")),
                status = "info"
              ),
              tags$div(
                style = "max-width: 1200px; margin: auto;",
                DTOutput("table_list")
              )
              
      ),
      
      # Tab 3: Manage Relationships
      tabItem(
        tabName = "relationship",
        h2("Define Relationships"),
        selectInput("table1", "Select Table 1", choices = NULL),
        selectInput("table2", "Select Table 2", choices = NULL),
        actionButton("add_relationship", "Add Relationship"),
        DTOutput("relationships_list"),
        visualizationUI("add_tables_vis")
      ),
      
      # Tab 4: Export Design
      tabItem(tabName = "export_design",
              h2("Export Design"),
              visualizationUI("export_design_vis"),
              actionButton("export_sql","Export SQL Query"),
              verbatimTextOutput("export_preview"),
                
              actionButton("export_design", "Exportc")
                # Placeholder for SQL preview
      )
    )
  )
)

