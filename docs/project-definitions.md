# Project Definitions

## Tech Occupations

For this project, tech occupations are defined using the U.S. Bureau of Labor Statistics SOC major occupation group:

- 15-0000 Computer and Mathematical Occupations

Analysis will focus on detailed occupations within this group.


## Bay Area Metro Areas

For this project, the Bay Area is defined using the following BLS Metropolitan Statistical Areas (MSAs):

- San Francisco-Oakland-Fremont, CA
- San Jose-Sunnyvale-Santa Clara, CA
- Santa Rosa-Petaluma, CA
- Napa, CA
- Vallejo, CA
- Santa Cruz-Watsonville, CA

Reason:
These metropolitan areas represent the major labor markets and counties commonly associated with the San Francisco Bay Area.

## Employment Metrics

## Wage Metrics

## Data Quality Rules

- Missing values in PostgreSQL represent BLS non-published or suppressed estimates, not import errors.
- BLS symbols (`*`, `#`, `**`) were converted to `NULL` during data preparation.
- Do not impute or replace missing values with zero or averages.
- Filter by column when analyzing:
  - Employment rankings: `WHERE tot_emp IS NOT NULL`
  - Wage rankings: `WHERE a_median IS NOT NULL` (or `a_mean IS NOT NULL`)
  - Location quotient analysis: `WHERE loc_quotient IS NOT NULL`
- Suppressed employment may still have wage estimates, and vice versa; exclude only the metric that is missing.

## Exclusions

- Records with suppressed employment are excluded from employment totals and demand rankings only.
- Records without reported median annual wage are excluded from salary rankings only.
- No full rows are dropped from the database; exclusions apply per analysis query.