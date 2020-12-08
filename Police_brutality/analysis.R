library(tidyverse)
library(leaflet)
library(ggplot2)
library(waffle)

# link back to https://simplemaps.com/data/us-cities

murders <- read.csv("data/PoliceKillingsUS.csv")
cities <- read.csv("data/uscities.csv")
population <- read.csv("data/data2017.csv")

murders <- cities %>% 
  select(city, lat, lng) %>% 
  left_join(murders, by = "city") %>% 
  mutate(race = replace(race, race == 'B', 'Black')) %>% 
  mutate(race = replace(race, race == 'W', 'White')) %>% 
  mutate(race = replace(race, race == 'H', 'Latinx')) %>% 
  mutate(race = replace(race, race == 'A', 'Asian')) %>% 
  mutate(race = replace(race, race == 'N', 'Native American')) %>% 
  mutate(race = replace(race, race == 'O', 'Other/Undetermined')) %>% 
  mutate(race = replace(race, race == '', 'Other/Undetermined')) %>% 
  drop_na(manner_of_death) %>% 
  distinct(name, .keep_all = T)

population <- population %>% 
  select(DP05_0080PE, DP05_0078PE, DP05_0071PE, DP05_0079PE,
         DP05_0082PE, DP05_0077PE) %>%
  rename(White = DP05_0077PE, Black = DP05_0078PE, 
         Native = DP05_0079PE, Asian = DP05_0080PE, Other = DP05_0082PE, 
         Latinx = DP05_0071PE) %>% 
  slice(2) %>% 
  gather(key = "race", value ="proportion")

gather <- murders %>%
  select(race) %>% 
  group_by(race) %>% 
  count() %>%
  rename(Total = n) %>% 
  ungroup() %>% 
  mutate(Percent = 100 * Total / sum(Total))
  
  
