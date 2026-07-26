-- Silver Layer: Enrich raw prices with sector labels and daily returns

CREATE OR REPLACE TABLE silver_stock_analytics AS
WITH daily_returns AS (
    SELECT 
        p.*,
        s.Sector,
        LAG(p.Close) OVER (PARTITION BY p.Ticker ORDER BY p.Date) AS prev_close,
        ROUND(((p.Close - LAG(p.Close) OVER (PARTITION BY p.Ticker ORDER BY p.Date)) 
               / LAG(p.Close) OVER (PARTITION BY p.Ticker ORDER BY p.Date)) * 100, 4) AS daily_return_pct
    FROM bronze_stock_prices p
    JOIN sector_mapping s ON p.Ticker = s.Ticker
)
SELECT * FROM daily_returns
WHERE prev_close IS NOT NULL;
