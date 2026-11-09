-- Step 5: Metro comparison
-- Question: How does tech employment vary across Bay Area metros?
-- Database: bayarea_tech_jobs_db
-- Table: bay_area_jobs.tech_jobs
-- Note: BLS reports MSAs (metros), not counties.

SET search_path TO bay_area_jobs, public;

-- 1. Metro scorecard: employment, wages, and concentration side by side
SELECT
    area_title,
    COUNT(*) AS occupations_reported,
    SUM(tot_emp) AS total_tech_employment,
    ROUND(AVG(a_median), 1) AS avg_median_wage,
    ROUND(AVG(loc_quotient), 2) AS avg_loc_quotient,
    COUNT(*) FILTER (WHERE loc_quotient > 1) AS occupations_above_national
FROM tech_jobs
GROUP BY area_title
ORDER BY total_tech_employment DESC NULLS LAST;

-- 2. Share of Bay Area tech employment by metro

/* In this below query, 
The inner SUM(tot_emp)
Group aggregate → tech employment for that metro.

Outer SUM(...) OVER ()
Window function → adds those metro totals across all metros (Bay Area grand total).
OVER () with empty parentheses means “over the whole result set.” */

SELECT
    area_title,
    SUM(tot_emp) AS total_tech_employment,
    ROUND(
        100.0 * SUM(tot_emp)
        / NULLIF(SUM(SUM(tot_emp)) OVER (), 0),
        1
    ) AS pct_of_bay_area_tech_jobs
FROM tech_jobs
WHERE tot_emp IS NOT NULL
GROUP BY area_title
ORDER BY total_tech_employment DESC;

-- 3. Software Developers across metros (largest occupation)
SELECT
    area_title,
    tot_emp,
    a_median,
    loc_quotient,
    jobs_1000
FROM tech_jobs
WHERE occ_code = '15-1252'
ORDER BY tot_emp DESC NULLS LAST;

-- 4. Top-paying occupation in each metro
/* In this query,
Sorting puts the top paying occupation first per metro; 
DISTINCT ON keeps that first row.*/

SELECT DISTINCT ON (area_title)
    area_title,
    occ_title,
    a_median,
    tot_emp
FROM tech_jobs
WHERE a_median IS NOT NULL
ORDER BY area_title, a_median DESC;

-- 5.Most concentrated occupation in each metro (LQ)
SELECT DISTINCT ON (area_title)
    area_title,
    occ_title,
    loc_quotient,
    tot_emp
FROM tech_jobs
WHERE loc_quotient IS NOT NULL
ORDER BY area_title, loc_quotient DESC;
