library(visNetwork)

visualizationUI <- function(id) {
  ns <- NS(id)
  tagList(
    visNetworkOutput(ns("network"))
  )
}

visualizationServer <- function(id, tables, relationships) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    output$network <- renderVisNetwork({
      tables_data <- tables()
      relationships_data <- relationships()
      
      if (nrow(tables_data) == 0) {
        showNotification("No tables to display.", type = "warning")
        return(NULL)
      }
      
      # Create table nodes
      table_nodes <- data.frame(
        id = tables_data$Table_Name,
        label = tables_data$Table_Name,
        shape = "box",
        stringsAsFactors = FALSE
      )
      
      # Initialize attribute nodes & edges
      attr_nodes <- data.frame(id = character(), label = character(), shape = character(), stringsAsFactors = FALSE)
      attr_edges <- data.frame(from = character(), to = character(), arrows = character(), stringsAsFactors = FALSE)
      
      for (i in seq_len(nrow(tables_data))) {
        table_name <- tables_data$Table_Name[i]
        attributes <- unlist(tables_data$Attributes[[i]])  # Ensure attributes are a character vector
        
        if (!is.null(attributes) && length(attributes) > 0) {
          new_attr_nodes <- data.frame(
            id = paste0(table_name, "_", attributes),
            label = attributes,
            shape = "ellipse",
            stringsAsFactors = FALSE
          )
          
          new_attr_edges <- data.frame(
            from = paste0(table_name, "_", attributes),
            to = table_name,
            arrows = "to",
            stringsAsFactors = FALSE
          )
          
          attr_nodes <- rbind(attr_nodes, new_attr_nodes)
          attr_edges <- rbind(attr_edges, new_attr_edges)
        }
      }
      
      # Ensure relationships_data is not empty
      if (nrow(relationships_data) > 0) {
        rel_edges <- data.frame(
          from = relationships_data$Table1,
          to = relationships_data$Table2,
          arrows = rep("to", nrow(relationships_data)),
          stringsAsFactors = FALSE
        )
      } else {
        rel_edges <- data.frame(from = character(), to = character(), arrows = character(), stringsAsFactors = FALSE)
      }
      
      # **Ensure nodes have same structure**
      attr_nodes <- attr_nodes[, names(table_nodes), drop = FALSE]
      
      # **Ensure edges have same structure**
      attr_edges <- attr_edges[, names(rel_edges), drop = FALSE]
      
      # Merge nodes and edges
      nodes <- rbind(table_nodes, attr_nodes)
      edges <- rbind(attr_edges, rel_edges)
      
      # Ensure non-empty graph
      if (nrow(nodes) == 0 || nrow(edges) == 0) {
        showNotification("No data available for visualization.", type = "warning")
        return(NULL)
      }
      
      # Render network
      visNetwork(nodes, edges) %>%
        visEdges(arrows = "to") %>%
        visNodes(font = list(size = 14))
    })
  })
}




