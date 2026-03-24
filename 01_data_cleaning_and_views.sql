-- ============================================================
-- Alberta Energy Export Analysis
-- Description: Data cleaning and view creation scripts
-- Covers date range validation, null handling, confidential
-- value replacement, and combined pipeline view construction
-- All raw tables are left untouched — clean views built on top
-- ============================================================

USE AlbertaEnergyAnalysis


-- ============================================================
-- DATE RANGE VALIDATION
-- Goal: Confirm date ranges across all raw tables before
-- filtering to 2006 to align with pipeline data start date
-- Results: exports start 1985, WTI starts 2003, pipelines
-- start between 2006 and 2010 depending on reporting requirements
-- ============================================================

SELECT MIN(Period), MAX(Period) FROM exports_by_destination
SELECT MIN(Period), MAX(Period) FROM exports_by_type
SELECT MIN(observation_date), MAX(observation_date) FROM wti_prices
SELECT MIN(Date), MAX(Date) FROM pipeline_transmountain
SELECT MIN(Date), MAX(Date) FROM pipeline_enbridge
SELECT MIN(Date), MAX(Date) FROM pipeline_keystone


-- ============================================================
-- VIEW 1: vw_wti_prices_clean
-- Filters WTI price data to 2006 onward to align with
-- pipeline data. Renames price column for clarity.
-- ============================================================

CREATE VIEW vw_wti_prices_clean AS
SELECT 
    observation_date,
    POILWTIUSDM AS wti_price_usd
FROM wti_prices
WHERE observation_date >= '2006-01-01'

-- Validation checks
SELECT COUNT(*) FROM vw_wti_prices_clean
SELECT TOP 5 * FROM vw_wti_prices_clean


-- ============================================================
-- VIEW 2: vw_exports_destination_clean
-- Filters to 2006 onward, excludes Total rows to prevent
-- double counting, and converts Confidential text values
-- to NULL so volume columns can be used in calculations
-- ============================================================

CREATE VIEW vw_exports_destination_clean AS
SELECT 
    Period,
    Year,
    Month,
    PADD,
    CASE 
        WHEN Volume_m3_d = 'Confidential' THEN NULL 
        ELSE CAST(Volume_m3_d AS FLOAT) 
    END AS volume_m3_d,
    CASE 
        WHEN Volume_bbl_d = 'Confidential' THEN NULL 
        ELSE CAST(Volume_bbl_d AS FLOAT) 
    END AS volume_bbl_d
FROM exports_by_destination
WHERE Period >= '2006-01-01'
AND PADD != 'Total'

-- Validation checks
SELECT COUNT(*) FROM vw_exports_destination_clean
SELECT TOP 5 * FROM vw_exports_destination_clean


-- ============================================================
-- VIEW 3: vw_exports_type_clean
-- Filters to 2006 onward, excludes Total rows to prevent
-- double counting, and converts Confidential values to NULL
-- ============================================================

CREATE VIEW vw_exports_type_clean AS
SELECT
    Period,
    Year,
    Month,
    Oil_Type,
    CASE
        WHEN Volume_m3_d = 'Confidential' THEN NULL
        ELSE CAST(Volume_m3_d AS FLOAT)
    END AS volume_m3_d,
    CASE
        WHEN Volume_bbl_d = 'Confidential' THEN NULL
        ELSE CAST(Volume_bbl_d AS FLOAT)
    END AS volume_bbl_d
FROM exports_by_type
WHERE Period >= '2006-01-01'
AND Oil_Type != 'Total'

-- Validation checks
SELECT COUNT(*) FROM vw_exports_type_clean
SELECT TOP 5 * FROM vw_exports_type_clean


-- ============================================================
-- VIEW 4: vw_pipeline_combined
-- Combines Trans Mountain, Enbridge, and Keystone pipeline
-- tables using UNION ALL into a single reporting view
-- Volume and capacity columns imported as nvarchar to handle
-- mixed text and numeric values — cast to FLOAT here with
-- empty string and NULL handling via CASE statements
-- ============================================================

CREATE VIEW vw_pipeline_combined AS
SELECT
    Date, Company, Pipeline, Key_Point,
    Direction_Of_Flow, Trade_Type, Product,
    CASE
        WHEN Throughput_1000_m3_d = '' OR Throughput_1000_m3_d IS NULL THEN NULL
        ELSE CAST(Throughput_1000_m3_d AS FLOAT)
    END AS throughput_1000_m3_d,
    CASE
        WHEN Nameplate_Capacity_1000_m3_d = '' OR Nameplate_Capacity_1000_m3_d IS NULL THEN NULL
        ELSE CAST(Nameplate_Capacity_1000_m3_d AS FLOAT)
    END AS nameplate_capacity_1000_m3_d,
    CASE
        WHEN Available_Capacity_1000_m3_d = '' OR Available_Capacity_1000_m3_d IS NULL THEN NULL
        ELSE CAST(Available_Capacity_1000_m3_d AS FLOAT)
    END AS available_capacity_1000_m3_d
FROM pipeline_transmountain

UNION ALL

SELECT
    Date, Company, Pipeline, Key_Point,
    Direction_Of_Flow, Trade_Type, Product,
    CASE
        WHEN Throughput_1000_m3_d = '' OR Throughput_1000_m3_d IS NULL THEN NULL
        ELSE CAST(Throughput_1000_m3_d AS FLOAT)
    END AS throughput_1000_m3_d,
    CASE
        WHEN Nameplate_Capacity_1000_m3_d = '' OR Nameplate_Capacity_1000_m3_d IS NULL THEN NULL
        ELSE CAST(Nameplate_Capacity_1000_m3_d AS FLOAT)
    END AS nameplate_capacity_1000_m3_d,
    CASE
        WHEN Available_Capacity_1000_m3_d = '' OR Available_Capacity_1000_m3_d IS NULL THEN NULL
        ELSE CAST(Available_Capacity_1000_m3_d AS FLOAT)
    END AS available_capacity_1000_m3_d
FROM pipeline_enbridge

UNION ALL

SELECT
    Date, Company, Pipeline, Key_Point,
    Direction_Of_Flow, Trade_Type, Product,
    CASE
        WHEN Throughput_1000_m3_d = '' OR Throughput_1000_m3_d IS NULL THEN NULL
        ELSE CAST(Throughput_1000_m3_d AS FLOAT)
    END AS throughput_1000_m3_d,
    CASE
        WHEN Nameplate_Capacity_1000_m3_d = '' OR Nameplate_Capacity_1000_m3_d IS NULL THEN NULL
        ELSE CAST(Nameplate_Capacity_1000_m3_d AS FLOAT)
    END AS nameplate_capacity_1000_m3_d,
    CASE
        WHEN Available_Capacity_1000_m3_d = '' OR Available_Capacity_1000_m3_d IS NULL THEN NULL
        ELSE CAST(Available_Capacity_1000_m3_d AS FLOAT)
    END AS available_capacity_1000_m3_d
FROM pipeline_keystone

-- Validation checks
SELECT COUNT(*) FROM vw_pipeline_combined
SELECT DISTINCT Pipeline FROM vw_pipeline_combined
SELECT TOP 5 * FROM vw_pipeline_combined

-- Confirm all 4 views created successfully
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS