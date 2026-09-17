# Data

This directory documents the datasets used in the analysis. The original
datasets are not included in this repository.

---
## 1. Meteorological Data

Monthly meteorological data for the period **1973–2023** were obtained from
the **Bangladesh Agricultural Research Council (BARC)**.

The analysis included four climatic parameters:

- Rainfall
- Temperature
- Relative humidity
- Wind speed

### Study Districts

The analysis covered four districts of northwest Bangladesh:

- Rajshahi
- Pabna
- Natore
- Bogura

Direct station observations were used for Rajshahi, Pabna, and Bogura.
Because a direct meteorological station record was not available for Natore,
the corresponding values were estimated using **Inverse Distance Weighting
(IDW)** based on surrounding stations.

### Temporal Processing

- **Rainfall:** monthly accumulated rainfall
- **Temperature:** monthly mean temperature
- **Relative humidity:** monthly mean relative humidity
- **Wind speed:** monthly mean wind speed

The climate analysis covers the period **1973–2023 (51 years)**.

---
## 2. Satellite Data

Landsat satellite imagery was used for land-use/land-cover (LULC) analysis.

LULC maps were produced for four representative years:

- 1985
- 1998
- 2011
- 2023

The analysis used the following broad land-cover categories:

- Built-up
- Water
- Vegetation
- Bare land

The LULC classification was designed to maintain consistency across the
selected years.

---
## 3. Data Availability

The raw meteorological and satellite datasets are not stored in this
repository.

This repository contains the **analysis outputs, documentation, and
supporting workflow materials** rather than redistributing the original
datasets.

Researchers interested in reproducing the analysis should obtain the
appropriate source datasets directly from their respective data providers
and follow the methodology documented in this repository.

---
## 4. Data Limitations

A complete daily meteorological record covering the entire 1973–2023 study
period was not available for this analysis. Therefore, the extreme
precipitation analysis was based on **annual maximum monthly rainfall
(AMS)** rather than conventional annual maximum daily rainfall.

Consequently, the GEV results should be interpreted as characteristics of
extreme monthly rainfall, not daily rainfall extremes.

The absence of a direct meteorological station record for Natore also
required spatial estimation using IDW.

---
