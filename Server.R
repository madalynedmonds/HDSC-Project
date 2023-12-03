library(shiny)
library(ggplot2)
library(dplyr)
library(DT)

# Load data --------------------------------------------------------------------
mpg <- mpg
all_manufacturers <- sort(unique(mpg$manufacturer))
all_fuel <- sort(unique(mpg$fl))

# Create new variable:
# ratio of city and highway MPG
mpg <- mpg %>%
  mutate(mpg_ratio = cty / hwy)

function(input, output, session) {
  output$scatterplot <- renderPlot({
    ggplot(data = mpg, aes_string(x = input$x, y = input$y,
                                     color = input$z)) +
      geom_point(alpha = input$alpha)
  })
  # Print data table
  output$mpgbrush <- renderDataTable({
    brushedPoints(mpg, input$plot_brush) %>% 
      select(manufacturer, drv, fl, class, mpg_ratio, cty, hwy)
  })
  # Create text output stating the correlation between the two ploted
  output$correlation <- renderText({
    r <- round(cor(mpg[, input$x], mpg[, input$y], use = "pairwise"), 3)
    paste0(
      "Correlation = ", r,
      ". Note: If the relationship between the two variables is not linear, the correlation coefficient will not be meaningful."
    )
  })
  output$avgs <- renderUI({
    avg_x <- mpg %>% pull(input$x) %>% mean() %>% round(2)
    avg_y <- mpg %>% pull(input$y) %>% mean() %>% round(2)
    str_x <- paste("Average", input$x, "=", avg_x)
    str_y <- paste("Average", input$y, "=", avg_y)
    HTML(paste(str_x, str_y, sep = '<br/>'))
  })
  output$lmoutput <- renderPrint({
    x <- mpg %>% pull(input$x)
    y <- mpg %>% pull(input$y)
    print(summary(lm(y ~ x, data = mpg)), digits = 3, signif.stars = FALSE)
  })
  # Print data table if checked 
  output$mpgtable <- renderDataTable({
    if(input$show_data){
      DT::datatable(data = mpg %>% select(manufacturer:class),
                    options = list(pageLength = 10),
                    rownames = FALSE)
    } 
  })
  # Create data table
  output$mpgtable2 <- renderDataTable({
    req(input$manufacturer)
    cars_from_selected_manufacturer <- mpg %>%
      filter(manufacturer %in% input$manufacturer) %>%
      select(c(manufacturer,model,cyl,trans,drv,cty,hwy,mpg_ratio,fl,class))
    DT::datatable(
      data = cars_from_selected_manufacturer,
      options = list(pageLength = 10),
      rownames = FALSE)
  })
  # Download file
  output$download_data <- downloadHandler(
    filename = function() {
      paste0("mpg", input$filetype)
    },
    content = function(file) { 
      if(input$filetype == "csv"){ 
        write_csv(mpg %>% select(input$selected_var), file) 
      }
      if(input$filetype == "tsv"){ 
        write_tsv(mpg %>% select(input$selected_var), file) 
      }
    })}