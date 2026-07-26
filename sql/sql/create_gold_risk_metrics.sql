-- Gold Layer: Per-stock financial risk metrics

CREATE OR REPLACE TABLE gold_risk_metrics AS
WITH market_avg AS (
    SELECT Date, AVG(daily_return_pct) AS market_return
    FROM silver_stock_analytics
    GROUP BY Date
)
SELECT 
    a.Ticker,
    a.Sector,
    ROUND(AVG(a.daily_return_pct), 4) AS avg_daily_return,
    ROUND(STDDEV(a.daily_return_pct), 4) AS daily_volatility,
    COUNT(*) AS trading_days,
    ROUND(MIN(a.Close), 2) AS min_price,
    ROUND(MAX(a.Close), 2) AS max_price,
    ROUND(AVG(a.daily_return_pct) / NULLIF(STDDEV(a.daily_return_pct), 0), 4) AS sharpe_proxy,
    ROUND(
        COVAR_SAMP(a.daily_return_pct, m.market_return) 
        / NULLIF(VAR_SAMP(m.market_return), 0), 4
    ) AS beta,
    ROUND(PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY a.daily_return_pct), 4) AS var_95
FROM silver_stock_analytics a
JOIN market_avg m ON a.Date = m.Date
GROUP BY a.Ticker, a.Sector;
