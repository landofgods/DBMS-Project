  library(shiny)
  library(visNetwork)
  source("visualization.R")
  
  server <- function(input, output, session) {
    setwd("C:\\Users\\Dell\\OneDrive\\Desktop\\Programming\\R Programs\\DBMSapp")
    ## Direct to Create Tables
    observeEvent(input$go_to_create_tables, {
      updateTabItems(session, "sidebar", selected = "manage_tables")  # Use the correct ID and tabName
    })
    
# ----------------------------------------------------------------------------
    # Server logic for visNetwork visualization
    observeEvent(input$schema_choice, {
      selected_schema <- input$schema_choice
      if (!is.null(selected_schema)) {
        schema <- schemas[[selected_schema]]
        
        # Validation: Check if schema structure is valid
        if (!all(c("description", "tables", "relationships") %in% names(schema))) {
          showNotification("Selected schema is incomplete or invalid.", type = "error")
          return()
        }
        
        # Render Schema Description
        output$schema_description <- renderText(schema$description)
        
        nodes <- data.frame(
          id = names(schema$tables),
          label = names(schema$tables),
          title = sapply(schema$tables, function(cols) paste(cols, collapse = "<br>")), # Tooltip content
          shape = "box",
          stringsAsFactors = FALSE
        )
        # Prepare Edges (Relationships)
        edges <- data.frame(
          from = sapply(schema$relationships, function(rel) rel[1]),
          to = sapply(schema$relationships, function(rel) rel[2]),
          arrows = "to",
          label = sapply(schema$relationships, function(rel) rel[3]), # Relationship type (e.g., "1-to-1", "1-to-Many")
          color = sapply(schema$relationships, function(rel) ifelse(rel[3] == "1-to-1", "blue", "green")), # Color coding
          stringsAsFactors = FALSE
        )
        
        output$schema_visualization <- renderVisNetwork({
          visNetwork(nodes, edges) %>%
            visEdges(arrows = "to") %>%
            visNodes(font = list(size = 18), title = nodes$title) %>% # Enable tooltips
            visLayout(randomSeed = 123) %>% 
            visEdges(label = edges$label, color = edges$color) # Show relationship types
        })
      
  
# ----------------------------------------------------------------------------
        # Render Tables Preview
        tables <- data.frame(
          Table_Name = names(schema$tables),
          Columns = sapply(schema$tables, function(cols) paste(cols, collapse = ", ")),
          stringsAsFactors = FALSE
        )
        output$schema_tables_preview <- renderDT(tables, options = list(paging = FALSE, searching = FALSE))
        
        # Render Relationships Preview
        rels <- data.frame(
          Table1 = sapply(schema$relationships, function(rel) rel[1]),
          Table2 = sapply(schema$relationships, function(rel) rel[2]),
          stringsAsFactors = FALSE
        )
        output$schema_relationships_preview <- renderDT(rels, options = list(paging = FALSE, searching = FALSE))
      }
    })
    
    # Reactive values for dynamic table and relationship management
    db_tables <- reactiveVal(data.frame(
      Table_Name = character(),        # Name of the table
      Attributes = I(list()),          # List of attributes (column details)
      Primary_Key = character(),       # Single primary key (column name)
      Primary_Key_Type = character(),  # Type of the primary key
      Primary_Key_Size = numeric(),    # Size of the primary key
      Foreign_Keys = I(list()),        # List of foreign key definitions
      stringsAsFactors = FALSE
    ))
    relationships <- reactiveVal(data.frame(Table1 = character(), Table2 = character(), stringsAsFactors = FALSE))
    
    db_tables_flag <- reactive({
      !is.null(db_tables()) && nrow(db_tables()) > 0
    })
    
    # Global reactive list of all key names (primary and foreign)
    all_keys <- reactiveVal(c())  # Starts as an empty character vector
    
    # Validation: Ensure schemas are loaded correctly
    if (!exists("schemas") || !is.list(schemas)) {
      stop("Default schemas not found or improperly loaded.")
    }
    
    
# ----------------------------------------------------------------------------
    # Event: Add Table
    observeEvent(input$add_table, {
      new_table <- input$table_name
      if (new_table != "") {
        current_tables <- db_tables()
        if (!(new_table %in% current_tables$Table_Name)) {
          updated_tables <- rbind(current_tables, data.frame(Table_Name = new_table, stringsAsFactors = FALSE))
          db_tables(updated_tables)
          showNotification("Table added successfully",type = "default") # Properly called within a reactive context
        } else {
          showNotification("Table already exists!", type = "error")
        }
      } else {
        showNotification("Table name cannot be empty.",type = "error")
      }
      
      updateTextInput(session, "table_name", value = "")
    })
    
# ---------------------------------------------------------------------
    # Reactive value to track button clicks
    ui_initialized <- reactiveVal(FALSE)
    
    # Creating a temporary table..
    temp_table <- reactiveVal(data.frame(
      Table_Name = "",
      Attributes = I(list(list())),
      Primary_Key = "",
      Primary_Key_Type = "INTEGER",
      Primary_Key_Size = 10,
      Foreign_Keys = I(list(list())),
      stringsAsFactors = FALSE
    ))
    
    observeEvent(input$init_table, {
      # Set the flag to TRUE
      ui_initialized(TRUE)
      
      # Initialize the temp_table with default values
      temp_table(data.frame(
        Table_Name = "",
        Attributes = I(list(list())),
        Primary_Key = "",
        Primary_Key_Type = "INTEGER",
        Primary_Key_Size = 10,
        Foreign_Keys = I(list(list())),
        stringsAsFactors = FALSE
      ))
      
      # Notify the user that the temporary table is initialized
      showNotification("Create Table Tab opened!", type = "message")
    })
    
    
    output$dynamic_ui <- renderUI({
      # Render UI elements only after the button is clicked
      if (!ui_initialized()) {
        return()
      }
      
      tagList(
        textInput("table_name", "Enter Table Name"),
        uiOutput("primary_key_ui"),
        uiOutput("foreign_key_ui"),
        uiOutput("attribute_key_ui")
      )
    })
    observeEvent(input$table_name, {
      req(input$table_name)  # Ensure input is available
      
      # Access the reactive value and update `Table_Name`
      current_temp <- temp_table()
      current_temp$Table_Name <- input$table_name  # Modify the data frame
      temp_table(current_temp)  # Save the updated data frame back to temp_table
      
            print(current_temp$Table_Name)
      
      # Check if the table name already exists in db_tables
      if (input$table_name %in% db_tables()$Table_Name) {
        showNotification("Table name already exists in the database!", type = "error")
        return()  # Exit if duplicate name is found
      }
      })
    
      
      output$primary_key_ui <- renderUI({
        current_temp <- temp_table()
        
        tagList(
          h3(paste("Define Primary Key for Table:", current_temp$Table_Name)),
          textInput(
            "primary_key_attribute",
            "Name for Column",value = "key"
          ),
          selectInput(
            "primary_key_type",
            "Select Data Type",
            choices = c("INTEGER", "VARCHAR", "DATE", "BOOLEAN")  # Options for data types
          ),
          numericInput(
            "primary_key_size",
            "Specify Size (if applicable)",
            value = 10,
            min = 1
          ),
          actionButton("add_primary_key", "Add Primary Key", icon = icon("key"))
        )
      }) 
      
      output$foreign_key_ui <- renderUI({
        current_temp <- temp_table()
        
        if (!db_tables_flag()) {
          # If no referenced tables are available, show a message or placeholder
          return(div(h4("No tables available, So cannot create foreign key!.",style = "color: red;padding:10px;")))
        }
        
        tagList(
          h3(paste("Define Foreign Key for Table:", current_temp$Table_Name)),
          textInput(
            "foreign_key_attribute",
            "Name for Column",
            value = "key"  # Default value for the column name
          ),
          selectInput(
            "referenced_table",
            "Referenced Table",
            choices = db_tables()$Table_Name  # Use db_tables for reference tables
          ),
          uiOutput("referenced_column_ui"),  # Dynamically render column choices
          selectInput(
            "foreign_key_type",
            "Select Data Type",
            choices = c("INTEGER", "VARCHAR", "DATE", "BOOLEAN")  # Valid data types
          ),
          numericInput(
            "foreign_key_size",
            "Specify Size (if applicable)",
            value = 10,  # Default size
            min = 1      # Minimum allowed size
          ),
          actionButton("add_foreign_key", "Add Foreign Key", icon = icon("link"))  # Action to add foreign key
        )
      })
    
    observeEvent(input$add_primary_key, {
      current_temp <- temp_table()
     
      # Validate that no primary key exists yet
      if (current_temp$Primary_Key != "") {
        showNotification("A primary key is already defined for this table!", type = "error")
        return()  # Prevent duplicate primary keys
      }
      
      # Check for duplicate key name in global list
      if (input$primary_key_attribute %in% all_keys()) {
        showNotification("Duplicate key name! Key already exists in table.", type = "error")
        return()
      }
      
      # Update primary key details in temp_table
      current_temp$Primary_Key <- input$primary_key_attribute
      current_temp$Primary_Key_Type <- input$primary_key_type
      current_temp$Primary_Key_Size <- input$primary_key_size
      temp_table(current_temp)  # Save changes back to temp_table

      # Update the global key list
      all_keys(c(all_keys(), input$primary_key_attribute))
      
      showNotification("Primary Key added successfully to temporary table!", type = "message")
      
    })
    
    output$attribute_key_ui <- renderUI({
      current_temp <- temp_table()
     
      tagList(
        h3(paste("Define Attribute Key for Table:", current_temp$Table_Name)),
        textInput(
          "attribute_key_name",
          "Name for Column",value = "key"
        ),
        selectInput(
          "attribute_key_type",
          "Select Data Type",
          choices = c("INTEGER", "VARCHAR", "DATE", "BOOLEAN")  # Options for data types
        ),
        numericInput(
          "attribute_key_size",
          "Specify Size (if applicable)",
          value = 10,
          min = 1
        ),
        actionButton("add_attribute_key", "Add Attribute Key", icon = icon("plus"))
      )
    })
    
    # Server logic for attribute key
    observeEvent(input$add_attribute_key, {
      current_temp <- temp_table()
      
      # Validate user input
      if (input$attribute_key_name == "") {
        showNotification("Attribute name cannot be empty!", type = "error")
        return()
      }
      if (input$attribute_key_type == "") {
        showNotification("Attribute type cannot be empty!", type = "error")
        return()
      }
      
      # Check for duplicate key name in global list
      if (input$attribute_key_name %in% all_keys()) {
        showNotification("Duplicate key name! Key already exists in table.", type = "error")
        return()
      }
      
      # Create the new attribute key
      new_attribute_key <- list(
        name = input$attribute_key_name,
        type = input$attribute_key_type,
        size = input$attribute_key_size
      )
      
      # Append the attribute key to temp_table's Attributes
      current_temp$Attributes[[1]] <- append(current_temp$Attributes[[1]], list(new_attribute_key))
      temp_table(current_temp)  # Save changes back to temp_table
      
      
      # Update the global key list
      all_keys(c(all_keys(), input$attribute_key_name))
      
      
      showNotification("Attribute Key added successfully!", type = "message")
    })
    
    
    
    observeEvent(input$add_foreign_key, {
      current_temp <- temp_table()
      
      # Create a new foreign key entry
      new_foreign_key <- list(
        name = input$foreign_key_attribute,
        type = input$foreign_key_type,
        size = input$foreign_key_size,
        references = list(
          table = input$referenced_table,
          column = input$referenced_column
        )
      )
      
      # Append the foreign key to temp_table
      current_temp$Foreign_Keys[[1]] <- append(current_temp$Foreign_Keys[[1]], list(new_foreign_key))
      temp_table(current_temp)  # Save changes back to temp_table
      observeEvent(input$add_foreign_key, {
        current_temp <- temp_table()
        
        # Check for duplicate key name
        if (input$foreign_key_attribute %in% all_keys()) {
          showNotification("Duplicate key name! Key already exists in table.", type = "error")
          return()
        }
        
        # Create a new foreign key
        new_foreign_key <- list(
          name = input$foreign_key_attribute,
          type = input$foreign_key_type,
          size = input$foreign_key_size,
          references = list(
            table = input$referenced_table,
            column = input$referenced_column
          )
        )
        
        # Add the foreign key to temp_table
        current_temp$Foreign_Keys[[1]] <- append(current_temp$Foreign_Keys[[1]], list(new_foreign_key))
        temp_table(current_temp)
        
        # Update the global key list
        all_keys(c(all_keys(), input$foreign_key_attribute))
        
        showNotification("Foreign Key added successfully!", type = "message")
      })
      showNotification("Foreign Key added successfully to temporary table!", type = "message")
    })
    
    output$referenced_column_ui <- renderUI({
      # Check if db_tables() is empty
      if (is.null(db_tables()) || nrow(db_tables()) == 0) {
        return()
      }
      
      ref_table <- input$referenced_table
      
      # Get the attributes for the referenced table
      attributes_data <- db_tables()[db_tables()$Table_Name == ref_table, "Attributes"][[1]]
      
      # Extract only the attribute names
      ref_attributes <- sapply(attributes_data, function(attr) attr$name)
      
      # Get the primary key
      ref_primary_key <- db_tables()[db_tables()$Table_Name == ref_table, "Primary_Key"]
      
      # Combine attributes and primary key for selection
      ref_choices <- list(
        Attributes = ref_attributes,
        PrimaryKey = paste0("PK: ", ref_primary_key)
      )
      
      selectInput(
        "referenced_column",
        "Referenced Column",
        choices = ref_choices
      )
    })
    
    output$attribute_display <- renderUI({
      current_temp <- temp_table()
      # If no attributes, display a message
      # Generate a list of attribute details
      attribute_list <- lapply(current_temp$Attributes[[1]], function(attr) {
        div(paste(attr$name, "-", attr$type, ifelse(attr$type == "VARCHAR", paste0("(", attr$size, ")"), "")))
      })
      # Render the list as a UI element
      do.call(tagList, attribute_list)
    })
 # ----------------------------------------------------------------------------------
    #Load Table to Database

    observeEvent(input$commit_table, {
      current_temp <- temp_table()
      current_tables <- db_tables()
      
      # Validate that the table is fully configured
      if (current_temp$Table_Name == "") {
        showNotification("Cannot commit: Table name is missing!", type = "error")
        return()
      }
      if (length(current_temp$Attributes[[1]]) == 0) {
        showNotification("Cannot commit: No attributes defined for the table!", type = "error")
        return()
      }
      if (current_temp$Primary_Key == "") {
        showNotification("Cannot commit: Primary Key is not defined!", type = "error")
        return()
      }
      
      # Check if the table already exists in the database
      if (current_temp$Table_Name %in% current_tables$Table_Name) {
        showNotification("Cannot commit: Duplicate table name!", type = "error")
        return()
      }
      
      # Commit the table to db_tables
      updated_tables <- rbind(current_tables, current_temp)
      db_tables(updated_tables)
      
      # Reset the temp_table
      temp_table(data.frame(
        Table_Name = "",
        Attributes = I(list(list())),
        Primary_Key = "",
        Primary_Key_Type = "INTEGER",
        Primary_Key_Size = 10,
        Foreign_Keys = I(list(list())),
        stringsAsFactors = FALSE
      ))
      
      showNotification("Table committed successfully!", type = "message")
      ui_initialized(FALSE)
      
      # Clear the global key list after commit
      all_keys(c())  # Reset all_keys to an empty list
      
    })
    
    # Display Tables
    output$table_list <- renderDT({
      tables <- db_tables()
      
     
      
      # Render DataTable
      datatable(
        tables,
        options = list(
          paging = FALSE,
          searching = FALSE,
          scroll = TRUE
        )
      )
    })
    
    
    
# ----------------------------------------------------------------------------
    # Update Dropdown Choices for Relationships
    observe({
      table_names <- db_tables()$Table_Name
      updateSelectInput(session, "table1", choices = table_names)
      updateSelectInput(session, "table2", choices = table_names)
    })
    
    # Event: Add Relationship
    observeEvent(input$add_relationship, {
      table1 <- input$table1
      table2 <- input$table2
      if (table1 != table2 && table1 != "" && table2 != "") {
        current_relationships <- relationships()
        new_relationship <- data.frame(Table1 = table1, Table2 = table2, stringsAsFactors = FALSE)
        updated_relationships <- rbind(current_relationships, new_relationship)
        relationships(updated_relationships)
        showNotification("Relation added successfully!", type = "default") # Properly called within a reactive context
      } else {
        showNotification("Please select two different tables.", type = "error")
      }
    })
    
    # Display Relationships
    output$relationships_list <- renderDT({
      relationships()
    })
    
    
# ----------------------------------------------------------------------------    
    # Event: Export SQL
    observeEvent(input$export_sql, {
      tables <- db_tables()
      sql_statements <- c()
      
      for (i in 1:nrow(tables)) {
        table <- tables$Table_Name[i]
        attributes <- tables$Attributes[[i]]
        pk <- tables$Primary_Key[i]
        pk_type <- tables$Primary_Key_Type[i]
        pk_size <- tables$Primary_Key_Size[i]
        fks <- tables$Foreign_Keys[[i]]
        
        # Define columns
        column_lines <- sapply(attributes, function(attr) {
          paste0(attr$name, " ", attr$type, ifelse(attr$type == "VARCHAR", paste0("(", attr$size, ")"), ""))
        })
        
        # Add primary key as a column definition + primary key constraint
        if (!is.null(pk) && pk != "") {
          # Define the primary key column with type and size
          pk_column_line <- paste0(pk, " ", pk_type, ifelse(pk_type == "VARCHAR", paste0("(", pk_size, ")"), ""))
          
          # Add the PRIMARY KEY constraint
          pk_constraint_line <- paste0("PRIMARY KEY (", pk, ")")
        } else {
          pk_column_line <- ""
          pk_constraint_line <- ""
        }
        
        # Add foreign keys
        fk_lines <- sapply(fks, function(fk) {
          paste0("FOREIGN KEY (", fk$name, ") REFERENCES ", fk$references$table, "(", fk$references$column, ")")
        })
        
        # Combine SQL
        table_sql <- paste0(
          "CREATE TABLE ", table, " (\n",
          paste(c(column_lines, pk_column_line, pk_constraint_line, fk_lines), collapse = ",\n"),
          "\n);"
        )
        
        sql_statements <- c(sql_statements, table_sql)
      }
      
      # Preview the generated SQL
      output$export_preview <- renderText({ paste(sql_statements, collapse = "\n\n") })
    })
    
    ### CREATE RSQLITE .DB FILE
    library(RSQLite)
    observeEvent(input$export_design, {
      conn <- dbConnect(SQLite(), "personalized_database.db")
      # Dynamically create tables
      tables1 <- db_tables()
      rels <- relationships()
      
      for (i in 1:nrow(tables1)) {
        table_name <- tables1$Table_Name[i]
        create_statement <- paste0("CREATE TABLE ", table_name, " (id INTEGER PRIMARY KEY);")
        dbExecute(conn, create_statement)
      }
      
      dbDisconnect(conn)
      showNotification("Database file created successfully!", type = "default")
    })
    
    # Event: Schema Selection
    observeEvent(input$schema_choice, {
      selected_schema <- input$schema_choice
      if (!is.null(selected_schema)) {
        schema <- schemas[[selected_schema]]
        
        # Validation: Check if schema structure is valid
        if (!all(c("description", "tables", "relationships") %in% names(schema))) {
          showNotification("Selected schema is incomplete or invalid.", type = "message")
          return()
        }
        
        # Render Schema Description
        output$schema_description <- renderText(schema$description)
        
        # Render Tables Preview
        tables <- data.frame(
          Table_Name = names(schema$tables),
          Columns = sapply(schema$tables, function(cols) paste(cols, collapse = ", ")),
          stringsAsFactors = FALSE
        )
        output$schema_tables_preview <- renderDT(tables, options = list(paging = FALSE, searching = FALSE))
        
        # Render Relationships Preview
        rels <- data.frame(
          Table1 = sapply(schema$relationships, function(rel) rel[1]),
          Table2 = sapply(schema$relationships, function(rel) rel[2]),
          stringsAsFactors = FALSE
        )
        output$schema_relationships_preview <- renderDT(rels, options = list(paging = FALSE, searching = FALSE))
      }
    })
    
    observeEvent(input$load_schema, {
      selected_schema <- input$schema_choice
      if (!is.null(selected_schema)) {
        schema <- schemas[[selected_schema]]
        
        # Validate schema structure
        if (!all(c("description", "tables", "relationships") %in% names(schema))) {
          showNotification("Selected schema is incomplete or invalid.", type = "error")
          return()
        }
        
        # Update global tables
        current_tables <- db_tables()
        schema_tables <- data.frame(Table_Name = names(schema$tables), stringsAsFactors = FALSE)
        updated_tables <- rbind(current_tables, schema_tables)
        db_tables(updated_tables)  # Update reactive value
        
        # Update global relationships
        current_relationships <- relationships()
        schema_relationships <- data.frame(
          Table1 = sapply(schema$relationships, function(rel) rel[1]),
          Table2 = sapply(schema$relationships, function(rel) rel[2]),
          stringsAsFactors = FALSE
        )
        updated_relationships <- rbind(current_relationships, schema_relationships)
        relationships(updated_relationships)  # Update reactive value
        
        showNotification("Schema loaded successfully!", type = "default")
      }
    })
    
    
    visualizationServer("add_tables_vis", db_tables, relationships)
    visualizationServer("export_design_vis", db_tables, relationships)
}
    
  