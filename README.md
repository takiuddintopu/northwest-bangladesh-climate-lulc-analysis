# Spatiotemporal Variability and Trends in Climatic Parameters and Their Association with Extreme Precipitation and Land Use/Land Cover Change in Northwest Bangladesh

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

### Study Area Map

![Study Area Map](figures/01-study-area/study-area-map.png)

---

### Methodological Framework

The study followed an integrated analytical framework combining spatial analysis, statistical trend assessment, climatological analysis, extreme-value analysis, correlation analysis, and LULC assessment.


![Methodological Framework](figures/02-methodological-framework/methodological-framework-diagram.png)

---

# 📊 Data

## Meteorological Data

Monthly meteorological data for **1973–2023** were obtained from the **Bangladesh Agricultural Research Council (BARC)**.

| Parameter | Period | Temporal Resolution |
|---|---:|---|
|Rainfall | 1973–2023 | Monthly |
| Temperature | 1973–2023 | Monthly |
| Relative Humidity | 1973–2023 | Monthly |
| Wind Speed | 1973–2023 | Monthly |

Direct station observations were available for **Rajshahi, Bogura, and Pabna (Ishurdi)**.

Because a corresponding direct station record for Natore was unavailable in the dataset, climatic values for Natore were estimated using **Inverse Distance Weighted (IDW) interpolation** based on surrounding stations.

Annual rainfall was calculated from accumulated monthly rainfall, while annual temperature, relative humidity, and wind speed were calculated from the corresponding monthly means.

---

## LULC Data

LULC analysis was conducted for four reference years:

**1985 → 1998 → 2011 → 2023**

Four major classes were considered:

- Built-up area
- Water bodies
- Vegetation/forest
- Bare land

Agricultural land was not retained as a separate class because it could not be consistently distinguished from vegetation and bare land during interpretation of the Landsat imagery.

---

# 🛠️ Methodology

## Climate Analysis

The climatic analysis included:

- Spatial thematic mapping
- Linear trend visualization
- Mann–Kendall trend testing
- Sen's slope estimation
- Seasonal analysis
- Monthly climatology

---

## 🗺️ Spatial Distribution of Climatic Parameters

The spatial distribution of the climatic parameters was examined across the four study districts.

### Annual Rainfall

![Thematic Map of Rainfall](figures/03-climate-maps/thematic-map-rainfall.png)

### Mean Temperature

![Thematic Map of Temperature](figures/03-climate-maps/thematic-map-temp.png)

### Relative Humidity

![Thematic Map of Relative Humidity](figures/03-climate-maps/thematic-map-humidity.png)

### Wind Speed

![Thematic Map of Wind Speed](figures/03-climate-maps/thematic-map-wind.png)

---

# 📈 Long-Term Climate Trends

Long-term trends in rainfall, temperature, relative humidity, and wind speed were evaluated using the **Mann–Kendall trend test** and **Sen's slope estimator**.

## Annual Rainfall Trend

![Annual Rainfall Mann-Kendall Trend](figures/04-climate-trends/rainfall-mannkendall-trend.png)

## Mean Temperature Trend

![Mean Temperature Mann-Kendall Trend](figures/04-climate-trends/meantemp-mannkendall-trend.png)

## Relative Humidity Trend

![Relative Humidity Mann-Kendall Trend](figures/04-climate-trends/humidity-mannkendall-trend.png)

## Wind Speed Trend

![Wind Speed Mann-Kendall Trend](figures/04-climate-trends/windspeed-mannkendall-trend.png)

---

# 🌦️ Seasonal and Monthly Climatology

The seasonal and monthly behavior of the climatic parameters was examined to characterize the climatological patterns across the study area.

## Monthly Rainfall Climatology

![Monthly Rainfall Climatology](figures/06-seasonal-climatology/rainfall_monthly-climatology.png)

## Monthly Temperature Climatology

![Monthly Temperature Climatology](figures/06-seasonal-climatology/temperature-monthly-climatology.png)

## Monthly Relative Humidity Climatology

![Monthly Humidity Climatology](figures/06-seasonal-climatology/humidity-monthly-climatology.png)

## Monthly Wind Speed Climatology

![Monthly Wind Speed Climatology](figures/06-seasonal-climatology/windspeed-monthly-climatology.png)

The climatic variables exhibit a strong seasonal cycle, with rainfall concentrated mainly during the monsoon season and substantially lower rainfall during winter.

---

# 🌳 Land Use/Land Cover Change

LULC analysis was conducted using Landsat imagery for four reference years: **1985, 1998, 2011, and 2023**.

A supervised classification approach was used to identify major land-cover categories and compare their composition across the study period.

Four major classes were considered:

- Built-up area
- Water bodies
- Vegetation/forest
- Bare land

Agricultural land was not retained as a separate class because it could not be consistently distinguished from vegetation and bare land during interpretation of the Landsat imagery.

## Rajshahi

![Rajshahi LULC Change](figures/05-lulc/rajshahi-lulc.png)

## Pabna

![Pabna LULC Change](figures/05-lulc/pabna-lulc.png)

## Natore

![Natore LULC Change](figures/05-lulc/natore-lulc.png)

## Bogura

![Bogura LULC Change](figures/05-lulc/bogura-lulc.png)

The LULC results are interpreted as evidence of broad landscape change rather than exact measurements of individual land conversions.

---

# 🌧️ Extreme Precipitation Analysis

Extreme precipitation characteristics were assessed using an **Annual Maximum Series (AMS)** and the **Generalized Extreme Value (GEV)** distribution.

Because complete daily rainfall observations were not available for the full study period, the AMS was constructed by selecting the **maximum monthly rainfall value from each year**.

Therefore, the extreme-value analysis represents **annual maximum monthly rainfall**, rather than conventional daily rainfall extremes.

## Annual Maximum Series Trends

![AMS Rainfall Trends](figures/07-extreme-precipitation/ams-trends.png)

## GEV Q-Q Diagnostics

![GEV Q-Q Diagnostics](figures/07-extreme-precipitation/gev-qq-diagnostics.png)

## GEV Return Levels

![GEV Return Levels](figures/07-extreme-precipitation/gev-return-levels.png)

The GEV analysis included:

- GEV parameter estimation
- Anderson–Darling goodness-of-fit assessment
- Gringorten Q-Q diagnostics
- Return-level estimation
- 2-, 5-, 10-, 25-, 50-, and 100-year return periods
- 95% bootstrap confidence intervals

The estimated return levels increase with longer return periods, while uncertainty becomes greater at longer return periods, particularly for the 50- and 100-year estimates.

---

# 📊 Correlation Analysis

Relationships among rainfall, temperature, relative humidity, and wind speed were examined using:

- Pearson correlation
- Spearman correlation
- Kendall correlation
- Correlation matrices
- Heat-map visualization

## Regional Mean Pearson Correlation

![Regional Mean Pearson Correlation Heatmap](figures/08-correlations/regional-mean-pearson-heatmap.png)

## District-Level Pearson Correlations

![Combined Four District Pearson Correlation Heatmap](figures/08-correlations/combined-4-district-pearson-heatmap.png)

The correlation analysis indicates that relationships among climatic variables vary spatially across the four districts.

The regional mean showed a significant negative relationship between temperature and relative humidity:

**Pearson r = −0.307, p = 0.0285**

These relationships represent statistical associations and should not be interpreted as evidence of direct causal relationships.

---

# 📈 Key Findings

## Climate Trends

- Annual rainfall showed a **decreasing tendency in all four districts**.
- The rainfall decline was statistically significant in **Natore, Pabna, and Rajshahi**, but not in Bogura.
- Sen's slope estimates ranged from approximately **−7.04 to −9.00 mm/year**.
- Rajshahi showed a statistically significant warming trend of approximately **+0.15°C per decade**.
- Temperature trends in Natore, Pabna, and Bogura were not statistically significant.
- Relative humidity increased significantly in **Natore, Pabna, and Rajshahi**, while the increase in Bogura was not statistically significant.
- Wind speed decreased significantly in **Natore and Pabna**, while the trends in Rajshahi and Bogura were not statistically significant.

---

## Seasonal and Monthly Patterns

The four districts showed a strong seasonal climatic cycle.

- Rainfall was strongly concentrated during the **monsoon**.
- Monsoon rainfall ranged from approximately **1047.7 mm in Rajshahi to 1252.1 mm in Bogura**.
- Winter rainfall was comparatively low, at approximately **29–35 mm**.
- Temperature, relative humidity, and wind speed followed distinct seasonal patterns.

---

## Extreme Precipitation

- Annual maximum monthly rainfall showed decreasing trends across all four districts.
- The decline was statistically significant in **Rajshahi, Natore, and Pabna**, but not in Bogura.
- GEV models provided acceptable fits according to the Anderson–Darling assessment.
- Estimated return levels increased with longer return periods, while uncertainty also increased substantially at longer return periods.
- The estimated 100-year return levels ranged from approximately **663.8 mm in Natore to 981.9 mm in Pabna**.

---

## LULC Change

Substantial changes in land-cover composition were observed between 1985 and 2023.

For example, in Rajshahi:

- Vegetation increased from **44.15% (1985)** to **64.34% (2023)**.
- Bare land decreased from **48.42%** to **12.24%**.
- Classified built-up area increased to **14.18% in 2023**.

The LULC results are interpreted as broad landscape-level changes rather than exact measurements of individual land conversions.

---

## Climatic Relationships

The correlation analysis showed that climatic relationships were **spatially variable** rather than uniform across the four districts.

The regional mean showed a significant negative relationship between temperature and relative humidity:

**Pearson r = −0.307, p = 0.0285**

The district-level relationships differed considerably, demonstrating the importance of examining climatic behavior at the district scale.

---

# 🌍 Integrated Interpretation

Overall, the study indicates that climatic behavior across northwestern Bangladesh is **spatially heterogeneous, strongly seasonal, and characterized by different long-term tendencies among districts**.

The LULC analysis provides environmental context for these climatic changes, while the correlation analysis demonstrates that the climatic variables themselves are statistically interconnected.

However, the study does **not establish that LULC change caused the observed climatic trends**, and the correlation analysis does not establish causal relationships.

---

# ⚠️ Limitations

Several limitations should be considered when interpreting the results:

- The GEV analysis is based on **monthly rather than daily rainfall data**.
- Natore climatic values were estimated using **IDW interpolation** rather than direct station observations.
- The standard Mann–Kendall test was applied without formal autocorrelation correction.
- LULC classification contains uncertainty, particularly for historical imagery and the separation of agricultural land from vegetation and bare land.
- Correlation analysis identifies statistical associations but does not establish causation.
- LULC was used as environmental context rather than as a direct causal explanatory variable.

---

# 🛠️ Software and Tools

| Tool | Application |
|---|---|
| **ArcMap 10.8** | Study area mapping, thematic mapping, LULC classification and spatial analysis |
| **R** | Trend analysis, Mann–Kendall test, Sen's slope, GEV modelling, diagnostics, return levels and correlation analysis |
| **Microsoft Excel** | Data organization, preliminary processing and tabulation |

---

# 📁 Repository Structure

```text
northwest-bangladesh-climate-lulc-trends/
│
├── README.md
│
├── figures/
│   │
│   ├── 01-study-area/
│   │   └── study area map.png
│   │
│   ├── 02-methodological-framework/
│   │   └── Methodological_Framework_Diagram.png
│   │
│   ├── 03-climate-maps/
│   │   ├── themetic map humidity.png
│   │   ├── themetic map rainfall.png
│   │   ├── themetic map wind.png
│   │   └── themetic map temp.png
│   │
│   ├── 04-climate-trends/
│   │   ├── Humidity_MannKendall_Trend.png
│   │   ├── WindSpeed_MannKendall_Trend.png
│   │   ├── MeanTemp_MannKendall_Trend.png
│   │   └── Rainfall_MannKendall_Trend.png
│   │
│   ├── 05-lulc/
│   │   ├── Bogura_LULC.png
│   │   ├── Natore_LULC.png
│   │   ├── Pabna_LULC.png
│   │   └── Rajshahi_LULC.png
│   │
│   ├── 06-seasonal-climatology/
│   │   ├── Humidity_MonthlyClimatology.png
│   │   ├── Rainfall_MonthlyClimatology.png
│   │   ├── WindSpeed_MonthlyClimatology.png
│   │   └── Temperature_MonthlyClimatology.png
│   │
│   ├── 07-extreme-precipitation/
│   │   ├── AMS_Trends.png
│   │   ├── GEV_QQ_Diagnostics.png
│   │   └── GEV_ReturnLevels.png
│   │
│   └── 08-correlations/
│       ├── Combined_4District_Pearson_Heatmap.png
│       └── Regional_Mean_Pearson_Heatmap.png
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
