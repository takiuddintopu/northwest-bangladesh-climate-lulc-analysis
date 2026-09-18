# R Scripts

This directory contains the R scripts used for climate variability, trend, extreme precipitation, and correlation analyses in the study.

The scripts are organized by analytical objective to keep the workflow clear and reproducible.

## Directory Structure

```text
scripts/
├── 01-trend-analysis/
│   └── annual-climate-trend-analysis.R
│
├── 02-climatology-analysis/
│   ├── monthly-climatology.R
│   └── seasonal-climate-variability.R
│
├── 03-gev-analysis/
│   └── gev-annual-maximum-monthly-rainfall.R
│
└── 04-correlation-analysis/
    ├── climate-correlation-analysis.R
    └── pearson-heatmaps.R
```

## Scripts Overview

---

### 1. Annual Climate Trend Analysis

**Script:** `trend-analysis/annual_climate_trend_analysis.R`

Analyzes long-term annual trends in:

* Rainfall
* Mean temperature
* Relative humidity
* Wind speed

The script applies:

* Mann–Kendall trend test
* Sen's slope estimator

The analysis covers **1973–2023** for Rajshahi, Pabna, Natore, and Bogura.

**Main outputs:**

* Mann–Kendall trend figures
* Sen's slope statistics tables

---

### 2. Monthly Climatology

**Script:** `climatology-analysis/monthly_climatology.R`

Calculates the long-term monthly climatology of the four climatic parameters for the study period.

Rainfall is aggregated as monthly totals, while temperature, relative humidity, and wind speed are summarized using monthly means.

**Main outputs:**

* Monthly rainfall climatology
* Monthly temperature climatology
* Monthly relative humidity climatology
* Monthly wind speed climatology

---

### 3. Seasonal Climate Variability

**Script:** `climatology-analysis/seasonal_climate_variability.R`

Examines climatic variability across four seasons:

* Winter (DJF)
* Pre-monsoon (MAM)
* Monsoon (JJAS)
* Post-monsoon (ON)

The script calculates seasonal statistics for rainfall, temperature, relative humidity, and wind speed.

December is assigned to the following winter season so that each DJF season represents a complete December–January–February period.

**Main outputs:**

* Seasonal climate figures
* Seasonal climatic summary tables
* Seasonal standard deviation tables

---

### 4. GEV Analysis of Extreme Precipitation

**Script:** `gev-analysis/gev_annual_maximum_monthly_rainfall.R`

Performs Generalized Extreme Value (GEV) analysis of extreme precipitation.

Because a complete daily rainfall record for 1973–2023 was not available, the analysis uses **annual maximum monthly rainfall totals (AMS)** rather than annual maximum daily rainfall.

The script includes:

* GEV parameter estimation
* Anderson–Darling goodness-of-fit assessment
* Q–Q diagnostics
* Return-level estimation
* Bootstrap uncertainty estimation
* Mann–Kendall trend assessment of AMS
* Sen's slope estimation

**Main outputs:**

* AMS trend figure
* GEV Q–Q diagnostic plots
* GEV return-level curves
* GEV parameter and goodness-of-fit table
* Return-level summary table

---

### 5. Climate Correlation Analysis

**Script:** `correlation-analysis/climate_correlation_analysis.R`

Examines statistical associations among the climatic parameters using:

* Pearson correlation
* Spearman rank correlation
* Kendall rank correlation

The analysis is performed for individual districts and for the regional mean series.

Pairwise complete observations are used when calculating correlations.

**Main outputs:**

* District-level correlation tables
* Regional correlation tables
* Pearson, Spearman, and Kendall heatmaps
* Temperature–humidity scatter plots

> Correlation analysis describes statistical association and does not establish causation.

---

### 6. Pearson Correlation Heatmaps

**Script:** `correlation-analysis/pearson_heatmaps.R`

Generates Pearson correlation heatmaps for the climatic parameters.

The script provides a focused workflow for producing:

* District-level Pearson correlation heatmaps
* Regional mean Pearson correlation heatmap

It is intended as a standalone visualization script for Pearson correlation results.

---

## Required R Packages

The scripts use commonly available R packages, including:

```r
dplyr
tidyr
ggplot2
Kendall
trend
ismev
evd
goftest
gridExtra
```

Additional packages may be required depending on the specific analysis being run.

Install packages in R/RStudio with:

```r
install.packages(c(
  "dplyr",
  "tidyr",
  "ggplot2",
  "Kendall",
  "trend",
  "ismev",
  "evd",
  "goftest",
  "gridExtra"
))
```

## Data Requirements

The scripts are designed to work with the processed climate datasets used in this project.

The expected datasets include annual and monthly climate data for:

* Rajshahi
* Pabna
* Natore
* Bogura

The study period is **1973–2023**.

Raw meteorological datasets are not included in this repository. See [`data/README.md`](../data/README.md) for information about the data sources, processing, and limitations.

## Reproducibility

The scripts were developed in **R** and are intended to provide a reproducible workflow from processed climate datasets to statistical results and figures.

Before running a script:

1. Place the required input datasets in the expected data location.
2. Open the corresponding `.R` file in R/RStudio.
3. Check the input file names and paths.
4. Install the required packages.
5. Run the script.

The scripts save generated figures and statistical tables to their designated output directories.

## Notes on Methodological Scope

This repository represents the computational workflow used for the climate analysis component of the study.

Important methodological limitations are documented in the main project README and `data/README.md`, particularly the use of **annual maximum monthly rainfall** for GEV analysis because complete daily rainfall data were unavailable for the entire study period.

For the full methodological explanation, interpretation of results, and discussion of limitations, refer to the thesis included in the `thesis/` directory.
