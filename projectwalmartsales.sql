create database Walmartsales;
use Walmartsales;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

select * from sales;

-- Feature new columns--
-- insertingn a column which shows at which part of the day we are having a sale
-- column showing morning, evening, afternoon


select time,
(case
when `time`  between "00:00:00" and "12:00:00" then "Morning"

when `time`  between "12:01:00" and "16:00:00" then "Afternoon"
else "Evening"
end
) as time_of_day
 from sales;
 
 
 
 -- adding this to actual schema using alter table command
 
 alter table sales add column time_of_day varchar(20);

SHOW VARIABLES LIKE 'sql_safe_updates';
SET sql_safe_updates = 0;

update sales 
set time_of_day = (case
when `time`  between "00:00:00" and "12:00:00" then "Morning"

when `time`  between "12:01:00" and "16:00:00" then "Afternoon"
else "Evening"
end
);

select 
date, dayname(date) from sales;

alter table sales 
add column day_name varchar(10);

update sales
set day_name = dayname(date);

-- addding month and column name

select date, monthname(date) from sales;

 alter table sales 
add column month_name varchar(10); 

update sales 
set month_name = monthname(date);



-- --------------- generic questions to answer -------------

-- How many unique cities does the data have?
select distinct city from sales;

-- In which city is each branch?

select count(branch) from sales where city like "Yangon";
select count(branch) from sales where city like "Naypyitaw";
select count(branch) from sales where city like "Mandalay";

-- --------------------product related question ---------------
-- ------------------------------------------------------------

-- How many unique product lines does the data have?

select count(distinct product_line) from sales;


-- What is the most common payment method?

select distinct payment from sales;
select count(payment) from sales where payment like "Credit card";
select count(payment) from sales where payment like "Ewallet";
select count(payment) from sales where payment like "Cash";

-- cash is most commonly used 

-- What is the most selling product line?

select sum(quantity) as qty, product_line
from sales
group by product_line
order by qty desc;

-- What is the total revenue by month?
select sum(total) as revenue, month_name from sales
group by month_name
order by revenue asc;

-- What month had the largest COGS?
select month_name as month,
sum(cogs) as cog from sales
group by month_name 
order by sum(cogs);


-- What product line had the largest revenue?

select product_line, sum(total) as revenue 
from sales
group by product_line
order by revenue;


-- What is the city with the largest revenue?

select city, sum(total) as revenue 
from sales
group by city
order by revenue;

-- What product line had the largest VAT?
select product_line, 
avg(tax_pct) as avg_tax from sales
group by product_line
order by avg_tax;


-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

-- adding remark column to database

alter table sales
add column remark varchar(10);

UPDATE sales
SET remark = (
    CASE
        WHEN (SELECT AVG(quantity) FROM (SELECT * FROM sales) AS subquery) > 5.5 THEN 'Good'
        ELSE 'Bad'
    END
);


-- Which branch sold more products than average product sold?
select branch, sum(quantity) as qty
from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales);

-- What is the most common product line by gender?
select gender, product_line, count(gender) as totalcount
from sales
group by gender, product_line
order by totalcount desc;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- -------------------------- Customers -------------------------------
-- --------------------------------------------------------------------

-- How many unique customer types does the data have?
select distinct customer_type from sales;

-- How many unique payment methods does the data have?
select distinct payment from sales;

-- What is the most common customer type?
select  distinct customer_type as cust_type, count( customer_type) from sales
group by cust_type
 order by count( customer_type);
 
--  Which customer type buys the most?
select  distinct customer_type as cust_type, count( quantity) from sales
group by cust_type
 order by count( quantity);
 
 -- What is the gender distribution per branch?
 
 select distinct branch, count(gender) from sales
 group by branch
 order by count(gender);
 
 -- Which time of the day do customers give most ratings per branch?
 select time_of_day,
 avg(rating) as ratings,
 branch from sales
 group by branch, time_of_day
 order by ratings;
 
 -- Which day fo the week has the best avg ratings?
 select distinct day_name, avg(rating) as avgrat from sales
 group by day_name
 order by avgrat;
 
 -- Which day of the week has the best average ratings per branch?
 select distinct day_name, branch , avg(rating) as avgrat from sales
 group by day_name, branch
 order by avgrat;
 
 -- --------------------------------------------------------------------
-- ---------------------------- Sales ---------------------------------
-- --------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday 
select sum(total) as revenue, time_of_day from sales
group by time_of_day
order by revenue;

-- Evenings experience most sales,

-- Which of the customer types brings the most revenue?
select sum(total) as revenue, customer_type from sales
group by customer_type
order by revenue;
-- Member customers are bringing most revenue

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax;
 



 


