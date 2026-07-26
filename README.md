# Equity Portfolio Risk & Performance Analytics Pipeline

An end-to-end cloud financial analytics pipeline that ingests stock market data, engineers risk metrics via SQL, trains ML models for price prediction and anomaly detection, optimizes portfolio allocation, and delivers insights through an interactive Tableau dashboard.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/b97d0aa9-0c8c-432e-8410-649cc6ce3c15" />


---

## Project Overview

This project demonstrates the full modern data stack applied to financial analytics — from raw data ingestion through machine learning and portfolio optimization. Built on Databricks Free Edition with a medallion architecture (Bronze → Silver → Gold), it processes 5 years of daily price data for 50 equities across 7 sectors.

**Key Outcomes:**
- Engineered 6 financial risk metrics (Sharpe ratio, Beta, VaR, volatility, daily returns, sector averages) for 50 equities using SQL window functions
- Trained Random Forest and Gradient Boosting classifiers with 19 features; results validated Efficient Market Hypothesis (AUC ~0.50)
- Built Isolation Forest anomaly detection flagging 1,818 unusual trading days (3%) — correctly identifying events like Netflix's 35% subscriber-loss crash and NVDA's AI-boom earnings surge
- Optimized portfolio allocation across 3 strategies: Max Sharpe portfolio turned $100 into $442 vs $213 for equal-weight baseline
- Designed incremental daily refresh pipeline with automated data quality checks (6-point validation)

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        DATA INGESTION                           │
│              Yahoo Finance API (yfinance) → Python              │
│                 50 tickers | 5 years | 62,750+ rows             │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    BRONZE LAYER (Raw)                            │
│              bronze_stock_prices (62,750+ rows)                  │
│              sector_mapping (50 rows)                            │
└─────────────────────────┬───────────────────────────────────────┘
                          │ SQL JOINs + LAG Window Functions
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    SILVER LAYER (Transformed)                    │
│              silver_stock_analytics (62,700+ rows)               │
│              Daily returns, sector labels, prev_close            │
└─────────────────────────┬───────────────────────────────────────┘
                          │ Aggregations + Statistical Functions
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    GOLD LAYER (Business-Ready)                   │
│              gold_risk_metrics (50 rows)                         │
│              gold_sector_performance (8 rows)                    │
│              gold_ml_predictions (5,900 rows)                    │
│              gold_anomaly_detection (60,600 rows)                │
│              gold_portfolio_strategies (3 rows)                  │
│              gold_portfolio_allocations (150 rows)               │
│              gold_portfolio_backtest (1,271 rows)                │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    VISUALIZATION & ML                            │
│     Tableau Dashboard    │    ML Models    │   Optimization      │
│     (Interactive, 4      │  Random Forest  │  Min-Variance       │
│      charts + 3 KPIs)   │  Gradient Boost │  Max Sharpe         │
│                          │  Isolation Forest│  Equal Weight      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Repository Structure

```
├── notebooks/
│   ├── 01_data_ingestion.py          # Pull data from Yahoo Finance, load to Databricks
│   ├── 02_daily_refresh.py           # Incremental daily update + data quality checks
│   ├── 03_stock_prediction.py        # ML: Random Forest & Gradient Boosting classifiers
│   ├── 04_anomaly_detection.py       # ML: Isolation Forest for unusual trading days
│   └── 05_portfolio_optimization.py  # Mean-Variance optimization, 3 strategies, backtest
│
├── sql/
│   ├── create_silver_analytics.sql   # JOINs + LAG window functions for daily returns
│   ├── create_gold_risk_metrics.sql  # Sharpe, Beta, VaR, volatility calculations
│   └── create_gold_sector_perf.sql   # Sector-level aggregated metrics
│
├── screenshots/
│   ├── dashboard_main.png            # Tableau dashboard (default view)
│   ├── dashboard_filtered.png        # Tableau dashboard (sector filter active)
│   └── architecture_diagram.png      # Pipeline architecture
│
├── data/
│   └── sector_mapping.csv            # Ticker-to-sector reference table
│
└── README.md
```

---

## Data Pipeline

### Data Source
- **Yahoo Finance API** via `yfinance` Python library
- 50 equities across 7 sectors: Technology, Financials, Healthcare, Energy, Consumer, Industrials, Media/Payments
- 5 years of daily OHLCV data (June 2021 – June 2026)
- 62,750+ total records

### Medallion Architecture (Databricks)

| Layer | Table | Rows | Description |
|-------|-------|------|-------------|
| Bronze | `bronze_stock_prices` | 62,750+ | Raw daily prices from Yahoo Finance |
| Reference | `sector_mapping` | 50 | Ticker → Sector classification |
| Silver | `silver_stock_analytics` | 62,700+ | Enriched with sectors, daily returns via LAG |
| Gold | `gold_risk_metrics` | 50 | Per-stock Sharpe, Beta, VaR, volatility |
| Gold | `gold_sector_performance` | 8 | Sector-level aggregated metrics |
| Gold | `gold_ml_predictions` | 5,900 | Random Forest & Gradient Boosting predictions |
| Gold | `gold_anomaly_detection` | 60,600 | Isolation Forest anomaly flags |
| Gold | `gold_portfolio_strategies` | 3 | Strategy comparison (Min Risk, Max Sharpe, Equal) |
| Gold | `gold_portfolio_allocations` | 150 | Stock weights per strategy |
| Gold | `gold_portfolio_backtest` | 1,271 | $100 growth simulation over 5 years |

### Daily Refresh Pipeline
The `02_daily_refresh` notebook supports incremental ingestion:
1. Checks the latest date in the database
2. Pulls only new data from Yahoo Finance
3. Appends to Bronze table
4. Recalculates all Silver and Gold tables
5. Runs 6-point data quality validation (nulls, duplicates, ticker count, negative prices, date gaps, stale tickers)

---

## Financial Metrics Engineered (SQL)

| Metric | Formula | Business Meaning |
|--------|---------|-----------------|
| Daily Return (%) | `(Close - LAG(Close)) / LAG(Close) × 100` | How much the stock moved today |
| Volatility | `STDDEV(daily_return)` | Risk — how wildly returns swing |
| Sharpe Ratio | `AVG(return) / STDDEV(return)` | Risk-adjusted return (reward per unit of risk) |
| Beta | `COVAR(stock, market) / VAR(market)` | Market sensitivity (>1 = aggressive, <1 = defensive) |
| Value at Risk (95%) | `PERCENTILE_CONT(0.05)` | Worst expected daily loss at 95% confidence |
| Sector Averages | `AVG()` grouped by sector | Sector-level risk/return profile |

### SQL Concepts Used
`JOIN`, `CTE (WITH)`, `LAG() OVER (PARTITION BY ... ORDER BY ...)`, `AVG`, `STDDEV`, `COVAR_SAMP`, `VAR_SAMP`, `PERCENTILE_CONT`, `GROUP BY`, `ROUND`, `NULLIF`, `CREATE TABLE AS SELECT`

---

## Machine Learning

### Phase 1: Stock Price Direction Prediction
- **Goal:** Predict whether a stock goes up or down the next trading day
- **Features (19):** Rolling returns (3/5/10-day), volatility windows, RSI-14, MACD, Bollinger Band position, volume z-scores, day-of-week, month, consecutive streak, daily range
- **Models:** Random Forest (300 trees), Gradient Boosting (300 estimators, lr=0.05)
- **Train/Test Split:** Time-based (pre-2026 train, 2026 test) — no data leakage
- **Results:** AUC ~0.50, validating Efficient Market Hypothesis — simple technical features cannot reliably predict short-term stock direction
- **Top Features:** 5-day return momentum, daily price range, volume vs 20-day average

### Phase 2: Anomaly Detection
- **Goal:** Automatically flag unusual trading days across all 50 stocks
- **Model:** Isolation Forest (contamination=3%)
- **Features:** Return z-score, volume z-score, daily range z-score, overnight gap, raw daily return
- **Results:** 1,818 anomalies detected (3.0% of trading days)
- **Validation:** Top anomalies correspond to real market events — Netflix -35% (subscriber loss), NVDA +24% (AI earnings), META +20% (first dividend)
- **Sector Insight:** Technology had highest anomaly rate (4.78%), Consumer lowest (2.18%)

### Phase 3: Portfolio Optimization
- **Goal:** Find optimal stock allocation to maximize risk-adjusted returns
- **Method:** Mean-Variance Optimization (Markowitz) via `scipy.optimize`
- **Constraints:** Weights sum to 1, max 15% per stock, no short selling
- **Three Strategies:**

| Strategy | Daily Return | Volatility | Sharpe | $100 → |
|----------|-------------|------------|--------|--------|
| Min Risk | 0.052% | 0.716% | 0.072 | $187 |
| Max Sharpe | 0.122% | 0.972% | 0.125 | $442 |
| Equal Weight | 0.065% | 0.997% | 0.065 | $213 |

- **Max Sharpe allocation:** WMT (15%), LLY (15%), XOM (14.4%), NVDA (12.6%), ABBV (11.5%), GE (9.8%)
- **Min Risk allocation:** JNJ (15%), KO (12.7%), MCD (10.8%), LMT (9.5%), PG (8.6%)

---

## Dashboard

Interactive Tableau dashboard with 4 visualizations and 3 KPI cards:

| Component | Type | Insight |
|-----------|------|---------|
| KPI: Equities Tracked | Card | 50 stocks monitored |
| KPI: Portfolio Sharpe | Card | 1.73 overall risk-adjusted return |
| KPI: Top Sector | Card | Technology (highest Sharpe) |
| Price Trends | Line Chart | 5-year price movement for 6 representative stocks |
| Risk vs. Return | Scatter Plot | Volatility vs return by sector (colored) |
| Sharpe by Sector | Bar Chart | Sector ranking by risk-adjusted return |
| Market Beta | Bubble Chart | Market sensitivity by sector, sized by VaR |

**Interactive Feature:** Clicking a sector on the Sharpe bar chart filters the scatter plot and beta chart to show only that sector's stocks.

---

## Tech Stack

| Category | Tools |
|----------|-------|
| Cloud Platform | Databricks Free Edition (Serverless SQL Warehouse) |
| Languages | Python, SQL (Spark SQL) |
| Data Ingestion | yfinance, pandas |
| Data Processing | Apache Spark, pandas |
| Machine Learning | scikit-learn (Random Forest, Gradient Boosting, Isolation Forest) |
| Optimization | scipy.optimize (SLSQP) |
| Visualization | Tableau Desktop |
| Architecture | Medallion (Bronze/Silver/Gold) |

---

## Key Findings

1. **Technology sector** delivered the highest risk-adjusted return (Sharpe) but also the highest anomaly rate (4.78%), reflecting high reward with high unpredictability
2. **Consumer stocks** (WMT, KO, PG) showed the lowest beta and fewest anomalies — the safest defensive plays
3. **Optimized portfolio (Max Sharpe) outperformed equal-weight by 107%** ($442 vs $213 on a $100 investment), proving quantitative allocation adds real value
4. **Stock price prediction models achieved ~50% accuracy**, consistent with Efficient Market Hypothesis — validating that simple technical features cannot beat market efficiency
5. **Anomaly detection correctly identified major market events** without any news data, purely from price/volume patterns

---

## How to Run

1. **Create a Databricks Free Edition account** at [databricks.com/try-databricks](https://www.databricks.com/try-databricks)
2. **Import notebooks** from the `notebooks/` folder into your Databricks workspace
3. **Run `01_data_ingestion.py`** to pull stock data and create Bronze table
4. **Run SQL queries** from `sql/` folder in SQL Editor to create Silver and Gold tables
5. **Run `03_stock_prediction.py`** for ML price prediction
6. **Run `04_anomaly_detection.py`** for anomaly flagging
7. **Run `05_portfolio_optimization.py`** for portfolio strategies and backtest
8. **Connect Tableau** to exported CSVs for dashboard visualization
9. **For daily updates:** Run `02_daily_refresh.py` to pull latest data and recalculate all metrics

---

## Author

**Saloni Shahi**
MS Business Analytics | Northeastern University, D'Amore-McKim School of Business

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue)](https://www.linkedin.com/in/saloni-shahi)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black)](https://github.com/SaloniShahi336)
