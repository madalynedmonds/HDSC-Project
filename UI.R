library("shiny")
library(ggplot2)
library(dplyr)
library(DT)

shinyUI(fluidPage(
  headerPanel("Fuel Economy Data from 1999 to 2008 for 38 Popular Models of Cars"),
  #Sidebar layout with an input and output definitions
  sidebarLayout(
    # Inputs: select variables to plot
    sidebarPanel(
      # Select variable for y-axis
      selectInput(inputId = "y", label = "Y-axis:",
                  choices = c("Engine Displacement"="displ","City MPG"="cty","Highway MPG"="hwy", "City to Highway MPG Ratio"="mpg_ratio"),
                  selected = "cty"),
      # Select variable for x-axis
      selectInput(inputId = "x", label = "X-axis:",
                  choices = c("Engine Displacement"="displ","City MPG"="cty","Highway MPG"="hwy", "City to Highway MPG Ratio"="mpg_ratio"),
                  selected = "hwy"),
      # Select variable for color
      selectInput(inputId = "z",
                  label = "Color by:",
                  choices = c("Manufacturer"="manufacturer","Model"="model","Year"="year","Cylinders"="cyl","Transmission"="trans","Drive Type"="drv", "Fuel Type"="fl","Class"="class"),
                  selected = "drv"),
      selectInput(
        inputId = "manufacturer",
        label = "Select Manufacturer:",
        choices = all_manufacturers,
        selected = "audi",
        multiple = TRUE
      ),
      # Select alpha level
      sliderInput(inputId = "alpha", 
                  label = "Data Point Opacity:", 
                  min = 0, max = 1, 
                  value = 1),
      # Show data table 
      checkboxInput(inputId = "show_data",
                    label = "Show Full Data Table", value = FALSE),
      # Download Data
      radioButtons(inputId = "filetype",
                   label = "Select Filetype:",
                   choices = c("csv", "tsv"),
                   selected = "csv"),
      
      checkboxGroupInput(inputId = "selected_var",
                         label = "Select variables:",
                         choices = names(mpg),
                         selected = c("manufacturer"))
    ),
    # Output: Show scatterplot
    mainPanel(
      plotOutput(outputId = "scatterplot", brush = "plot_brush"),
      # Show data table
      textOutput(outputId = "correlation"),
      dataTableOutput(outputId = "mpgbrush"),
      htmlOutput(outputId = "avgs"),
      verbatimTextOutput(outputId = "lmoutput"),
      DT::dataTableOutput(outputId = "mpgtable"),
      DT::dataTableOutput(outputId = "mpgtable2"),
      HTML("Select filetype and variables, then hit 'Download data'."),
      downloadButton("download_data", "Download data")
    )
  )
))