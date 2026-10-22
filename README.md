
# ECO346 Assignment 1 — Data Visualization

**Registration Number:** FA24-BEDS-086  
**Assigned Group:** Balochistan Rural  
**Course:** ECO346 — Data Visualization Techniques for Economists

## Project Overview

This repository contains the data, R and Python scripts, and visualizations for Assignment 1.

The analysis focuses on household-weighted education spending and literacy patterns in rural Balochistan using the PSLM subset datasets.

## Folder Structure

- `data/` — Original PSLM CSV datasets and Python literacy results.
- `scripts/` — R and Python scripts for the assignment.
- `figures/` — Generated SVG visualizations.
- `slides/` — PowerPoint presentation.

## Data Files

- `data/pslm_hh_subset.csv`
- `data/pslm_person_subset.csv`

Source: PSLM subset datasets provided through the course repository.

## Software Requirements

- R and RStudio
- R packages: `tidyverse`, `ggplot2`, `readr`, `dplyr`
- Python 3
- Python packages: `pandas`, `numpy`, `matplotlib`

## How to Run

Download or clone this repository and set the working directory to the main project folder.

### R Scripts

Open the RStudio project or set the working directory to the repository root.

Run the scripts in the `scripts/` folder:

1. `01_data_check.R` — Check and prepare the data.
2. `02_weighted_histogram.R` — Create the weighted education spending histogram.
3. `03_weighted_literacy.R` — Create the weighted literacy graph.
4. `04_default_plot.R` — Generate the original default plot.
5. `04_redesigned_plot.R` — Generate the redesigned literacy visualization.

### Python Script

Install the required Python packages:

```bash
python -m pip install pandas numpy matplotlib
```

Run the script from the repository root:

```bash
python scripts/05_python_literacy.py
```

The Python script calculates household-weighted literacy rates by age group and sex, saves a CSV results table, and generates an SVG graph.

## Outputs

Visualizations are saved in the `figures/` folder.

The Python results table is saved as:

`data/05_python_literacy_results.csv`

## Reproducibility

The scripts use local CSV datasets and do not require internet access when running, provided the required software and packages are installed.
