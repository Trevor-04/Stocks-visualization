-- 1 What is the average closing price for each company in the dataset?
	select stock_symbol, avg(close) AS close_price
	from prices
	group by stock_symbol
	order by close_price desc;

-- 2 What is the highest and lowest closing price for each company?
	select stock_symbol, min(low) AS lowest, max(high) AS highest
	from prices
	group by stock_symbol
	order by lowest, highest;
-- 3 How did the closing prices change over time for each company?
	select stock_symbol, date, close
	from prices
	order by date;
-- 4 What was the highest closing price each year for a specific company?
	SELECT p.stock_symbol, p.date, p.high
FROM prices p
JOIN (
    SELECT stock_symbol, MAX(date) AS max_date
    FROM prices
    GROUP BY stock_symbol
) AS latest_date ON p.stock_symbol = latest_date.stock_symbol AND p.date = latest_date.max_date
ORDER BY p.date;
-- 5 Which company had the highest closing price on average?
	select stock_symbol, AVG(high) as highest_close_avg
    from prices
    group by stock_symbol
    order by highest_close_avg desc
    limit 1;
-- 6 What was the volatility (standard deviation of closing prices) for each company?
	select stock_symbol, stddev(close) as volatility
    from prices
    group by stock_symbol;
    
-- 7 How many times did each company's stock price change by more than 5% in a single day? 
	select stock_symbol, count(*)
    from prices
    where (high- low) / low > 0.05
    group by stock_symbol;
	
-- 8 Can you identify periods of significant price changes (e.g., drops or increases)?
	SELECT stock_symbol, date, 
       (close - LAG(close) OVER (PARTITION BY stock_symbol ORDER BY date)) / LAG(close) OVER (PARTITION BY stock_symbol ORDER BY date) * 100 AS percentage_change
		FROM prices
		ORDER BY ABS(percentage_change) DESC
		LIMIT 10;
        
-- 9 Identifying periods of consecutive days with significant cumulative changes (e.g., drops or increases of more than 10% over 5 days):
	WITH daily_changes AS (
    SELECT stock_symbol, date, 
           (close - LAG(close) OVER (PARTITION BY stock_symbol ORDER BY date)) / LAG(close) OVER (PARTITION BY stock_symbol ORDER BY date) * 100 AS daily_percentage_change
    FROM prices
), cumulative_changes AS (
    SELECT stock_symbol, date,
           SUM(daily_percentage_change) OVER (PARTITION BY stock_symbol ORDER BY date ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS five_day_change
    FROM daily_changes
)
	SELECT stock_symbol, date, five_day_change
	FROM cumulative_changes
	WHERE ABS(five_day_change) > 10
	ORDER BY ABS(five_day_change) DESC;

-- 10 Finding months or years with significant price changes (e.g., more than 20% increase or decrease):
SELECT stock_symbol, 
       DATE_FORMAT(STR_TO_DATE(date, '%m/%d/%Y'), '%Y-%m') AS month, 
       (MAX(close) - MIN(close)) / MIN(close) * 100 AS monthly_change
FROM prices
GROUP BY stock_symbol, month
HAVING ABS(monthly_change) > 20
ORDER BY ABS(monthly_change) DESC;

    
   SELECT stock_symbol, 
       DATE_FORMAT(STR_TO_DATE(date, '%m/%d/%Y'), '%Y') AS year, 
       (MAX(close) - MIN(close)) / MIN(close) * 100 AS yearly_change
FROM prices
GROUP BY stock_symbol, year
HAVING ABS(yearly_change) > 20
ORDER BY ABS(yearly_change) DESC;



-- 11 Can you identify any trends or patterns in the stock prices over time (e.g., moving averages)?
SELECT stock_symbol, date, close,
       AVG(close) OVER (PARTITION BY stock_symbol ORDER BY STR_TO_DATE(date, '%m/%d/%Y') ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS sma_30
FROM prices;

