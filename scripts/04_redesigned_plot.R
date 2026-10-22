# Question 4: Redesigned Literacy Plot
# Registration: FA24-BEDS-086
# Assigned group: Balochistan Rural

library(readr)
library(dplyr)
library(ggplot2)

# Read datasets
hh <- read_csv("data/pslm_hh_subset.csv")
person <- read_csv("data/pslm_person_subset.csv")

# Join household and person records
pslm <- person %>%
  left_join(
    hh %>% select(hhid, hhweight, prov_code, urban_rural),
    by = "hhid"
  )

# Select valid observations
literacy_data <- pslm %>%
  filter(
    prov_code == 4,
    urban_rural == 1,
    age >= 10,
    age <= 64,
    sex %in% c(1, 2),
    literate %in% c(0, 1),
    !is.na(hhweight),
    hhweight > 0
  ) %>%
  mutate(
    age_start = 10 + 5 * floor((age - 10) / 5),
    age_midpoint = age_start + 2,
    sex_label = if_else(sex == 1, "Male", "Female")
  )

# Calculate weighted literacy rates
literacy_summary <- literacy_data %>%
  group_by(age_start, age_midpoint, sex_label) %>%
  summarise(
    n = n(),
    literacy_rate = 100 * sum(literate * hhweight) / sum(hhweight),
    .groups = "drop"
  )

# Create redesigned graph
redesigned_plot <- ggplot(
  literacy_summary,
  aes(
    x = age_midpoint,
    y = literacy_rate,
    color = sex_label,
    group = sex_label
  )
) +
  geom_line(linewidth = 1.1) +
  geom_point(aes(shape = n < 30), size = 3, stroke = 1) +
  scale_shape_manual(
    values = c("FALSE" = 16, "TRUE" = 1),
    labels = c("30 or more", "Fewer than 30"),
    name = "Age-band sample size"
  ) +
  scale_x_continuous(breaks = seq(12, 62, 5)) +
  scale_y_continuous(limits = c(0, 100)) +
  labs(
    title = "Literacy Rates by Age and Sex — Balochistan Rural",
    subtitle = "Redesigned plot: household-weighted literacy rates",
    x = "Age group midpoint",
    y = "Weighted literacy rate (%)",
    color = "Sex",
    caption = "Source: PSLM subset | FA24-BEDS-086"
  ) +
  theme_minimal(base_size = 12)

# Display redesigned graph
print(redesigned_plot)

# Save redesigned graph
ggsave(
  filename = "figures/04_redesigned_plot.svg",
  plot = redesigned_plot,
  width = 10,
  height = 6,
  units = "in",
  device = "svg"
)