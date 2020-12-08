#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
source("analysis.R")

select_race <- c("All races", unique(murders$race))
select_race <- select_race[-9]
age <- range(murders$age, na.rm=TRUE)
select_weapon <- c("Unsorted", unique(murders$armed))

mental_illness_input <- selectInput(
    inputId = "by_mental_illness",
    label = "Signs of mental illness?",
    choices = c("Both", TRUE, FALSE)
)
armed_input <- selectInput(
    inputId = "by_weapon",
    label = "Armed?",
    choices = select_weapon
)
race_input <- selectInput(
    inputId = "by_race",
    label = "Sort by race",
    choices = select_race
)

age_input <- sliderInput(
    inputId = "age_slider",
    label = "Sort by age",
    min = age[1],
    max = age[2],
    value = cbind(age[1], age[2])
)

waffle_age_input <- sliderInput(
    inputId = "waffle_age_slider",
    label = "Sort by age",
    min = age[1],
    max = age[2],
    value = cbind(age[1],age[2])
)

# Define UI for application that draws a histogram
tagList(
    includeCSS("www/style.css"),
    navbarPage(title = "An Analysis of Fatal Shootings by Police",
               header = "",
               id = "navtab",
               
               tabPanel("Introduction",
                        h3("Police Brutality in the United States"),
                        img(src='protest.jpg', align = "left", width = "500px"),
                        h4("Introduction"),
                        p("Since before ", 
                          a("Rodney King", href = "https://www.npr.org/2017/04/26/524744989/when-la-erupted-in-anger-a-look-back-at-the-rodney-king-riots"),
                          ", the police brutality in the United States has been
                          a controversial issue. In light of recent events,
                          namely the murder of",
                          a("George Floyd", href = "https://www.nytimes.com/article/george-floyd.html"),
                          " in Minnneapolis, the issue has resurfaced, and more 
                          people are demanding awareness. In my own exploration 
                          of the issue, I chose to examine age and race, and how
                          these two factors influenced likeliness to get killed
                          by a police officer. "
                          ),
                        h4("Processes"),
                        p("The fatal police shootings dataset was relatively
                          long, and I appreciate that it provided the name and 
                          other information about the victims. But, I didn't 
                          know where to begin, so I chose to map it all. To show 
                          as much information as possible, I decided to use a 
                          leaflet map with markers at the location of death, 
                          and popups the rest of the information. I was
                          influenced by my readings of Data Feminism to make 
                          such a map, because it shows each individual case 
                          instead of masking it behind a statistic. The giant
                          swarm of markers is overwhelming and takes you aback,
                          while the number of total deaths- 2,281- might not 
                          have as much gravity. To get the coordinates, I joined
                          the simplemaps us cities dataset with the police 
                          killings dataset by city."),
                        p("In my exploration, I was interested to 
                          see how many people my age (17) were involved in these
                          fatal shootings. So, I decided to filter these
                          values by age. I noticed that almost every popup
                          under the age of 17 was black. So, I decided to focus
                          my question not only on age, but on race as well."),
                        p("The next graphic was meant to show the proportion
                          between all the races, sorted again by age. I chose a
                          waffle graph because it could show the proportion 
                          while maintaining the individuality. The graph indeed
                          supported my previous observation that younger black 
                          people are more likely to be fatally wounded by police
                          , but I was surprised to see that in total, there were
                          more white people in total killed by police. Then, I 
                          realized that obviously this would be the case because
                          there are more white people in the United States. To 
                          prevent other people from making this mistake in their
                          initial analysis of the graph, I included the total
                          proportion of different races in the United States
                          using data from the U.S census website for 2017. This
                          helped me assert that black people were
                          disproportionately killed by police, while white
                          people and asians were actually less likely to be the
                          victims of these fatal shootings."),
                        p("Finally, I wanted to know more about the specific
                          cases, especially I was interested if unarmed young
                          black people were more likely to be killed by police 
                          than any other race, as they seemed to be in general.
                          The plot showed that indeed, this was true"),
                        h4("Citations"),
                        p("For this project, I used the ",
                          a("US Cities", 
                            href="https://simplemaps.com/data/us-cities"),
                          " dataset by simplemaps.com to access the coordinates
                          for the leaflet map. I also used the",
                          a("Fatal Police Shootings in the US",
                            href="https://www.kaggle.com/kwullum/fatal-police-shootings-in-the-us?select=PoliceKillingsUS.csv"),
                          "from Kaggle. Last, I used the ",
                          a("2017 ACS Demographic and Housing data", href="https://www.census.gov/data/datasets/2017/demo/popproj/2017-popproj.html"),
                          "from the census.gov site's datasets"
                          ),
               ),
               tabPanel("Data Analysis",
                   tabsetPanel(
                       tabPanel("Map",
                                sidebarLayout(
                                    sidebarPanel(
                                        race_input,
                                        age_input,
                                    ),
                                    
                                    mainPanel(
                                        h3("Police killings, 2015-2017"),
                                        p("The following map lists every killing
                                          by police from 01/01/2015 - 
                                          12/31/2017. Click on the markers to
                                          get more information about each victim
                                          ."),
                                        leafletOutput("map_plot")
                                    )
                                )
                       ),
                       tabPanel("Waffle Chart",
                                sidebarLayout(
                                    sidebarPanel(
                                        waffle_age_input
                                    ),
                                    
                                    # Show a plot of the generated distribution
                                    mainPanel(
                                        h3("Fatalities by race"),
                                        p("The following map illustrates the 
                                          proportion of people killed by age, 
                                          by race."),
                                        plotOutput("waffle_plot"),
                                        p("Left: the total number and percentage
                                          and number of people killed, by race.
                                          Right: the total population of people
                                          in the USA in 2017, by race"),
                                        fluidRow(
                                            tableOutput("waffle_table"),
                                            tableOutput("total_table")
                                        )
                                    )
                                )
                       ),
                       tabPanel("Violin Plot",
                                sidebarLayout(
                                    sidebarPanel(
                                        armed_input,
                                        mental_illness_input 
                                    ),
                                    
                                    mainPanel(
                                        h3("Fatalities by weapon and mental 
                                           illness"),
                                        p("The following map illustrates the 
                                          general trend of police killings by
                                          race, age and weapon."),
                                        plotOutput("violin_plot")
                                    )
                                )
                       )
                   )
               ),
               tabPanel("Conclusions",
                        h4("Findings"),
                        img(src='protest2.jpg', align = "right", width = "500px"
                            ),
                        p("Through my research, I found that young, black men
                        under the age of 20 were disproportionately killed by
                        police officers. 45% of all murders under the age of 20
                        by cops were black. Compare this to the 12% of the
                        U.S population which is black. I also found that younger
                        unarmed latinx and black people were more likely to be 
                        killed than their white peers. Additionally, Asian 
                        people were also only proportionally less likely to to 
                        be killed by police than white people."),
                        )
    )
)