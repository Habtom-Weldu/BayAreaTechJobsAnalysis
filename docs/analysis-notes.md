# Analysis Notes

**SQL:** `sql/analysis/01_data_validation.sql`

## Data validation (PostgreSQL)

- Source table: `bay_area_jobs.tech_jobs`
  **Key findings:**
   - 89 rows loaded; 6 metros and 20 occupations covered (survey year 2025).
   - Missing values: tot_emp (2), loc_quotient (2), a_median (1).
   - No duplicate metro–occupation rows.
  **Limitations:**
   - 3 records with BLS suppressed or unpublished values (see affected records table). 

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

## Highest-demand tech occupations

**Question:** Which technology occupations have the highest employment in the Bay Area?

**SQL:** `sql/analysis/02_highest_demand.sql`

**Filters:** `tot_emp IS NOT NULL` (87 of 89 records)

**Key findings:**

- **Bay Area-wide (summed across metros):** Software Developers rank first (157,940 jobs across all 6 metros). Next highest: Computer Occupations, All Other (34,490); Computer Systems Analysts (19,550); Computer User Support Specialists (17,780); Data Scientists (16,830).
- **Single metro × occupation:** The two largest individual estimates are Software Developers in San Jose–Sunnyvale–Santa Clara (87,350) and San Francisco–Oakland–Fremont (69,030). Together these two cells account for roughly 99,400 jobs — about 63% of Bay Area-wide Software Developer employment.
- **Employment by metro:** San Francisco–Oakland–Fremont (155,910; 19 occupations) and San Jose–Sunnyvale–Santa Clara (149,950; 19 occupations) dominate. Smaller metros report far less: Santa Rosa (2,850), Santa Cruz (2,070), Vallejo (1,690), and Napa (640).
- **Labor market density (`jobs_1000`):** Software Developers in San Jose have the highest concentration (76.962 jobs per 1,000), nearly 2.7× San Francisco (29.078) for the same occupation. Santa Cruz shows relatively high density for Software Developers (5.533) despite a much smaller headcount (540 jobs).
- **Coverage note:** Some occupations appear in fewer metros at the top of the rankings (e.g. Information Security Analysts in 4 metros, QA and Web Designers in 5), reflecting where BLS reports employment for those roles.

**Limitations:**

- 2 rows excluded due to suppressed employment (`tot_emp IS NULL`).
- Employment is reported by MSA, not county.
- Single survey year (2025); this analysis reflects current levels, not growth over time.
