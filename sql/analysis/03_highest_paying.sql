-- Step 3: Highest-paying tech occupations
-- Question: Which technology occupations offer the highest median salaries?
-- Database: bayarea_tech_jobs_db
-- Table: bay_area_jobs.tech_jobs
-- Filter: a_median IS NOT NULL (88 of 89 records)

SET search_path TO bay_area_jobs, public;

-- Top 10 metro x occupation by median annual wage
-- Highest annual median wages for each specific occupation in each specific metro area.
SELECT
    area_title,
    occ_code,
    occ_title,
    a_median,
    a_mean,
    tot_emp
FROM tech_jobs
WHERE a_median IS NOT NULL
ORDER BY a_median DESC
LIMIT 10;

-- Highest hourly median wages (metro x occupation)
-- i.e.The highest hourly median wage for each specific occupation in each specific metro area.
SELECT
    area_title,
    occ_title,
    h_median,
    a_median,
    tot_emp
FROM tech_jobs
WHERE h_median IS NOT NULL
ORDER BY h_median DESC
LIMIT 10;

-- Top 10 occupations Bay Area-wide (average of metro median wages)
-- i.e. based on the average of their metro-level median wages.
SELECT
    occ_code,
    occ_title,
    SUM(tot_emp) AS total_employees,
    ROUND(AVG(a_median), 1) AS avg_metro_median_wage,
    ROUND(AVG(a_mean), 1) AS avg_metro_mean_wage,
    COUNT(*) AS metros_reporting
FROM tech_jobs
WHERE a_median IS NOT NULL
GROUP BY occ_code, occ_title
ORDER BY avg_metro_median_wage DESC
LIMIT 10;

-- Median annual wage by metro (average across occupations in each metro)
-- i.e. the average annual median wage across occupations within each Bay Area metro
SELECT
    area_title,
    ROUND(AVG(a_median), 1) AS avg_occupation_median_wage,
    ROUND(AVG(a_mean), 1) AS avg_occupation_mean_wage,
    COUNT(*) FILTER (WHERE a_median IS NOT NULL) AS occupations_reporting
FROM tech_jobs
GROUP BY area_title
ORDER BY avg_occupation_median_wage DESC NULLS LAST;
