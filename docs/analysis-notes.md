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

## Highest-paying tech occupations

**Question:** Which technology occupations offer the highest median salaries?

**SQL:** `sql/analysis/03_highest_paying.sql`

**Filters:** `a_median IS NOT NULL` (88 of 89 records)

**Key findings:**

- **Single metro × occupation (median annual wage):** San Jose–Sunnyvale–Santa Clara dominates the top of the list. Highest: Computer and Information Research Scientists ($218,420), Software Developers ($213,110), Statisticians ($202,840), Web and Digital Interface Designers ($201,260), and Database Architects ($197,960). San Francisco appears at #6 with Software Developers ($186,640).
- **Bay Area-wide (average of metro medians):** Highest averages are Research Scientists (~$194,930; 2 metros) and Database Architects (~$186,910; 2 metros). Software Developers average ~$165,892 across all 6 metros — a more coverage-stable high-wage signal. Data Scientists average ~$135,410 across all 6 metros.
- **Coverage caution:** Some top-ranked occupation averages rely on 1–2 metros (e.g. Statisticians and Mathematical Science Occupations, All Other appear in only one metro). Those ranks are less representative Bay Area-wide than occupations reported in most metros.
- **Wages by metro:** San Jose has the highest average occupation median (~$166,036), followed by San Francisco (~$148,725). Smaller metros cluster lower: Santa Cruz (~$114,417), Vallejo (~$107,368), Santa Rosa (~$106,134), Napa (~$105,511).
- **Hourly view:** Rankings match annual medians. Top hourly medians in San Jose include Research Scientists ($105.01/hr) and Software Developers ($102.46/hr).

**Limitations:**

- 1 row excluded due to unpublished median wage (`a_median IS NULL`: Statisticians in San Francisco).
- Occupation-level averages treat each metro equally (not employment-weighted).
- Single survey year (2025); levels only, not wage growth over time.

## Bay Area tech concentration

**Question:** Which tech occupations are more concentrated locally than nationally?

**SQL:** `sql/analysis/04_tech_concentration.sql`

**Filters:** `loc_quotient IS NOT NULL` (87 of 89 records)

**Location quotient (LQ):** LQ > 1 means more concentrated than the U.S. average; LQ < 1 means less concentrated.

**Key findings:**

- **Single metro × occupation:** San Jose dominates high concentration. Top LQ values: Computer and Information Research Scientists (8.14), Software Developers (7.09), Web and Digital Interface Designers (5.32), Computer Occupations, All Other (5.25), and Software QA Analysts/Testers (4.76). San Francisco’s highest include Web/Digital Designers (3.83), Research Scientists (2.94), and Software Developers (2.68).
- **Bay Area-wide (average LQ across metros):** Research Scientists lead (~5.54; 2 metros). Among occupations reported in most metros, Software Developers average ~1.82 (6 metros; LQ > 1 in SF and San Jose only), followed by Computer Occupations, All Other (~1.69) and Data Scientists (~1.20).
- **By metro:** San Jose is the most tech-specialized (avg LQ ~2.78; 18 of 19 occupations above national). San Francisco is next (avg LQ ~1.74; 16 of 19 above national). Smaller metros are mostly below national: Santa Cruz (~0.81), Santa Rosa (~0.49), Vallejo (~0.40), Napa (~0.40). Santa Rosa, Vallejo, and Napa have **zero** occupations with LQ > 1 in this filtered set.
- **Below-national pockets:** Lowest LQ cells include Software Developers in Napa (0.15), Information Security Analysts in Santa Rosa (0.16), and Software Developers in Vallejo (0.21).

**Limitations:**

- 2 rows excluded due to suppressed LQ (`loc_quotient IS NULL`).
- Occupation-level average LQ treats each metro equally (not employment-weighted).
- LQ compares each metro to the national mix; it does not measure absolute job counts.
- Single survey year (2025).

## Metro comparison

**Question:** How does tech employment vary across Bay Area metros?

**SQL:** `sql/analysis/05_metro_comparison.sql`

**Key findings:**

- **Two-metro dominance:** San Francisco–Oakland–Fremont (~155,910 tech jobs; ~49.8% of Bay Area tech employment) and San Jose–Sunnyvale–Santa Clara (~149,950; ~47.9%) together account for about **97.7%** of reported Bay Area tech employment in this dataset. The other four metros combined are under 3%.
- **Scorecard contrast:** San Jose leads on wages (avg median ~$166,036) and specialization (avg LQ ~2.78). San Francisco leads on total headcount. Smaller metros have far lower employment and mostly below-national concentration.
- **Software Developers across metros:** San Jose (87,350 jobs; median $213,110; LQ 7.09) and San Francisco (69,030; $186,640; LQ 2.68) dwarf the rest. Outside the core, employment is small (130–560 jobs) and LQ is below 1 in every smaller metro.
- **Top-paying role by metro:** Research Scientists lead in San Jose ($218,420). Software Developers are the top-paying reported role in San Francisco, Santa Cruz, Santa Rosa, and Napa. Vallejo’s highest median is Information Security Analysts ($137,160).
- **Most concentrated role by metro:** San Jose Research Scientists (LQ 8.14); San Francisco Web/Digital Designers (3.83); Santa Cruz Computer Programmers (1.59). In Santa Rosa, Vallejo, and Napa, even the “most concentrated” roles stay at or below national (LQ ≤ 1).

**Limitations:**

- BLS reports metropolitan areas (MSAs), not counties.
- Occupation coverage differs by metro (7 occupations in Napa vs 19–20 in the core metros).
- Average wage/LQ metrics are not employment-weighted.
- Single survey year (2025); no trend comparison yet.

## Interactive viz (Tableau Public) 
Dashboard: <https://public.tableau.com/app/profile/habtom.hailay/viz/Bay_Area_Tech_Jobs_Viz/BayAreaTechJobs>
