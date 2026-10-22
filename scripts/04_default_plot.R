# Question 4: Default ggplot
# Registration: FA24-BEDS-086
# Assigned group: Balochistan Rural

library(readr)
library(dplyr)
library(ggplot2)

# Read datasets
hh <- read_csv("data/pslm_hh_subset.csv")
person <- read_csv("data/pslm_person_subset.csv")

# Join household information
pslm <- person %>%
  left_join(
    hh %>% select(hhid, prov_code, urban_rural),
    by = "hhid"
  )

# Select assigned group
balochistan_rural <- pslm %>%
  filter(
    prov_code == 4,
    urban_rural == 1,
    age >= 10,
    age <= 64,
    literate %in% c(0, 1)
  )

# Default ggplot (before redesign)
default_plot <- ggplot(
  balochistan_rural,
  aes(x = age, y = literate)
) +
  geom_point()

print(default_plot)

# Save the original default plot before redesign
ggsave(
  filename = "figures/04_default_plot.svg",
  plot = default_plot,
  width = 10,
  height = 6,
  units = "in",
  device = "svg"
)