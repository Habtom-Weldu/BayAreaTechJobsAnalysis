-- Bay Area tech jobs — PostgreSQL schema
-- Source: data/processed/bay_area_tech_jobs.csv (BLS OEWS M2025, filtered)

BEGIN;

CREATE SCHEMA IF NOT EXISTS bay_area_jobs;
SET search_path TO bay_area_jobs, public;

CREATE OR REPLACE FUNCTION bls_text_to_numeric(input_text TEXT)
RETURNS NUMERIC
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT CASE
        WHEN input_text IS NULL THEN NULL
        WHEN btrim(input_text) = '' THEN NULL
        WHEN btrim(input_text) ~ '^[*#]+$' THEN NULL
        ELSE btrim(input_text)::NUMERIC
    END;
$$;

CREATE TABLE tech_jobs (
    id           SERIAL PRIMARY KEY,
    survey_year  INTEGER NOT NULL DEFAULT 2025,
    area_code    INTEGER NOT NULL,
    area_title   TEXT NOT NULL,
    occ_code     VARCHAR(10) NOT NULL,
    occ_title    TEXT NOT NULL,
    tot_emp      NUMERIC(12, 1),
    jobs_1000    NUMERIC(8, 3),
    loc_quotient NUMERIC(6, 2),
    h_mean       NUMERIC(8, 2),
    a_mean       NUMERIC(10, 1),
    h_median     NUMERIC(8, 2),
    a_median     NUMERIC(10, 1),
    CONSTRAINT tech_jobs_natural_key UNIQUE (survey_year, area_code, occ_code),
    CONSTRAINT tech_jobs_survey_year_check CHECK (survey_year >= 2000),
    CONSTRAINT tech_jobs_tot_emp_nonneg CHECK (tot_emp IS NULL OR tot_emp >= 0),
    CONSTRAINT tech_jobs_jobs_1000_nonneg CHECK (
        jobs_1000 IS NULL OR jobs_1000 >= 0
    ),
    CONSTRAINT tech_jobs_loc_quotient_nonneg CHECK (
        loc_quotient IS NULL OR loc_quotient >= 0
    ),
    CONSTRAINT tech_jobs_wage_nonneg CHECK (
        (h_mean IS NULL OR h_mean >= 0)
        AND (a_mean IS NULL OR a_mean >= 0)
        AND (h_median IS NULL OR h_median >= 0)
        AND (a_median IS NULL OR a_median >= 0)
    )
);

CREATE INDEX idx_tech_jobs_survey_year ON tech_jobs (survey_year);
CREATE INDEX idx_tech_jobs_area_code ON tech_jobs (area_code);
CREATE INDEX idx_tech_jobs_a_median
    ON tech_jobs (a_median DESC NULLS LAST);
CREATE INDEX idx_tech_jobs_tot_emp
    ON tech_jobs (tot_emp DESC NULLS LAST);
CREATE INDEX idx_tech_jobs_occ_code ON tech_jobs (occ_code);

-- Full CSV staging table (extra columns dropped on import)
CREATE TABLE staging_bay_area_tech_jobs (
    area         TEXT,
    area_title   TEXT,
    area_type    TEXT,
    prim_state   TEXT,
    naics        TEXT,
    naics_title  TEXT,
    i_group      TEXT,
    own_code     TEXT,
    occ_code     TEXT,
    occ_title    TEXT,
    o_group      TEXT,
    tot_emp      TEXT,
    emp_prse     TEXT,
    jobs_1000    TEXT,
    loc_quotient TEXT,
    h_mean       TEXT,
    a_mean       TEXT,
    mean_prse    TEXT,
    h_pct10      TEXT,
    h_pct25      TEXT,
    h_median     TEXT,
    h_pct75      TEXT,
    h_pct90      TEXT,
    a_pct10      TEXT,
    a_pct25      TEXT,
    a_median     TEXT,
    a_pct75      TEXT,
    a_pct90      TEXT,
    annual       TEXT,
    hourly       TEXT
);

COMMIT;
