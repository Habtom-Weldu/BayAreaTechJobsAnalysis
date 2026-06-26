# Analysis Notes

## Data validation (PostgreSQL)

- Source table: `bay_area_jobs.tech_jobs`
- Total records: 89 (6 metros × 20 occupations, survey year 2025)
- Missing values after import:
  - `tot_emp`: 2
  - `loc_quotient`: 2
  - `a_median`: 1

## Affected records

| Metro | OCC code | Occupation | Missing fields | Notes |
|-------|----------|------------|----------------|-------|
| San Francisco-Oakland-Fremont, CA | 15-2099 | Mathematical Science Occupations, All Other | `tot_emp`, `loc_quotient` | BLS employment suppression (`**`) |
| Santa Rosa-Petaluma, CA | 15-1254 | Web Developers | `tot_emp`, `loc_quotient` | BLS employment suppression (`**`) |
| San Francisco-Oakland-Fremont, CA | 15-2041 | Statisticians | `a_median` (and related wage fields) | Wage not published for this metro–occupation |

## Analysis impact

- **Highest employment / demand:** 87 of 89 records used (`tot_emp IS NOT NULL`).
- **Highest median salary:** 88 of 89 records used (`a_median IS NOT NULL`).
- **Location quotient:** 87 of 89 records used (`loc_quotient IS NOT NULL`).
- Impact on top-10 rankings is expected to be minimal given the small number of affected rows.
