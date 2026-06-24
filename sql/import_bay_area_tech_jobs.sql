-- Import data/processed/bay_area_tech_jobs.csv into bay_area_jobs.tech_jobs
--
-- Prerequisites:
--   1. psql -f sql/schema.sql
--   2. From repo root:
--      psql ... -c "\copy bay_area_jobs.staging_bay_area_tech_jobs FROM 'data/processed/bay_area_tech_jobs.csv' WITH (FORMAT csv, HEADER true, QUOTE '\"', ESCAPE '\"')"
--   3. psql ... -f sql/import_bay_area_tech_jobs.sql
--
-- survey_year 2025 matches BLS release M2025. Change when loading other years.

BEGIN;

SET search_path TO bay_area_jobs, public;

INSERT INTO tech_jobs (
    survey_year,
    area_code,
    area_title,
    occ_code,
    occ_title,
    tot_emp,
    jobs_1000,
    loc_quotient,
    h_mean,
    a_mean,
    h_median,
    a_median
)
SELECT
    2025 AS survey_year,
    s.area::INTEGER AS area_code,
    s.area_title,
    s.occ_code,
    s.occ_title,
    bls_text_to_numeric(s.tot_emp),
    bls_text_to_numeric(s.jobs_1000),
    bls_text_to_numeric(s.loc_quotient),
    bls_text_to_numeric(s.h_mean),
    bls_text_to_numeric(s.a_mean),
    bls_text_to_numeric(s.h_median),
    bls_text_to_numeric(s.a_median)
FROM staging_bay_area_tech_jobs AS s
ON CONFLICT (survey_year, area_code, occ_code) DO UPDATE
SET
    area_title = EXCLUDED.area_title,
    occ_title = EXCLUDED.occ_title,
    tot_emp = EXCLUDED.tot_emp,
    jobs_1000 = EXCLUDED.jobs_1000,
    loc_quotient = EXCLUDED.loc_quotient,
    h_mean = EXCLUDED.h_mean,
    a_mean = EXCLUDED.a_mean,
    h_median = EXCLUDED.h_median,
    a_median = EXCLUDED.a_median;

TRUNCATE staging_bay_area_tech_jobs;

COMMIT;

SELECT COUNT(*) AS tech_jobs_row_count FROM tech_jobs;
