# Plotting with ggplot2

# loading packages
library(dplyr) # data manipulation, akin to manual filtering, reordering and calculations 
library(ggplot2) # plotting
library(readr) # reading and writing CSVs

surveys <- readr::read_csv("data_raw/portal_data_joined.csv")   # use this if you only need a package once
surveys <- read_csv("data_raw/portal_data_joined.csv")  

# Filter to complete survey data and remove NAs
surveys_complete <- surveys %>%
  filter(!is.na(weight),
         !is.na(hindfoot_length),
         !is.na(sex))

# Extract the most common species
species_counts <- surveys_complete %>%
  count(species_id) %>%
  filter(n >= 30)


# Include/keep most common species
surveys_complete <- surveys_complete %>%
  filter(species_id %in% species_counts$species_id)  # select something within something (%in%)

# Plotting with ggplot2
# ggplot(data = DATA, mapping = aes() + 
#          geom_point())  # this is the base function to plot using ggplot2, data must be a data frame


ggplot(data = surveys_complete, 
       mapping = aes(x = weight, y = hindfoot_length)) + 
          geom_point()

ggplot(data = surveys_complete, 
       mapping = aes(x = weight, y = hindfoot_length)) + 
  geom_point(alpha = 0.1, color = "red")  # specify the point size to reduce overlapping of points

ggplot(data = surveys_complete, 
       mapping = aes(x = weight, y = hindfoot_length)) + 
  geom_point(alpha = 0.1, aes(color = species_id))  # specify the point size to reduce overlapping of points


# Boxplot
ggplot(data = surveys_complete, 
       aes(x = species_id, y = weight)) + 
  geom_boxplot()
  geom_jitter(alpha = 0.1)

ggplot(data = surveys_complete, 
       aes(x = species_id, y = weight)) + 
  geom_jitter(alpha = 0.1) +
  geom_boxplot(alpha = 0, color = "forestgreen")


# weight - hindfoot_length correlation for each species
sp <- species_counts$species_id
for (i in 1:nrow(species_counts)) {
    sub <- surveys_complete %>% 
    filter(species_id == sp[i])
}


sp <- species_counts$species_id
for (i in 1:nrow(species_counts)) {
  sub <- surveys_complete %>% 
    filter(species_id == sp[i])
  
  fig <- ggplot(data = sub, 
         mapping = aes(x = weight, y = hindfoot_length)) + 
    geom_point(alpha = 0.1)
  
  ggsave(filename = paste0("C:/Users/Owner/Desktop/SEEDS-Critical-Skills/", sp[i], "_length_weight_scatter.jpg"),
         fig,
         height = 4,
         width = 4,
         units = "in")
}


# Time series plots
surveys_complete %>%
  filter(species_id == "DM") %>%
  group_by(year) %>%
  summarise(mean_weight = mean(weight),
            sd_weight = sd(weight)) %>%
  ggplot(aes(x = year, y = mean_weight)) +
  geom_pointrange(aes(ymin = mean_weight - sd_weight,
                      ymax = mean_weight + sd_weight))


# Time series plots challenge: select 'Diplodomys' genus members and find mean and sd of weight for each 
# species, year and sex
surveys_complete %>%
  filter(genus == "Diplodomys") %>%
  group_by(year, species_id, sex) %>%
  summarise(mean_weight = mean(weight),
            sd_weight = sd(weight)) %>%
  ggplot(aes(x = year, y = mean_weight, color = sex)) +
  geom_pointrange(aes(ymin = mean_weight - sd_weight,
                      ymax = mean_weight + sd_weight)) +
  facet_wrap(vars(species_id), scales = "free_y", nrow = 3)


surveys_complete %>%
  filter(genus == "Diplodomys") %>%
  group_by(year, species_id, sex) %>%
  summarise(mean_weight = mean(weight),
            sd_weight = sd(weight)) %>%
  ggplot(aes(x = year, y = mean_weight, color = sex)) +
  geom_pointrange(aes(ymin = mean_weight - sd_weight,
                      ymax = mean_weight + sd_weight)) +
  facet_grid(rows = vars(species_id), 
             cols = vars(sex),
             scales = "free_y")
# facet_grid and facet_wrap did not work for me. Error: Faceting variables must have at least one value
