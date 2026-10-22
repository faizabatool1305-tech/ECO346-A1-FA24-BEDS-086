# Load the required package
library(readr)

# Read the two PSLM datasets
hh <- read_csv("data/pslm_hh_subset.csv")
person <- read_csv("data/pslm_person_subset.csv")

# Check the number of rows and columns
dim(hh)
dim(person)

# Load dplyr for data preparation
library(dplyr)

# Combine person data with household information
pslm <- person %>%
  left_join(
    hh %>% select(hhid, hhweight, prov_code, urban_rural),
    by = "hhid"
  )

# Check the combined dataset
dim(pslm)

# Filter the assigned group: Balochistan Rural
balochistan_rural <- pslm %>%
  filter(prov_code == 4, urban_rural == 1)

# Check the number of observations
dim(balochistan_rural)

# Check education spending and household weights
summary(balochistan_rural$ed_total)
summary(balochistan_rural$hhweight)

# Count observations with positive education spending
sum(balochistan_rural$ed_total > 0, na.rm = TRUE)