use my_database;
-- Q1.
/*Emily would like to know how many bikes the shop owns by category. Can
you get this for her?
Display the category name and the number of bikes the shop owns in
each category (call this column number_of_bikes ). Show only the categories
where the number of bikes is greater than 2 .*/

select category,count(*) as number_of_bike 
from bike
group by category
having number_of_bike >2;

-- Q2.
/*Emily needs a list of customer names with the total number of
memberships purchased by each.
For each customer, display the customer's name and the count of
memberships purchased (call this column membership_count ). Sort the
results by membership_count , starting with the customer who has purchased
the highest number of memberships.
Keep in mind that some customers may not have purchased any
memberships yet. In such a situation, display 0 for the membership_count .*/

select c.name,count(m.id) as membership_count
from customer as c
left join membership as m
on c.id=m.customer_id
group by c.name
order by membership_count desc;

-- Q3.
/* Emily is working on a special offer for the winter months. Can you help her
prepare a list of new rental prices?
For each bike, display its ID, category, old price per hour (call this column
old_price_per_hour ), discounted price per hour (call it new_price_per_hour ), old
price per day (call it old_price_per_day ), and discounted price per day (call it
new_price_per_day ).
Electric bikes should have a 10% discount for hourly rentals and a 20%
discount for daily rentals. Mountain bikes should have a 20% discount for
hourly rentals and a 50% discount for daily rentals. All other bikes should
have a 50% discount for all types of rentals.
Round the new prices to 2 decimal digits.
*/ 

select id, category
, price_per_hour as old_price_per_hour
, case when category = 'electric' then round(price_per_hour - (price_per_hour*0.1) ,2)
	   when category = 'mountain bike' then round(price_per_hour - (price_per_hour*0.2) ,2)
       else round(price_per_hour - (price_per_hour*0.5) ,2)
  end as new_price_per_hour
, price_per_day as old_price_per_day
, case when category = 'electric' then round(price_per_day - (price_per_day*0.2) ,2)
	   when category = 'mountain bike' then round(price_per_day - (price_per_day*0.5) ,2)
       else round(price_per_day - (price_per_day*0.5) ,2)
  end as new_price_per_day
from bike;

-- Q4 
 /* Emily is looking for counts of the rented bikes and of the available bikes in each category.
Display the number of available bikes (call this column
available_bikes_count ) and the number of rented bikes (call this column
rented_bikes_count ) by bike category */

SELECT category,
       SUM(CASE WHEN status = 'available' THEN 1 ELSE 0 END) AS available_bikes_count,
       SUM(CASE WHEN status = 'rented' THEN 1 ELSE 0 END) AS rented_bikes_count
FROM bike
GROUP BY category;

-- Q5 
/*Emily is preparing a sales report. She needs to know the total revenue
from rentals by month, the total by year, and the all-time across all the
years.
Bike rental shop - SQL Case study 5
Display the total revenue from rentals for each month, the total for each
year, and the total across all the years. Do not take memberships into
account. There should be 3 columns: year , month , and revenue .
Sort the results chronologically. Display the year total after all the month
totals for the corresponding year. Show the all-time total as the last row.
The resulting table looks something like this:*/ 

select month(start_timestamp)as months , year(start_timestamp)as years,sum(total_paid) as revenu from rental
group by years,months
Union all 
select year(start_timestamp)as years, null as months ,sum(total_paid) as revenu from rental
group by years
union all 
select null as months, null as years, sum(total_paid) as revenu from rental
order by years,months;



-- Q6. 
/*Emily has asked you to get the total revenue from memberships for each
combination of year, month, and membership type.
Display the year, the month, the name of the membership type (call this
column membership_type_name ), and the total revenue (call this column
total_revenue ) for every combination of year, month, and membership type.
Sort the results by year, month, and name of membership type.
*/

select year(m.start_date)
,month(m.start_date) ,
m1.name,
sum(m.total_paid)
From membership as m
Inner join membership_type as m1
on m.membership_type_id=m1.id
GROUP BY 
    year(m.start_date), 
    month(m.start_date), 
    m1.name;
    
 --   Q.7
 /* Next, Emily would like data about memberships purchased in 2023, with
subtotals and grand totals for all the different combinations of membership
types and months.
Display the total revenue from memberships purchased in 2023 for each
combination of month and membership type. Generate subtotals and
grand totals for all possible combinations. There should be 3 columns:
membership_type_name , month , and total_revenue .
Sort the results by membership type name alphabetically and then
chronologically by month.*/

select m1.name as membership_type_name, month(m.start_date)as months,sum(m1.price) AS total_revenue
from membership as m 
inner join membership_type as m1
on m.membership_type_id=m1.id
where year(m.start_date)= "2023"
group by  membership_type_name,months;

-- Q8.
/*Now it's time for the final task.Emily wants to segment customers based on the number of rentals and
see the count of customers in each segment. Use your SQL skills to getthis!Categorize customers based on their rental history as follows:
Customers who have had more than 10 rentals are categorized as 'more
than 10' .
Customers who have had 5 to 10 rentals (inclusive) are categorized as
'between 5 and 10' .
Customers who have had fewer than 5 rentals should be categorized as
'fewer than 5' .
Calculate the number of customers in each category. Display two columns:
rental_count_category (the rental count category) and customer_count (the
number of customers in each category).*/

with cte as 
    (select customer_id, count(1)
    , case when count(1) > 10 then 'more than 10' 
           when count(1) between 5 and 10 then 'between 5 and 10'
           else 'fewer than 5'
      end as category
    from rental
    GROUP by customer_id)
select category as rental_count_category
, count(*) as customer_count
from cte 
group by category
order by customer_count;


