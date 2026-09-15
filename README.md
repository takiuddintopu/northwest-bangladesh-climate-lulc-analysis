# Spatiotemporal Variability and Trends in Climatic Parameters and their Association with Extreme Precipitation, Land use, and Land cover Change in Northwest Bangladesh

[![Study Period](https://img.shields.io/badge/Study%20Period-1973--2023-blue)]()
[![Study Area](https://img.shields.io/badge/Study%20Area-Northwest%20Bangladesh-green)]()
[![GIS](https://img.shields.io/badge/GIS-ArcMap%2010.8-orange)]()
[![Analysis](https://img.shields.io/badge/Analysis-R-purple)]()

## 📌 Overview

This undergraduate research project examines the spatial and temporal variability, long-term trends, seasonal behavior, extreme precipitation characteristics, and interrelationships of selected climatic parameters across four districts of northwestern Bangladesh: **Rajshahi, Pabna, Natore, and Bogura**.

The study covers **51 years (1973–2023)** and analyzes four climatic parameters:

- Rainfall
- Temperature
- Relative humidity
- Wind speed

The study also examines **land use/land cover (LULC) change** across four reference years (1985, 1998, 2011, and 2023) to provide environmental context for the observed climatic variations.

---

## 🎯 Objectives

The study was designed around five objectives:

1. Analyze the spatial and temporal variations of selected climatic parameters and examine their association with LULC changes.

2. Assess long-term trends and the magnitude of changes in climatic parameters using the **Mann–Kendall trend test** and **Sen's slope estimator**.

3. Characterize seasonal and monthly variability and identify climatological patterns across the study area.

4. Assess extreme precipitation characteristics and estimate return levels using **Annual Maximum Series (AMS)** and **Generalized Extreme Value (GEV)** analysis.

5. Examine relationships among the climatic parameters using **Pearson, Spearman, and Kendall correlation analyses**.

---

## 🗺️ Study Area

The study covers four districts in northwestern Bangladesh:

- Rajshahi
- Pabna
- Natore
- Bogura

The climatic analysis covers the period **1973–2023**.

The study area was selected to provide a district-level comparison of climatic behavior within the broader northwestern region of Bangladesh.

![Study Area Map](figures/01-study-area/study-area.png)

---

## 📊 Data

### Meteorological Data

Monthly meteorological data for **1973–2023** were obtained from the **Bangladesh Agricultural Research Council (BARC)**.

| Parameter | Period | Temporal Resolution |
|---|---:|---|
| Rainfall | 1973–2023 | Monthly |
| Temperature | 1973–2023 | Monthly |
| Relative Humidity | 1973–2023 | Monthly |
| Wind Speed | 1973–2023 | Monthly |

Direct station observations were available for **Rajshahi, Bogura, and Pabna (Ishurdi)**.

Because a corresponding direct station record for Natore was unavailable in the dataset, climatic values for Natore were estimated using **Inverse Distance Weighted (IDW) interpolation** based on surrounding stations.

Annual rainfall was calculated from accumulated monthly rainfall, while annual temperature, relative humidity, and wind speed were calculated from the corresponding monthly means.

### LULC Data

LULC analysis was conducted for:

**1985 → 1998 → 2011 → 2023**

Four major classes were considered:

- Built-up area
- Water bodies
- Vegetation/forest
- Bare land

Agricultural land was not retained as a separate class because it could not be consistently distinguished from vegetation and bare land during interpretation of the Landsat imagery.

---

## 🔬 Methodology

The overall analytical workflow integrated spatial analysis, statistical trend assessment, climatological analysis, extreme-value analysis, correlation analysis, and LULC assessment.

![Methodological Framework](figures/02-methodological-framework/Methodological-framework.png)

### Climate Analysis

- Spatial thematic mapping
- Linear trend visualization
- Mann–Kendall trend test
- Sen's slope estimation
- Seasonal analysis
- Monthly climatology

### Extreme Precipitation Analysis

An **Annual Maximum Series (AMS)** was constructed by selecting the highest monthly rainfall value from each year.

The AMS was then analyzed using the **Generalized Extreme Value (GEV)** distribution.

The analysis included:

- GEV parameter estimation
- Anderson–Darling goodness-of-fit assessment
- Gringorten Q–Q diagnostics
- Return-level estimation
- 2-, 5-, 10-, 25-, 50-, and 100-year return periods
- 95% bootstrap confidence intervals

> **Important:** Because complete daily rainfall observations were not available for the study period, the extreme-value analysis represents **annual maximum monthly rainfall**, rather than conventional daily rainfall extremes.

### Correlation Analysis

Relationships among rainfall, temperature, relative humidity, and wind speed were examined using:

- Pearson correlation
- Spearman correlation
- Kendall correlation
- Correlation matrices
- Heat-map visualization

### LULC Analysis

Landsat imagery was classified using a supervised classification approach to identify the four major LULC classes. The resulting maps were compared across the four reference years to document broad changes in land-cover composition.

---

## 🛠️ Software & Tools

| Tool | Application |
|---|---|
| **ArcMap 10.8** | Study area mapping, thematic mapping, LULC classification and spatial analysis |
| **R** | Trend analysis, Mann–Kendall test, Sen's slope, GEV modelling, diagnostics, return levels and correlation analysis |
| **Microsoft Excel** | Data organization, preliminary processing and tabulation |

---

## 📈 Key Findings

### Climate Trends

- Annual rainfall showed a **decreasing tendency in all four districts**.
- The rainfall decline was statistically significant in **Natore, Pabna, and Rajshahi**, but not in Bogura.
- Sen's slope estimates ranged from approximately **−7.04 to −9.00 mm/year**.
- Rajshahi showed a statistically significant warming trend of approximately **+0.15°C per decade**.
- Temperature trends in Natore, Pabna, and Bogura were not statistically significant.
- Relative humidity increased significantly in **Natore, Pabna, and Rajshahi**, while the increase in Bogura was not significant.
- Wind speed decreased significantly in **Natore and Pabna**, while the trends in Rajshahi and Bogura were not statistically significant.

### Seasonal and Monthly Patterns

The four districts showed a strong seasonal climatic cycle.

- Rainfall was strongly concentrated during the **monsoon**.
- Monsoon rainfall ranged from approximately **1047.7 mm in Rajshahi to 1252.1 mm in Bogura**.
- Winter rainfall was comparatively low, at approximately **29–35 mm**.
- Temperature, relative humidity, and wind speed followed distinct seasonal patterns.

### Extreme Precipitation

- Annual maximum monthly rainfall showed decreasing trends across all four districts.
- The decline was statistically significant in **Rajshahi, Natore, and Pabna**, but not in Bogura.
- GEV models provided acceptable fits according to the Anderson–Darling assessment.
- Estimated return levels increased with longer return periods, but uncertainty also increased substantially, particularly for the 50- and 100-year estimates.
- The estimated 100-year return levels ranged from approximately **663.8 mm in Natore to 981.9 mm in Pabna**.

### LULC Change

Substantial changes in land-cover composition were observed between 1985 and 2023.

For example, in Rajshahi:

- Vegetation increased from **44.15% (1985)** to **64.34% (2023)**.
- Bare land decreased from **48.42%** to **12.24%**.
- Classified built-up area increased to **14.18% in 2023**.

The LULC results are interpreted as evidence of broad landscape change rather than exact measurements of individual land conversions.

### Climatic Relationships

The correlation analysis showed that climatic relationships were **spatially variable** rather than uniform across the four districts.

The regional mean showed a significant negative relationship between temperature and relative humidity:

**Pearson r = −0.307, p = 0.0285**

However, district-level relationships differed considerably, demonstrating the importance of examining climatic behavior at the district scale.

---

## 🌍 Integrated Interpretation

Overall, the study indicates that climatic behavior across northwestern Bangladesh is **spatially heterogeneous, strongly seasonal, and characterized by different long-term tendencies among districts**.

The LULC analysis provides environmental context for these climatic changes, while the correlation analysis demonstrates that the climatic variables themselves are interconnected.

The study does **not** establish that LULC change caused the observed climatic trends, nor does correlation analysis establish causal relationships.

---

## ⚠️ Limitations

Several limitations should be considered when interpreting the results:

- The GEV analysis is based on **monthly rather than daily rainfall data**.
- Natore climatic values were estimated using **IDW interpolation** rather than direct station observations.
- The standard Mann–Kendall test was applied without formal autocorrelation correction.
- LULC classification contains uncertainty, particularly for historical imagery and the separation of agricultural land from vegetation and bare land.
- Correlation analysis identifies statistical associations but does not establish causation.
- LULC was used as environmental context rather than as a direct causal explanatory variable.

---

## 📁 Repository Structure

```northwest-bangladesh-climate-lulc-analysis/
│
├── README.md
│
├── figures/
│   ├── 01-study-area/
│   ├── 02-analytical-framework/
│   ├── 03-climate-maps/
│   ├── 04-climate-trends/
│   ├── 05-climatology/
│   ├── 06-lulc/
│   ├── 07-extreme-precipitation/
│   └── 08-correlations/
│
├── scripts/
│   ├── trend-analysis/
│   ├── gev-analysis/
│   └── correlation-analysis/
│
├── results/
│   ├── tables/
│   └── summary/
│
├── gis/
│   ├── climate-maps/
│   └── lulc/
│
├── data/
│   └── README.md
│
├── thesis/
│   └── thesis.pdf
│
└── LICENSE
