use sql_project;

-- First cleaning the data 

SELECT 
    SUM(CASE WHEN buyer_address IS NULL THEN 1 ELSE 0 END) AS missing_buyer_address,
    SUM(CASE WHEN eth_price IS NULL THEN 1 ELSE 0 END) AS missing_eth_price,
    SUM(CASE WHEN usd_price IS NULL THEN 1 ELSE 0 END) AS missing_usd_price,
    SUM(CASE WHEN seller_address IS NULL THEN 1 ELSE 0 END) AS missing_seller_address,
    SUM(CASE WHEN event_date IS NULL THEN 1 ELSE 0 END) AS missing_event_date,
    SUM(CASE WHEN transaction_hash IS NULL THEN 1 ELSE 0 END) AS missing_transaction_hash,
    SUM(CASE WHEN `name` IS NULL THEN 1 ELSE 0 END) AS missing_name
FROM pricedata;
-- There are no missing values 

SELECT buyer_address, eth_price, usd_price, seller_address, event_date, token_id, transaction_hash, `name`, COUNT(*) AS count
FROM pricedata
GROUP BY buyer_address, eth_price, usd_price, seller_address, event_date, token_id, transaction_hash, `name`
HAVING COUNT(*) > 1;
-- There are no duplicate values

-- Displaying the data
SELECT * FROM pricedata;

-- 1
SELECT count(*) FROM pricedata;

SELECT COUNT(*) AS total_sales
FROM pricedata
WHERE event_date BETWEEN '2018-01-01' AND '2021-12-31';


-- 2
SELECT `name`, eth_price, usd_price, event_date FROM pricedata
ORDER BY usd_price DESC
LIMIT 5;

-- 3
SELECT event_date, usd_price,
       AVG(usd_price) OVER (ORDER BY event_date ROWS BETWEEN 50 PRECEDING AND CURRENT ROW) AS moving_avg_usd_price
FROM sql_project.pricedata;

-- 4
SELECT `name`, avg(usd_price) AS average_price FROM pricedata
GROUP BY `name`
ORDER BY average_price DESC;

-- 5
SELECT DAYNAME(event_date) AS event_day,
count(*) AS number_of_sales,
avg(eth_price) AS avg_eth_price
FROM pricedata
GROUP BY event_day
ORDER BY number_of_sales ASC;

-- 6
SELECT CONCAT(name, ' was sold for $', ROUND(usd_price, -3),
' to ', buyer_address, ' from ', seller_address, ' on ', event_date) AS summary
FROM sql_project.pricedata;

-- 7
CREATE VIEW 1919_purchases AS
SELECT * FROM pricedata
WHERE buyer_address='0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

SELECT * FROM 1919_purchases;

-- 8
SELECT ROUND(eth_price,-2) as price_range,
COUNT(*) AS count,
RPAD('',COUNT(*),'*') AS bar
FROM pricedata
GROUP BY price_range
ORDER BY count; 

-- 9
SELECT name, MAX(usd_price) AS price, 'highest' AS status
FROM sql_project.pricedata
GROUP BY name
UNION ALL
SELECT name, MIN(usd_price) AS price, 'lowest' AS status
FROM pricedata
GROUP BY name
ORDER BY name ASC, status ASC;

-- 10
SELECT DATE_FORMAT(event_date, '%Y-%m') AS month_year,name,
    MAX(usd_price) AS highest_price
FROM pricedata
GROUP BY month_year, name
ORDER BY month_year ASC, highest_price DESC;

-- 11
SELECT DATE_FORMAT(event_date, '%Y-%m') AS month_year,round(sum(usd_price),-2) as total_volume
FROM pricedata
GROUP BY month_year
ORDER BY month_year;

-- 12
SELECT COUNT(*) AS no_of_transactions
FROM pricedata
WHERE buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685'
   OR seller_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

-- 13
CREATE TEMPORARY TABLE daily_averages AS
SELECT event_date,
       usd_price,
       AVG(usd_price) OVER (PARTITION BY event_date) AS daily_avg_price
FROM sql_project.pricedata;

select * from daily_averages;

SELECT event_date,
       ROUND(AVG(usd_price), 2) AS estimated_avg_value
FROM daily_averages
WHERE usd_price >= 0.1 * daily_avg_price
GROUP BY event_date
ORDER BY event_date;

