-- Step 2: Highest-demand tech occupations
-- Question: Which technology occupations have the highest employment?
-- Database: bayarea_tech_jobs_db
-- Table: bay_area_jobs.tech_jobs
-- Filter: tot_emp IS NOT NULL (87 of 89 records)

SET search_path TO bay_area_jobs, public;

-- Top 10 metro x occupation by total employment
SELECT
    area_title,
    occ_code,
    occ_title,
    tot_emp,
    jobs_1000
FROM tech_jobs
WHERE tot_emp IS NOT NULL
ORDER BY tot_emp DESC
LIMIT 10;

-- Top 10 occupations Bay Area-wide (sum employment across metros)
SELECT
    occ_code,
    occ_title,
    SUM(tot_emp) AS total_employment,
    COUNT(*) AS metros_reporting
FROM tech_jobs
WHERE tot_emp IS NOT NULL
GROUP BY occ_code, occ_title
ORDER BY total_employment DESC
LIMIT 10;

-- Total tech employment by metro
SELECT
    area_title,
    SUM(tot_emp) AS total_tech_employment,
    COUNT(*) FILTER (WHERE tot_emp IS NOT NULL) AS occupations_reporting
FROM tech_jobs
GROUP BY area_title
ORDER BY total_tech_employment DESC NULLS LAST;

-- Jobs per 1,000 (labor market density) — topr 10 metro x occupation
SELECT
    area_title,
    occ_title,
    jobs_1000,
    tot_emp
FROM tech_jobs
WHERE jobs_1000 IS NOT NULL
ORDER BY jobs_1000 DESC
LIMIT 10;
