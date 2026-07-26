-- Gold Layer: Sector-level aggregated performance metrics

CREATE OR REPLACE TABLE gold_sector_performance AS
SELECT 
    Sector,
    COUNT(DISTINCT Ticker) AS num_stocks,
    ROUND(AVG(avg_daily_return), 4) AS sector_avg_return,
    ROUND(AVG(daily_volatility), 4) AS sector_avg_volatility,
    ROUND(AVG(sharpe_proxy), 4) AS sector_avg_sharpe,
    ROUND(AVG(beta), 4) AS sector_avg_beta,
    ROUND(AVG(var_95), 4) AS sector_avg_var
FROM gold_risk_metrics
GROUP BY Sector;
