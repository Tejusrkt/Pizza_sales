select * from orderspizza
select * from pizzas
select * from pizza_types
select * from order_details

----Basic:
----Retrieve the total number of orders placed.

select count(distinct (order_id)) from orderspizza

----Calculate the total revenue generated from pizza sales.

select round(sum(quantity*price),2) as total_revenue from order_details as ot join pizzas as pz
on ot.pizza_id=pz.pizza_id


----Identify the highest-priced pizza.
select price,pt.name from pizzas as pz join pizza_types as pt
on pz.pizza_type_id=pt.pizza_type_id
order by price DESC



----Identify the most common pizza size ordered.

select count(order_details_id) as order_count,size from pizzas as pz join order_details as od
on pz.pizza_id=od.pizza_id
group by size
order by order_count desc
----List the top 5 most ordered pizza types along with their quantities. 


select pt.name,sum(quantity) as total_quantity from pizzas join pizza_types as pt
on pizzas.pizza_type_id=pt.pizza_type_id join order_details as ot
on pizzas.pizza_id=ot.pizza_id 
group by pt.name
order by total_quantity desc 

------Intermediate:
---Join the necessary tables to find the total quantity of each pizza category ordered.

select sum(quantity) as total_quantity,category from pizzas join pizza_types as pt
on pizzas.pizza_type_id=pt.pizza_type_id join order_details ot
on pizzas.pizza_id=ot.pizza_id
group by category
order by total_quantity desc

---Determine the distribution of orders by hour of the day.

select hour(time) as hours1, count(order_id) as total_orders from orderspizza
group by hour(time)
order by hours1

----Join relevant tables to find the category-wise distribution of pizzas.

select category,count(name) from pizza_types
group by category

----Group the orders by date and calculate the average number of pizzas ordered per day.

select avg(total_quant) from 
(
select orders.date,sum(quantity) as total_quant from orders join order_details as ot
on orders.order_id=ot.order_id
group by orders.date) as order_avg

----Determine the top 3 most ordered pizza types based on revenue.

select name,round(sum(quantity*price),2) as total_revenue from order_details as ot join pizzas as pz
on ot.pizza_id=pz.pizza_id join pizza_types as pt
on pt.pizza_type_id=pz.pizza_type_id
group by name
order by total_revenue desc

----Tough questions
----Calculate the percentage contribution of each pizza type to total revenue.

select category,round(sum(quantity*price) /(select round(sum(quantity*price),2) as total_sales from order_details as ot join pizzas as pz
on ot.pizza_id=pz.pizza_id)*100,2)as total_revenue_percentage from pizza_types as pt join pizzas as pz
on pt.pizza_type_id=pz.pizza_type_id join order_details as ot 
on ot.pizza_id=pz.pizza_id
group by category
order by total_revenue_percentage desc

-----Analyze the cumulative revenue generated over time.

select date,sum(revenue) over(order by order_date) as cum_revenue 
from
(
select orderspizza.date,sum(quantity * price) as revenue from order_details as ot join orderspizza as op
on op.order_id=ot.order_id join pizzas
on pizzas.pizza_id=ot.pizza_id
group by orderspizza.date) as sales


-----Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category,name,total_revenue from
(
select category,name,total_revenue,rank() over(partition by category order by total_revenue desc) as rn from
(
select category,name,round(sum(quantity*price),2) as total_revenue from order_details as ot join pizzas as pz
on ot.pizza_id=pz.pizza_id join pizza_types as pt
on pt.pizza_type_id=pz.pizza_type_id
group by category,name) as a) as b
where rn<=3