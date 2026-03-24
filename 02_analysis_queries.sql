
-- ============================================================
-- Alberta Energy Export Analysis
-- Description: Core analysis queries examining Canadian crude
-- oil export dependency, price correlation, product mix,
-- and pipeline throughput from 2006 to 2025
-- Data Sources: Canada Energy Regulator, FRED (IMF)
-- ============================================================


-- ============================================================
-- QUERY 1: US vs Non-US Export Dependency by Year
-- Goal: Show what percentage of Canadian crude exports go to
-- the US each year to quantify Alberta's trade dependency
-- PADD I-V = US regions, 'Other' = non-US destinations
-- ============================================================

SELECT 
    Year,
    SUM(CASE WHEN PADD != 'Other' THEN volume_bbl_d ELSE 0 END) AS us_exports_bbl_d,
    SUM(CASE WHEN PADD = 'Other' THEN volume_bbl_d ELSE 0 END) AS non_us_exports_bbl_d,
    SUM(volume_bbl_d) AS total_exports_bbl_d,
    ROUND(SUM(CASE WHEN PADD != 'Other' THEN volume_bbl_d ELSE 0 END) / 
    NULLIF(SUM(volume_bbl_d), 0) * 100, 1) AS us_export_pct
FROM vw_exports_destination_clean
GROUP BY Year
ORDER BY Year


-- ============================================================
-- QUERY 2: Export Volume vs WTI Price Correlation by Year
-- Goal: Show whether Canadian crude export volumes track with
-- oil prices or remain stable regardless of price movements
-- ============================================================

SELECT 
    e.Year,
    ROUND(SUM(e.volume_bbl_d), 0) AS total_exports_bbl_d,
    ROUND(AVG(w.wti_price_usd), 2) AS avg_wti_price_usd
FROM vw_exports_destination_clean e
JOIN vw_wti_prices_clean w 
    ON YEAR(w.observation_date) = e.Year
GROUP BY e.Year
ORDER BY e.Year


-- ============================================================
-- QUERY 3: Heavy vs Light vs Medium Crude Export Breakdown
-- Goal: Show the product mix of Canadian crude exports over time
-- Heavy crude dominance explains why US Midwest refineries are
-- so critical — they are specifically configured for oil sands
-- bitumen and cannot easily switch to other crude sources
-- API definitions: Heavy < 25, Medium 25-30, Light > 30
-- ============================================================

SELECT 
    Year,
    ROUND(SUM(CASE WHEN Oil_Type = 'Heavy' THEN volume_bbl_d ELSE 0 END), 0) AS heavy_bbl_d,
    ROUND(SUM(CASE WHEN Oil_Type = 'Light' THEN volume_bbl_d ELSE 0 END), 0) AS light_bbl_d,
    ROUND(SUM(CASE WHEN Oil_Type = 'Medium' THEN volume_bbl_d ELSE 0 END), 0) AS medium_bbl_d,
    ROUND(SUM(volume_bbl_d), 0) AS total_bbl_d,
    ROUND(SUM(CASE WHEN Oil_Type = 'Heavy' THEN volume_bbl_d ELSE 0 END) /
    NULLIF(SUM(volume_bbl_d), 0) * 100, 1) AS heavy_pct
FROM vw_exports_type_clean
GROUP BY Year
ORDER BY Year


-- ============================================================
-- PIPELINE EXPLORATION: Key Points Investigation
-- Goal: Identify the most meaningful measurement locations
-- across all three pipelines before finalizing Query 4
-- Used to select border crossing and tidewater export points
-- ============================================================

SELECT DISTINCT 
    Pipeline,
    Key_Point,
    Direction_Of_Flow,
    Trade_Type
FROM vw_pipeline_combined
ORDER BY Pipeline, Key_Point


-- ============================================================
-- PIPELINE DATA AVAILABILITY CHECK
-- Goal: Confirm throughput and capacity data exists at our
-- selected key export points before building the final query
-- Finding: Nameplate capacity not reported at border crossings
-- so utilization percentage cannot be calculated
-- ============================================================

SELECT DISTINCT
    Pipeline,
    Key_Point,
    Trade_Type,
    COUNT(*) AS row_count,
    SUM(CASE WHEN throughput_1000_m3_d IS NOT NULL THEN 1 ELSE 0 END) AS rows_with_throughput,
    SUM(CASE WHEN nameplate_capacity_1000_m3_d IS NOT NULL THEN 1 ELSE 0 END) AS rows_with_capacity
FROM vw_pipeline_combined
WHERE (
    (Pipeline = 'Enbridge Canadian Mainline system' AND Key_Point = 'ex-Gretna' AND Trade_Type = 'export')
    OR
    (Pipeline = 'Keystone pipeline' AND Trade_Type = 'export')
    OR
    (Pipeline = 'Trans Mountain pipeline' AND Key_Point = 'Westridge' AND Trade_Type = 'export')
)
GROUP BY Pipeline, Key_Point, Trade_Type
ORDER BY Pipeline


-- ============================================================
-- QUERY 4: Pipeline Throughput at Key Export Points Over Time
-- Goal: Show how much crude is physically moving through each
-- major export route annually
-- Note: Nameplate capacity not reported at border crossing
-- points so throughput trend used instead of utilization rate
-- Key points: Westridge (tidewater, TMX expansion impact)
-- and Keystone (US border crossing at Haskett, Manitoba)
-- ============================================================

SELECT
    YEAR(Date) AS Year,
    Pipeline,
    Key_Point,
    ROUND(AVG(throughput_1000_m3_d), 2) AS avg_throughput_1000_m3_d
FROM vw_pipeline_combined
WHERE throughput_1000_m3_d IS NOT NULL
AND (
    (Pipeline LIKE '%Keystone%' AND Trade_Type = 'export')
    OR
    (Pipeline LIKE '%Trans Mountain%' AND Key_Point = 'Westridge' AND Trade_Type = 'export')
)
GROUP BY YEAR(Date), Pipeline, Key_Point
ORDER BY Pipeline, Year


-- ============================================================
-- QUERY 5: Master Summary — Export Dependency, Volume, Price
-- Goal: Single query combining all key metrics by year
-- Shows how much Canada exports, where it goes, what price
-- it receives, and what product mix is being exported
-- ============================================================

SELECT
    e.Year,
    ROUND(SUM(e.volume_bbl_d), 0) AS total_exports_bbl_d,
    ROUND(SUM(CASE WHEN e.PADD != 'Other' THEN e.volume_bbl_d ELSE 0 END), 0) AS us_exports_bbl_d,
    ROUND(SUM(CASE WHEN e.PADD = 'Other' THEN e.volume_bbl_d ELSE 0 END), 0) AS non_us_exports_bbl_d,
    ROUND(SUM(CASE WHEN e.PADD != 'Other' THEN e.volume_bbl_d ELSE 0 END) /
    NULLIF(SUM(e.volume_bbl_d), 0) * 100, 1) AS us_export_pct,
    ROUND(AVG(w.wti_price_usd), 2) AS avg_wti_price_usd,
    ROUND(SUM(CASE WHEN t.Oil_Type = 'Heavy' THEN t.volume_bbl_d ELSE 0 END) /
    NULLIF(SUM(t.volume_bbl_d), 0) * 100, 1) AS heavy_crude_pct
FROM vw_exports_destination_clean e
JOIN vw_wti_prices_clean w
    ON YEAR(w.observation_date) = e.Year
JOIN vw_exports_type_clean t
    ON t.Year = e.Year
    AND t.Month = e.Month
GROUP BY e.Year
ORDER BY e.Year