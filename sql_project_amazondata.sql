SELECT * FROM amazon.amazondata;
        -- 2.1 Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening. This will help answer the question on which part of the day most sales are made.
		-- 2.2  Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). This will help answer the question on which week of the day each branch is busiest. 
        -- 2.3   Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar). Help determine which month of the year has the most sales and profit.

ALTER TABLE amazon.amazondata
ADD COLUMN timeofday VARCHAR(10);

ALTER TABLE amazon.amazondata
ADD COLUMN dayname VARCHAR(10);

ALTER TABLE amazon.amazondata
ADD COLUMN monthname VARCHAR(10);

-- Update the 'timeofday' column based on 'transaction_time'
UPDATE amazon.amazondata
SET timeofday = CASE
    WHEN transaction_time < '12:00:00' THEN 'Morning'
    WHEN transaction_time < '18:00:00' THEN 'Afternoon'
    ELSE 'Evening'
END;

-- Update the 'dayname' column based on 'transaction_date'
UPDATE amazon.amazondata
SET dayname = CASE
    WHEN DAYOFWEEK(transaction_date) = 1 THEN 'Sun'
    WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Mon'
    WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tue'
    WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wed'
    WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thu'
    WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Fri'
    WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Sat'
END;

-- Update the 'monthname' column based on 'transaction_date'
UPDATE amazon.amazondata
SET monthname = CASE
    WHEN MONTH(transaction_date) = 1 THEN 'Jan'
    WHEN MONTH(transaction_date) = 2 THEN 'Feb'
    WHEN MONTH(transaction_date) = 3 THEN 'Mar'
    WHEN MONTH(transaction_date) = 4 THEN 'Apr'
    WHEN MONTH(transaction_date) = 5 THEN 'May'
    WHEN MONTH(transaction_date) = 6 THEN 'Jun'
    WHEN MONTH(transaction_date) = 7 THEN 'Jul'
    WHEN MONTH(transaction_date) = 8 THEN 'Aug'
    WHEN MONTH(transaction_date) = 9 THEN 'Sep'
    WHEN MONTH(transaction_date) = 10 THEN 'Oct'
    WHEN MONTH(transaction_date) = 11 THEN 'Nov'
    WHEN MONTH(transaction_date) = 12 THEN 'Dec'
END;
-- Business Questions To Answer: 
-- 1.What is the count of distinct cities in the dataset?
select count(distinct city)as city1 from amazon.amazondata;

-- 2.For each branch, what is the corresponding city?
 select DISTINCT Branch,city from amazon.amazondata order by Branch;
 
--  3.What is the count of distinct product lines in the dataset?
select count(Distinct 'product line')as product_lines from amazon.amazondata;

-- 4.Which payment method occurs most frequently?
select payment,count(*) as payment_count from amazon.amazondata Group by payment  Order by payment_count Desc;

-- 5.Which product line has the highest sales?
 select "product line",sum(total)as total_sales from amazon.amazondata Group By "product line" Order By total_sales Desc;
 
 -- 6.How much revenue is generated each month?
 select DATE_FORMAT(Date,'%Y-%m') AS month, SUM(total) AS total_revenue FROM amazon.amazondata GROUP BY month ORDER BY total_revenue;
 
--  7.In which month did the cost of goods sold reach its peak?
select Date_format(Date,'%Y-%m') as month,sum(cogs)as total_cogs from amazon.amazondata Group By month order By total_cogs;

-- 8.Which product line generated the highest revenue?
select "product_line", sum(Quantity) as High_Revenue from amazon.amazondata Group By "Product line" Order By High_Revenue;

-- 9.In which city was the highest revenue recorded?
select city ,sum(total) as revenue from amazon.amazondata Group By city Order By Revenue Desc;

-- 10.Which product line incurred the highest Value Added Tax?
select "product line" ,count('Tax 5%') as VAT from amazon.amazondata Group By "Product line" Order By VAT  Desc;

-- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
select 'product line',
        CASE
           when total > Avg(Total) over (partition by 'product line') Then 'Good'
           Else 'Bad'
        End As sales_status
 From amazon.amazondata limit 5;      
 
 -- 12.Identify the branch that exceeded the average number of products sold
 select Branch,sum(Quantity) as sold from amazon.amazondata
 Group By Branch Having sum(Quantity)  > 
 (select Avg(Quantity) * count(Distinct Branch) from amazon.amazondata);
 
-- 13.Which product line is most frequently associated with each gender?
select Gender,'product line', count(*) as frequency from amazon.amazondata
Group By Gender,'Product line' Order by frequency desc;

-- 14.Calculate the average rating for each product line
select 'product line',avg(Rating) as average_rating from amazon.amazondata
Group By 'Product line' order by Average_rating desc;

-- 15.Count the sales occurrences for each time of day on every weekday.
select date_format(Date,'%y-%m-%d') as weekday,count(*) as sales_occurance from amazon.amazondata
Group By weekday Order by sales_occurance Desc;

-- 16.Identify the customer type contributing the highest revenue.
select 'Customer type',sum(total) as total_revenue from amazon.amazondata
Group By 'Customer type' Order By total_Revenue Desc;

-- 17.Determine the city with the highest VAT percentage.
select city, max(total) as Highest_vat FROM amazon.amazondata
GROUP BY city ORDER BY Highest_vat DESC limit 1;

-- 18.Identify the customer type with the highest VAT payments.
select 'customer type',max(payment) as Highest_Vat_Payments from amazon.amazondata
Group By 'customer type' Order By Highest_Vat_Payments Desc;

-- 19.What is the count of distinct customer types in the dataset?
SELECT count(Distinct 'customer_type') AS Distinct_customer_types
FROM amazon.amazondata;

-- 20.What is the count of distinct payment methods in the dataset?
SELECT COUNT(DISTINCT Payment) AS Distinct_payment_methods
FROM amazon.amazondata;

-- 21.Which customer type occurs most frequently?
select 'customer type', COUNT(*) AS frequency FROM amazon.amazondata
Group By 'customer type' order By frequency DESC  limit 1;

-- 22. Identify the customer type with the highest purchase frequency.
SELECT 'customer type', COUNT(*) AS purchase_frequency from amazon.amazondata
Group by 'customer type' order by purchase_frequency DESC;

-- 23.Determine the predominant gender among customers.
SELECT Gender, COUNT(*) AS frequency FROM amazon.amazondata
Group by Gender Order by frequency DESC LIMIT 1;

-- 24.Examine the distribution of genders within each branch.
select Branch,Gender  from amazon.amazondata
Group by Branch, Gender Order by Branch,Gender;

-- 25.Identify the time of day when customers provide the most ratings.
 select Time_of_day, COUNT(rating) AS ratings_count
FROM (
    SELECT 
        rating,
        CASE 
            WHEN EXTRACT(HOUR FROM time) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM time) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN EXTRACT(HOUR FROM time) BETWEEN 18 AND 21 THEN 'Evening'
            ELSE 'Night'
        END AS time_of_day
    FROM amazon.amazondata
) AS time_of_day_ratings
Group by time_of_day Order By ratings_count DESC;

-- 26.Determine the time of day with the highest customer ratings for each branch.
WITH time_of_day_ratings AS (
    SELECT 
        branch,
        rating,
        CASE 
            WHEN EXTRACT(HOUR FROM time) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM time) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN EXTRACT(HOUR FROM time) BETWEEN 18 AND 21 THEN 'Evening'
            ELSE 'Night'
        END AS time_of_day
    FROM amazon.amazondata
),
ratings_count AS (
    SELECT 
        branch, 
        time_of_day, 
        COUNT(rating) AS ratings_count
    FROM time_of_day_ratings
    GROUP BY branch, time_of_day
)
SELECT branch, time_of_day, ratings_count
FROM (
    SELECT branch, time_of_day, ratings_count,
           ROW_NUMBER() OVER (PARTITION BY branch ORDER BY ratings_count DESC) AS rn
    FROM ratings_count
) ranked_ratings
WHERE rn = 1;

-- 27.Identify the day of the week with the highest average ratings.
SELECT day_of_week, AVG(rating) AS average_rating
FROM (
    SELECT 
        rating,
        DAYNAME(date) AS day_of_week
    FROM amazon.amazondata
) AS day_ratings
Group By day_of_week Order By average_rating Desc
LIMIT 1;

-- 28.Determine the day of the week with the highest average ratings for each branch.
WITH day_ratings AS (
    SELECT 
        branch,
        rating,
        DAYNAME(date) AS day_of_week
    FROM amazon.amazondata
),
average_ratings AS (
    SELECT 
        branch,
        day_of_week,
        AVG(rating) AS average_rating
    FROM day_ratings
    GROUP BY branch, day_of_week
),
ranked_ratings AS (
    SELECT 
        branch,
        day_of_week,
        average_rating,
        ROW_NUMBER() OVER (PARTITION BY branch ORDER BY average_rating DESC) AS rn
    FROM average_ratings
)
SELECT branch, day_of_week, average_rating
FROM ranked_ratings
WHERE rn = 1;


