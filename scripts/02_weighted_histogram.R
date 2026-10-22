# Question 2: Weighted Histogram
# Registration: FA24-BEDS-086
# Assigned group: Balochistan Rural

library(readr)
library(dplyr)
library(ggplot2)
library(scales)

# Read the original datasets
hh <- read_csv("data/pslm_hh_subset.csv")
person <- read_csv("data/pslm_person_subset.csv")

# Join household information to person records
pslm <- person %>%
  left_join(
    hh %>% select(hhid, hhweight, prov_code, urban_rural),
    by = "hhid"
  )

# Select Balochistan Rural and valid spending observations
q2_data <- pslm %>%
  filter(
    prov_code == 4,
    urban_rural == 1,
    !is.na(ed_total),
    ed_total > 0,
    !is.na(hhweight),
    hhweight > 0
  ) %>%
  mutate(log_spending = log10(ed_total))

# Check the prepared data
nrow(q2_data)
summary(q2_data$log_spending)

# Function to calculate weighted quantiles
weighted_quantile <- function(x, w, p) {
  order_index <- order(x)
  x <- x[order_index]
  w <- w[order_index]
  
  cumulative_weight <- cumsum(w) / sum(w)
  
  x[which(cumulative_weight >= p)[1]]
}

# Calculate weighted median and 90th percentile
weighted_median <- weighted_quantile(
  q2_data$log_spending,
  q2_data$hhweight,
  0.50
)

weighted_p90 <- weighted_quantile(
  q2_data$log_spending,
  q2_data$hhweight,
  0.90
)

# Display the results
weighted_median
weighted_p90


# Create the weighted histogram
q2_plot <- ggplot(
  q2_data,
  aes(x = log_spending, weight = hhweight)
) +
  geom_histogram(
    aes(y = after_stat(density)),
    binwidth = 0.1,
    boundary = 2,
    fill = "#4C78A8",
    color = "white"
  ) +
  geom_vline(
    xintercept = weighted_median,
    color = "#E45756",
    linewidth = 1,
    linetype = "dashed"
  ) +
  geom_vline(
    xintercept = weighted_p90,
    color = "#54A24B",
    linewidth = 1,
    linetype = "dashed"
  ) +
  annotate(
    "text",
    x = weighted_median,
    y = Inf,
    label = paste0("Median: ", round(weighted_median, 2)),
    angle = 90,
    vjust = 1.5,
    hjust = 1.1,
    color = "#E45756"
  ) +
  annotate(
    "text",
    x = weighted_p90,
    y = Inf,
    label = paste0("90th percentile: ", round(weighted_p90, 2)),
    angle = 90,
    vjust = 1.5,
    hjust = 1.1,
    color = "#54A24B"
  ) +
  scale_x_continuous(
    breaks = seq(2, 6, 0.5)
  ) +
  coord_cartesian(xlim = c(2, 6)) +
  labs(
    title = "Education Spending Distribution — Balochistan Rural",
    subtitle = "Household-weighted histogram of positive education spending",
    x = "Log10 of education spending (PKR)",
    y = "Weighted density",
    caption = "Source: PSLM subset | FA24-BEDS-086"
  ) +
  theme_minimal(base_size = 12)

# Display the histogram
print(q2_plot)


# Save Question 2 histogram as an SVG file
ggsave(
  filename = "figures/02_weighted_histogram.svg",
  plot = q2_plot,
  width = 10,
  height = 6,
  units = "in",
  device = "svg"
)