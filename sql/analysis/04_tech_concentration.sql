-- Step 4: Bay Area tech concentration
-- Question: Which tech occupations are more concentrated locally than nationally?
-- Database: bayarea_tech_jobs_db
-- Table: bay_area_jobs.tech_jobs
-- Filter: loc_quotient IS NOT NULL (87 of 89 records)
--
-- Location quotient (LQ):
--   LQ > 1  = more concentrated than the U.S. average
--   LQ = 1  = same concentration as the U.S. average
--   LQ < 1  = less concentrated than the U.S. average

SET search_path TO bay_area_jobs, public;

-- Top 10 metro x occupation by location quotient
SELECT
    area_title,
    occ_code,
    occ_title,
    loc_quotient,
    tot_emp,
    jobs_1000
FROM tech_jobs
WHERE loc_quotient IS NOT NULL
ORDER BY loc_quotient DESC
LIMIT 10;

-- Occupations with above-average concentration (LQ > 1), Bay Area-wide
-- Average LQ across metros, and count how many metros have LQ > 1
SELECT
    occ_code,
    occ_title,
    ROUND(AVG(loc_quotient), 2) AS avg_loc_quotient,
    COUNT(*) FILTER (WHERE loc_quotient > 1) AS metros_above_national,
    COUNT(*) AS metros_reporting,
    SUM(tot_emp) AS total_employment
FROM tech_jobs
WHERE loc_quotient IS NOT NULL
GROUP BY occ_code, occ_title
ORDER BY avg_loc_quotient DESC
LIMIT 10;

-- How concentrated is tech overall in each metro?
-- Share of occupation rows with LQ > 1, plus average LQ
SELECT
    area_title,
    COUNT(*) FILTER (WHERE loc_quotient IS NOT NULL) AS occupations_reporting,
    COUNT(*) FILTER (WHERE loc_quotient > 1) AS occupations_above_national,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE loc_quotient > 1)
        / NULLIF(COUNT(*) FILTER (WHERE loc_quotient IS NOT NULL), 0),
        1
    ) AS pct_above_national,
    ROUND(AVG(loc_quotient), 2) AS avg_loc_quotient
FROM tech_jobs
GROUP BY area_title
ORDER BY avg_loc_quotient DESC NULLS LAST;

-- Below-average concentration (LQ < 1): where tech is thinner than national
SELECT
    area_title,
    occ_title,
    loc_quotient,
    tot_emp
FROM tech_jobs
WHERE loc_quotient IS NOT NULL
  AND loc_quotient < 1
ORDER BY loc_quotient ASC
LIMIT 10;
