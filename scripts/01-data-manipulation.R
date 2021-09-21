# Manipulating data in R

library(dplyr) # data manipulation, akin to manual filtering, reordering and calculations 
library(tidyr) # reshaping data functions
library(readr) # reading and writing CSvs
library(udunits2) # unit conversions

surveys <- read_csv("data_raw/portal_data_joined.csv")  
# function is faster for larger files, it automatically reads characters as factors, it also interprets date/times, it also tibbles, which means
# it prints the first 6 rows within the size of the frame/monitor
str(surveys)
nrow(surveys) ; ncol(surveys)
head(surveys)

# Subsetting by rows (filter) and columns (select) using dplyr R package
filter(surveys, year == 1995)
select(surveys, month, species, genus)
select(surveys, -record_id, -day)

surveys_sml <- surveys %>%
  filter(weight < 5) %>%
  select(species_id, sex, weight)
# %>% is called pipe in dplyr and it allows you to run calculations in sequence, so that the result of the first calculation is the input for 
# the second calculation in the sequence
str(surveys_sml)

# Adding a calculated column (mutate)
surveys %>%
  mutate(weight_kg = weight/1000, 
         weight_lb = weight_kg/2.2) # original units in grams, you can change to kg or pounds

surveys %>%
  filter(!is.na(weight)) %>%  # to remove NAs in the data
  select(weight) %>%
  mutate(weight_kg = ud.convert(weight, "g", "lb")) # original units in grams


# Split/apply/combine paradigm, using group_by() and summarize()
surveys %>% 
  filter(!is.na(weight), !is.na(sex)) %>%
  group_by(sex, species_id) %>% 
  summarize(mean_weight = mean(weight, na.rm = TRUE),
            sd_weight = sd(weight, na.rm = TRUE),
            n = n()) %>%
  arrange(desc(mean_weight))

# Counting, using count(), n()
count(surveys, species, sex)  # gives a count of data for each types in a column. It is similar to table() in baseR
# count is group_by() and summarize (n=n())
# n() is used within summarize()


# Reshaping data from long to wide, using pivot_wider()
surveys_gw <- surveys %>%
  filter(!is.na(weight)) %>%
  group_by(plot_id, genus) %>%
  summarize(mean_weight = mean(weight))
View(surveys_gw)

surveys_wide <- surveys_gw %>%
  pivot_wider(names_from = genus, values_from = mean_weight)
View(surveys_wide)

# from wide to long, using pivot_longer()
surveys_long <- surveys_wide %>%
  pivot_longer(-plot_id, names_to = "genus", values_to = "mean_weight") %>%
  filter(!is.na(mean_weight))
View(surveys_long)


# Write out the 
# dir.create("data_clean")
write_csv(surveys_wide, file = "data_clean/surveys_genus_weight.csv")
