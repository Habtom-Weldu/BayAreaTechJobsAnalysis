# Project checklist and Progress tracking
Phase 1: Project Setup

Project Initialization
 [x] Create project folder
 [x] Initialize Git repository
 [x] Create .gitignore
 [x] Remove accidental .gitingnore
 [x] Create virtual environment (.venv)
 [x] Install Python packages
 [x] Configure VS Code

Documentation
 [x] Create README.md
 [x] Define project objective
 [x] Define business questions
 [x]Create docs/data-sources.md

Folder Structure
 Create project structure

Phase 2: Data Acquisition
BLS Data
 [x] Download OEWS Metropolitan Area dataset
 [x] Download file descriptions
 [x] Store files in data/raw/bls/
Initial Dataset Review
 [x] Verify dataset loads in pandas
 [x] Verify row count
 [x] Verify column count
 [x] Review metro areas available

Phase 3: Data Understanding
Notebook Setup
 [x] Create notebooks/data_exploration.ipynb
 [x] Configure Jupyter kernel
 [x] Install openpyxl
Initial Exploration
 [x] Load dataset
 [x] Run df.shape
 [x] Run df.info()
 [x] Review columns
 [x] Review metro areas
Findings
 [x] Identify Bay Area metros
 [x] Identify potentially useful columns
 [x] Notice wage/employment columns are text (object)
 [x] Notice empty columns (PCT_TOTAL, PCT_RPT)

Define Tech Occupations
 [x] Explore occupation hierarchy
 [x] Investigate SOC codes
 [x] Decide what counts as "tech occupations"
 [x] Document filtering criteria

Bay Area Scope
 [x] Identify Bay Area metro areas to include
 [x] San Francisco-Oakland-Fremont
 [x] San Jose-Sunnyvale-Santa Clara
 [x] Santa Rosa-Petaluma
 [x] Napa
 [x] Santa Cruz-Watsonville
 [x] Vallejo

Data Quality Assessment
 [x] Investigate non-numeric wage columns
 [x] Investigate suppressed values (*, **, etc.)
 [x] Identify cleaning requirements


Data Preparation
 [x] Create cleaning notebook/script
 [x] Convert numeric columns
 [x] Handle missing values
 [x] Create cleaned dataset
 [x] Bay Area filter applied
 [x] Tech occupation filter applied
 [x] Major occupation rows removed
 [x] Empty columns removed
 [x] Numeric columns converted
 [x] Missing values assessed
 [x] Duplicates checked
 [x] Data quality validated
 [x] Clean dataset saved
 
Database
 Design PostgreSQL schema
 Import cleaned data
Analysis
 Highest-paying tech occupations
 Highest-demand tech occupations
 Bay Area tech concentration
 Employment trends
Visualization
 Tableau dashboard
 Project report
 GitHub portfolio presentation