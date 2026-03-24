# Alberta Crude Oil Export Analysis 2006–2025

An end-to-end data analysis project examining Canada's crude oil export dependency on the United States, the structural role of heavy crude and pipeline capacity in limiting diversification, and the early impact of the Trans Mountain Expansion on Alberta's energy trade landscape.

## Project Context

Canada sends the vast majority of its crude oil exports to the United States. This dependency has persisted for decades and carries significant economic risk in periods of trade uncertainty. This project uses government data to quantify that dependency, understand what drives it, and identify whether recent infrastructure investments are beginning to shift the balance.

The analysis was built entirely from publicly available data and is intended to demonstrate end-to-end analytics skills across SQL Server, data modeling, and Power BI.

## Key Findings

- From 2006 to 2017 Canada consistently sent 99 to 100% of crude exports to the US with virtually zero diversification
- Heavy crude has grown from 57% of exports in 2006 to 78% by 2025, deepening the structural dependency on US Midwest refineries specifically configured for oil sands bitumen
- Export volumes grew continuously regardless of oil price, demonstrating that Alberta cannot reduce supply even during price crashes due to the high cost of shutting down oil sands operations
- Trans Mountain Westridge terminal throughput grew 783% between 2023 and 2025, marking the first meaningful shift toward tidewater and non-US export markets
- Despite this progress, US dependency remains at 91% as of 2025

## Data Sources

| Dataset | Source | Coverage |
|---|---|---|
| Crude Oil Exports by Destination | Canada Energy Regulator | 1985 to 2025 |
| Crude Oil Exports by Type | Canada Energy Regulator | 1985 to 2025 |
| Pipeline Throughput and Capacity | Canada Energy Regulator | 2006 to 2025 |
| WTI Crude Oil Price | IMF via FRED | 2003 to 2026 |

## Technical Stack

- **Database:** SQL Server (local instance via SSMS)
- **Data Modeling:** Star schema design, relational views
- **ETL:** SQL-based extraction, transformation, and loading
- **Visualization:** Power BI Desktop and Power BI Service
- **Languages:** T-SQL, DAX, Power Query (M)

## Repository Structure
```
alberta-energy-export-analysis/
├── 01_data_cleaning_and_views.sql   # Date filtering, null[01_data_cleaning_and_views.sql](https://github.com/user-attachments/files/26035697/01_data_cleaning_and_views.sql) handling, view creation
├── 02_analysis_queries.sql          # Core analysis queries with comments
├── dashboard_screenshot.png         # Power BI dashboard preview
└── README.md
```

## Dashboard

The Power BI dashboard covers four analytical themes:

1. Canadian crude export destinations over time: US vs non-US split
2. Trans Mountain Westridge throughput: the TMX expansion impact
3. WTI crude oil price history with key market event annotations
4. Share of exports by crude type: heavy crude dominance over time

Key metrics are surfaced in headline KPI cards showing 2025 US export dependency, non-US export growth, and Westridge throughput growth since 2023.

![Dashboard Preview]<img width="1264" height="742" alt="dashboard_screenshot" src="https://github.com/user-attachments/assets/5f3e6ed0-226b-4cef-a39b-29ea266525fc" />


## Methodology Notes

- All analysis filtered to 2006 onward to align with pipeline reporting start dates
- Confidential values in export destination data converted to NULL
- Total rows excluded from export tables to prevent double counting
- Pipeline capacity utilization could not be calculated at border crossing points due to nameplate capacity not being reported at those locations. Throughput trend used as a proxy
- WTI price data sourced in USD per barrel, not seasonally adjusted

## Author

**Eric Procknow**
Calgary, AB
[LinkedIn](https://linkedin.com/in/ericprocknow)
