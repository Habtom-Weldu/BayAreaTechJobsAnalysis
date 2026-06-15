## Dataset Exploration

### Dataset
MSA_M2025_dl.xlsx

## Dataset Overview

- Source: BLS OEWS Metropolitan Area Employment and Wage Estimates
- Rows: 150,023
- Columns: 32

## Bay Area Scope

Selected metro areas:
- San Francisco-Oakland-Fremont, CA
- San Jose-Sunnyvale-Santa Clara, CA
- Santa Rosa-Petaluma, CA
- Napa, CA
- Vallejo, CA
- Santa Cruz-Watsonville, CA

Bay Area subset:
- Rows: 2,824

## Tech Occupation Definition

- BLS SOC Major Group: 15-0000 Computer and Mathematical Occupations

Tech subset:
- Rows: 95

### Initial Findings

- 150023 rows
- 32 columns
- Includes metropolitan areas across the U.S.
- Bay Area metros found:
  - San Francisco-Oakland-Fremont
  - San Jose-Sunnyvale-Santa Clara
  - Santa Rosa-Petaluma, CA
  - Napa, CA
  - Santa Cruz-Watsonville, CA
  - Vallejo, CA
- Columns with Null Value
  - PCT_TOTAL       150023
  - PCT_RPT         150023
  - ANNUAL          142176
  - HOURLY          149761
- Occupation groups (O_GROUP)
  - detailed    141015
  - major         8615
  - total          393
  - dtype: int64
- Industry Groups (I_GROUP)
  - cross-industry    150023
  - dtype: int64
- Tech occupations...
- Bay Area rows
  - (2824, 32)

### Data Quality Findings

The following fields were imported as object types instead of numeric:

- TOT_EMP
- JOBS_1000
- LOC_QUOTIENT
- H_MEAN
- A_MEAN
- H_MEDIAN
- A_MEDIAN

Investigation revealed that BLS uses special symbols such as:

- *
- #

These values prevent automatic numeric conversion and will require cleaning during the Prepare phase.

### Potentially Useful Columns

- AREA_TITLE
- OCC_CODE
- OCC_TITLE
- TOT_EMP
- A_MEAN
- A_MEDIAN
- LOC_QUOTIENT

## Cleaning Actions

- Filtered Bay Area metro areas.
- Filtered SOC 15 occupations.
- Removed major occupation rows.
- Removed empty columns (PCT_TOTAL, PCT_RPT).
- Replaced * and # with missing values.
- Converted wage and employment fields to numeric types.

## Non useful columns

 - After filternig the Bay Area metro areas the columns 'Hourly' and 'Annually' are discovered non-usefull as these columns have no values.
