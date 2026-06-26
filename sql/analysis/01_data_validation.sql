-- Step 1: Data validation
-- Database: bayarea_tech_jobs_db
-- Table: bay_area_jobs.tech_jobs

SET search_path TO bay_area_jobs, public;

-- Row count (expect 89)
SELECT COUNT(*) AS total_rows
FROM tech_jobs;

-- Coverage
SELECT
    COUNT(DISTINCT area_code) AS metro_count,
    COUNT(DISTINCT occ_code) AS occupation_count,
    MIN(survey_year) AS survey_year
FROM tech_jobs;

-- Missing values on key analysis columns
SELECT
    COUNT(*) FILTER (WHERE tot_emp IS NULL) AS missing_tot_emp,
    COUNT(*) FILTER (WHERE jobs_1000 IS NULL) AS missing_jobs_1000,
    COUNT(*) FILTER (WHERE loc_quotient IS NULL) AS missing_loc_quotient,
    COUNT(*) FILTER (WHERE a_median IS NULL) AS missing_a_median,
    COUNT(*) FILTER (WHERE a_mean IS NULL) AS missing_a_mean
FROM tech_jobs;

-- Rows with any missing value on key columns
SELECT
    area_title,
    occ_code,
    occ_title,
    tot_emp,
    loc_quotient,
    a_median
FROM tech_jobs
WHERE tot_emp IS NULL
   OR loc_quotient IS NULL
   OR a_median IS NULL
ORDER BY area_title, occ_code;

-- Duplicate check (expect 0 rows)
SELECT
    survey_year,
    area_code,
    occ_code,
    COUNT(*) AS row_count
FROM tech_jobs
GROUP BY survey_year, area_code, occ_code
HAVING COUNT(*) > 1;
