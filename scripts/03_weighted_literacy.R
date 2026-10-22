# Question 3: Weighted Literacy Rate by Age and Sex
# Registration: FA24-BEDS-086
# Assigned group: Balochistan Rural

# Load required packages
library(readr)
library(dplyr)
library(ggplot2)

# Read the PSLM datasets
hh <- read_csv("data/pslm_hh_subset.csv")
person <- read_csv("data/pslm_person_subset.csv")

# Join household information to person records
pslm <- person %>%
  left_join(
    hh %>% select(hhid, hhweight, prov_code, urban_rural),
    by = "hhid"
  )

# Select Balochistan Rural
balochistan_rural <- pslm %>%
  filter(prov_code == 4, urban_rural == 1)

# Check the number of observations
dim(balochistan_rural)

# Question 3: Prepare literacy data by age and sex
literacy_data <- balochistan_rural %>%
  filter(
    age >= 10,
    age <= 64,
    sex %in% c(1, 2),
    literate %in% c(0, 1),
    !is.na(hhweight),
    hhweight > 0
  ) %>%
  mutate(
    age_start = 10 + 5 * floor((age - 10) / 5),
    age_band = paste0(age_start, "-", age_start + 4),
    age_midpoint = age_start + 2,
    sex_label = if_else(sex == 1, "Male", "Female")
  )

# Check the prepared data
nrow(literacy_data)
head(literacy_data %>% select(age, age_band, sex_label, literate, hhweight))


# Calculate weighted literacy rates by age group and sex
literacy_summary <- literacy_data %>%
  group_by(age_start, age_band, age_midpoint, sex_label) %>%
  summarise(
    n = n(),
    weighted_literacy = 100 * sum(literate * hhweight) / sum(hhweight),
    .groups = "drop"
  ) %>%
  arrange(age_start, sex_label)

# Display the results
print(literacy_summary, n = 22)


# Calculate male-female literacy gaps by age group
literacy_gap <- literacy_summary %>%
  select(age_band, age_start, sex_label, weighted_literacy) %>%
  tidyr::pivot_wider(
    names_from = sex_label,
    values_from = weighted_literacy
  ) %>%
  mutate(gap = Male - Female) %>%
  arrange(desc(abs(gap)))

# Display the largest gap
print(literacy_gap, n = 11)

# Create weighted literacy graph
library(ggplot2)

q3_plot <- ggplot(
  literacy_summary,
  aes(
    x = age_midpoint,
    y = weighted_literacy,
    color = sex_label,
    group = sex_label
  )
) +
  geom_line(linewidth = 1) +
  geom_point(
    aes(shape = n < 30),
    size = 3,
    stroke = 1
  ) +
  scale_shape_manual(
    values = c("FALSE" = 16, "TRUE" = 1),
    labels = c("FALSE" = "30 or more", "TRUE" = "Fewer than 30"),
    name = "Age-band sample size"
  ) +
  scale_x_continuous(
    breaks = seq(12, 62, 5)
  ) +
  labs(
    title = "Literacy Rates by Age and Sex — Balochistan Rural",
    subtitle = "Household-weighted literacy rates, ages 10–64",
    x = "Age group midpoint",
    y = "Weighted literacy rate (%)",
    color = "Sex",
    caption = "Source: PSLM subset | FA24-BEDS-086"
  ) +
  theme_minimal(base_size = 12)

# Display graph
print(q3_plot)

# Save Question 3 graph as an SVG file
ggsave(
  filename = "figures/03_weighted_literacy.svg",
  plot = q3_plot,
  width = 10,
  height = 6,
  units = "in",
  device = "svg"
)