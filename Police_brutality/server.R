#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
source("analysis.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    output$map_plot <- renderLeaflet({
        
        hits <- makeIcon(iconUrl = "www/marker.png",
                           iconWidth = 20, iconHeight = 31,
                           iconAnchorX = 0, iconAnchorY = 0)
        
        plot_data <- murders %>% 
            filter(race == input$by_race) %>% 
            filter(age <= input$age_slider[2], age >= input$age_slider[1])
        
        if (input$by_race == "All races") {
            plot_data <- murders  %>% 
                filter(age <= input$age_slider[2], age >= input$age_slider[1])
        }
        
        map_plot <- leaflet(data = plot_data) %>% 
            addTiles() %>% 
            addProviderTiles(providers$Esri.WorldImagery) %>% 
            addMarkers(~lng,
                       ~lat,
                       icon = hits,
                       popup = 
                           paste(sep = "<br/>",
                                 paste("name:",
                                        plot_data$name),
                                 paste("age:",
                                        plot_data$age),
                                 paste("race:",
                                        plot_data$race),
                                 paste("manner of death:",
                                        plot_data$manner_of_death),
                                 paste("signs of mental illness?",
                                        plot_data$signs_of_mental_illness)
                                        ),
                       clusterOptions = 
                           markerClusterOptions(maxClusterRadius = 1)
                      )
        
        map_plot
    })
    
    output$waffle_plot <- renderPlot({
        
        murders <- murders %>%
            group_by(race, .drop=FALSE) %>%
            filter(age <= input$waffle_age_slider[2], age >= input$waffle_age_slider[1])
        
        plot_data <- murders %>%
            select(race) %>%
            count() %>%
            rename(total = n) %>% 
            ungroup() %>% 
            tibble::column_to_rownames('race') %>% 
            unlist(recursive = TRUE, use.names = TRUE)
        
        names(plot_data) <- c("Asian",
                              "Black",
                              "Latinx",
                              "Native American",
                              "Other/Undetermined",
                              "White")
        
        
        waffle_plot <- waffle(plot_data, rows=50, size = 0.6,
               colors=c("#1c9e77", "#d95f02", "#7470b3", "#f12088", "#67a61f", "#e6ad01" ),  
               xlab="1 square = 1 person",
        )
        
        waffle_plot
    })
    
    output$total_table <- renderTable({
        
        plot_data <- population
        
        plot_data
        
    })
    output$waffle_table <- renderTable({
        
        plot_data <- murders %>%
            filter(age <= input$waffle_age_slider[2], age >= input$waffle_age_slider[1]) %>% 
            select(race) %>% 
            group_by(race) %>% 
            count() %>%
            rename(Total = n) %>% 
            ungroup() %>% 
            mutate(Percent = 100 * Total / sum(Total))
        
        plot_data
    })
    
    output$violin_plot <- renderPlot({
        plot_data <- murders %>% 
            filter(signs_of_mental_illness == input$by_mental_illness) %>%
            filter(armed == input$by_weapon)
        
        if (input$by_mental_illness == "Both"){
            plot_data <- murders %>% 
                filter(armed == input$by_weapon)
        }
        
        if (input$by_weapon == "Unsorted"){
            plot_data <- murders %>% 
                filter(signs_of_mental_illness == input$by_mental_illness)
        }
        
        if (input$by_weapon == "Unsorted" && input$by_mental_illness == "Both"){
            plot_data <- murders
        }
        
        ggplot(plot_data, aes(x=race, y=age, fill=race)) + 
            coord_flip() +
            geom_violin(trim=FALSE) + 
            scale_fill_brewer(palette="Dark2") +
            geom_boxplot(width=0.1)
    })
})
