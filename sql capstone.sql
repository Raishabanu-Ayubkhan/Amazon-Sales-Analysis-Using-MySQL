-- 1.1 Build a database
create database Amazon;
use Amazon;
-- 1.2 imported csv file as amazon table
select * from amazon;
-- 1.3 Making all columns not null and setting data type 
ALTER TABLE amazon
MODIFY COLUMN `Invoice ID` VARCHAR(30) NOT NULL,
MODIFY COLUMN `Branch` VARCHAR(5) NOT NULL,
MODIFY COLUMN `City` VARCHAR(30) NOT NULL,
MODIFY COLUMN `Customer type` VARCHAR(30) NOT NULL,
MODIFY COLUMN `Gender` VARCHAR(10) NOT NULL,
MODIFY COLUMN `Product line` VARCHAR(100) NOT NULL,
MODIFY COLUMN `Unit price` DECIMAL(10, 2) NOT NULL,
MODIFY COLUMN `Quantity` INT NOT NULL,
MODIFY COLUMN `Tax 5%` FLOAT(6,4) NOT NULL,
MODIFY COLUMN `Total` DECIMAL(10,2) NOT NULL,
MODIFY COLUMN `Date` DATE NOT NULL,
MODIFY COLUMN `Time` TIME NOT NULL,
MODIFY COLUMN `Payment` VARCHAR(30) NOT NULL,
MODIFY COLUMN `cogs` DECIMAL(10, 2) NOT NULL,
MODIFY COLUMN `gross margin percentage` FLOAT(11,9) NOT NULL,
MODIFY COLUMN `gross income` DECIMAL(10,2) NOT NULL,
MODIFY COLUMN `Rating` DECIMAL(3,1) NOT NULL;
-- SHOP TIMING IS BETWEEN 10.00 AM TO 9.00 PM
SELECT max(`Time`) AS max_time,
       MIN(`Time`) AS min_time
FROM amazon;

-- 2.1 adding new column as time of day using case 
ALTER TABLE amazon
ADD COLUMN time_of_day VARCHAR(20);

UPDATE amazon
SET time_of_day = CASE
        WHEN `Time` BETWEEN '10:00:00' AND '11:59:59' THEN 'Morning'
        WHEN `Time` BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
        ELSE 'Evening'
    END ;
    
-- 2.2 Add a new column day name
ALTER TABLE amazon
ADD COLUMN day_name varchar(10);

UPDATE amazon 
SET day_name= dayname(`Date`);
select * from amazon;

-- 2.3 Adding month name to the table 
ALTER TABLE amazon
ADD COLUMN month_name varchar(10);

UPDATE amazon 
SET month_name= date_format(`Date` , '%b');

-- 3 Exploratory Data Analysis
-- Business question to answers
-- 1.Count of distinct cities
select count(distinct City) from amazon;

-- 2.For each branch, what is the corresponding city
select Branch,City from amazon
group by Branch,City
order by Branch;

-- 3.What is the count of distinct product lines in the dataset
select count(distinct `Product line`) from amazon;

-- 4.Which payment method occurs most frequently
select Payment,count(Payment) as pay_cnt from amazon
group by Payment
order by pay_cnt desc;

-- 5.Which product line has the highest sales?
select `Product line`,count(*)  as prd_cnt from amazon
group by `Product line`
order by prd_cnt desc;

-- 6. How much revenue is generated each month
select month_name,sum(Total) as revenue from amazon
group by month_name 
order by revenue desc;

-- 7. In which month did the cost of goods sold reach its peak
select month_name,sum(cogs) as cog from amazon
group by month_name 
order by cog desc
limit 1;

-- 8.Which product line generated the highest revenue
select `Product line`,sum(Total) as revenue from amazon 
group by `Product line`
order by revenue desc
limit 1;

-- 9.In which city was the highest revenue recorded 
select City,sum(Total) as revenue from amazon
group by City
order by revenue desc
limit 1;

-- 10.Which product line incurred the highest Value Added Tax
select `Product line`,sum(`Tax 5%`) as tax from amazon
group by `Product line`
order by tax desc
limit 1;

-- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
with cte1 as
(select `Product line`,count(*) as sale from amazon
group by `Product line`),
cte2 as
(select avg(sale) as average from cte1)
select c1.`Product line`,
case 
 when c1.sale > c2.average then 'GOOD'
 else 'BAD'
 end as 'Sales_label'
 from cte1 c1 join cte2 c2
 on 1=1;

-- 12 Identify the branch that exceeded the average number of products sold.
with cte3 as
(select Branch,sum(quantity) as product_count from amazon
group by Branch)
select Branch,product_count from cte3
where product_count>(select avg(product_count) from cte3);

-- 13 Which product line is most frequently associated with each gender?
with cte1 as 
(select Gender,`Product line`,count(*) as frequency from amazon
group by Gender,`Product line`),
cte2 as
(select Gender,`Product line`,frequency,row_number() over(partition by Gender order by frequency)as ranking from cte1)
select Gender,`Product line`,frequency from cte2 where ranking=1 ; 

-- 14.Calculate the average rating for each product line
select `Product line`,round(avg(Rating),2) as average_rating from amazon
group by `Product line`
order by average_rating desc;

-- 15 Count the sales occurrences for each time of day on every weekday.
select day_name,time_of_day,count(*) as sale_count from amazon
where day_name not in ('Saturday','Sunday')
group by day_name,time_of_day
order by 
CASE
        WHEN day_name = 'Monday' THEN 1
        WHEN day_name = 'Tuesday' THEN 2
        WHEN day_name = 'Wednesday' THEN 3
        WHEN day_name = 'Thursday' THEN 4
        WHEN day_name = 'Friday' THEN 5
    END,
    CASE
        WHEN time_of_day = 'Morning' THEN 1
        WHEN time_of_day = 'Afternoon' THEN 2
        WHEN time_of_day = 'Evening' THEN 3
	END;
    
-- 16 Identify the customer type contributing the highest revenue.
select `Customer type`,sum(Total) as revenue from amazon
group by `Customer type`
order by revenue desc
limit 1;

-- 17 Determine the city with the highest VAT percentage.

select max(`Tax 5%`)  as max_tax from amazon;
select City from amazon where `Tax 5%`=(select max(`Tax 5%`) from amazon);

-- 18 Identify the customer type with the highest VAT payments.
select `Customer type` from amazon where `Tax 5%`=(select max(`Tax 5%`) from amazon);

-- 19 What is the count of distinct customer types in the dataset?
select count(distinct `Customer type`) as customer_type_count from amazon;

-- 20 What is the count of distinct payment methods in the dataset?
select count(distinct Payment) as payment_method_count from amazon;

-- 21 Which customer type occurs most frequently?
select `Customer type`,count(*) as customer_count from amazon
group by `Customer type`
order by customer_count desc
limit 1;

-- 22 Identify the customer type with the highest purchase frequency.
select `Customer type`,count(*) as purchase_count from amazon
group by `Customer type`
order by purchase_count desc
limit 1;

-- 23 Determine the predominant gender among customers.
select Gender,count(*) as Gender_count from amazon
group by Gender
order by Gender
limit 1;

-- 24 Examine the distribution of genders within each branch.
select Branch,Gender,count(Gender) as gender_distribution from amazon
group by Branch,Gender
order by Branch;

-- 25 Identify the time of day when customers provide the most ratings.
select time_of_day,count(Rating) as rating_count from amazon
group by time_of_day
order by rating_count desc;

-- 26 Determine the time of day with the highest customer ratings for each branch.
with cte4 as
(select Branch,time_of_day,max(Rating) as max_rating from amazon
group by Branch,time_of_day),
cte5 as
(select *,rank() over(partition by Branch order by max_rating desc) as ranking from cte4)
select Branch,time_of_day,max_rating from cte5 where ranking=1;
 
-- 27 Identify the day of the week with the highest average ratings.
select day_name,avg(Rating) as avg_rating from amazon 
group by day_name
order by avg_rating desc
limit 1;
-- 28 Determine the day of the week with the highest average ratings for each branch.
with cte1 as
(select Branch,day_name,avg(Rating) as avg_rating from amazon
group by Branch,day_name
order by Branch),
cte2 as
(select *,rank() over (partition by Branch order by avg_rating desc) as ranking from cte1)
select Branch,day_name,avg_rating from cte2
where ranking=1 ;

select day_name,count(*) as sale_count from amazon
group by day_name
order by 
CASE
        WHEN day_name = 'Monday' THEN 1
        WHEN day_name = 'Tuesday' THEN 2
        WHEN day_name = 'Wednesday' THEN 3
        WHEN day_name = 'Thursday' THEN 4
        WHEN day_name = 'Friday' THEN 5
        WHEN day_name = 'Saturday' THEN 6
        WHEN day_name = 'Sunday' THEN 7
        
    END;
    


