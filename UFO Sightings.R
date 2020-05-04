library(data.table)
library(shiny)
library(leaflet)

UFO_map <- fread("https://raw.githubusercontent.com/kilo308/UFO-Interactive-Map/master/UFO%20Sightings.csv")

UFO_map$latitude <- as.numeric(UFO_map$latitude)
str(UFO_map)

ui <- fluidPage(
  titlePanel("UFO Sightings"),
  leafletOutput("UFO_map"),
  actionButton("recalc", "Reset"),
  strong(),
  p(),
  strong("Description:"),
  p("The map contains reports of unidentified flying objects in the last century from a dataset provided by the National UFO Reporting Center (NUFORC)."),
  strong("Instructions:"),
  p(" Zoom in on the map to see each cluster until it can no longer separate. Then click on the blue marker to see its details. Click on the RESET button to go back to the default view.")
)


server <- function(input, output, session) {
  
  points <- eventReactive(input$recalc, {
    cbind(UFO_map$longitude, UFO_map$latitude)
  }, ignoreNULL = FALSE)
  
  output$UFO_map <- renderLeaflet({
    UFO_map %>%
      leaflet() %>%
      addTiles() %>% 
      addMarkers(data = points(), popup=paste0("<strong>Date/Time: </strong>",
                                               UFO_map$datetime,
                                               "<br><strong>City: </strong>", 
                                               UFO_map$city,
                                               "<br><strong>Shape of UFO: </strong>", 
                                               UFO_map$shape,
                                               "<br><strong>Report: </strong>", 
                                               UFO_map$comments
                                               
      ),
      clusterOptions=markerClusterOptions())
  })
}

shinyApp(ui, server)