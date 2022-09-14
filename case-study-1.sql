-- 1. What is the total amount each customer spent at the restaurant?
SELECT
  	s.customer_id,
    sum(m.price) as total
FROM dannys_diner.sales as s
INNER JOIN dannys_diner.menu as m
ON s.product_id = m.product_id
group by s.customer_id
-- 2. How many days has each customer visited the restaurant?
SELECT
  	s.customer_id,
   count(s.order_date) as days
FROM dannys_diner.sales as s
group by s.customer_id
-- 3. What was the first item from the menu purchased by each customer?
SELECT 
	distinct
    s.customer_id,
    FIRST_VALUE(m.product_name) 
    OVER(
      	PARTITION BY s.customer_id
        ORDER BY s.order_date
    ) product
FROM 
    dannys_diner.sales s
INNER JOIN
	dannys_diner.menu m
ON s.product_id = m.product_id

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
m.product_name,
COUNT(s.product_id) as count
FROM dannys_diner.menu m
INNER JOIN dannys_diner.sales s
ON m.product_id = s.product_id
GROUP BY m.product_name
ORDER BY count desc
LIMIT 1

-- 5. Which item was the most popular for each customer?
SELECT 
	distinct
    s2.customer_id,
    FIRST_VALUE(m.product_name) 
    OVER(
      	PARTITION BY s2.customer_id
        ORDER BY s2.count desc
    ) most_popular
FROM (select s.customer_id, s.product_id, count(s.product_id)
from dannys_diner.sales s
group by s.customer_id, s.product_id) s2
inner join dannys_diner.menu m
on s2.product_id = m.product_id


-- 6. Which item was purchased first by the customer after they became a member?
select distinct s2.customer_id,
FIRST_VALUE(m.product_name)
OVER(
  PARTITION BY s2.customer_id
  ORDER BY s2.order_date asc ) first_purchase
FROM
(
select s.customer_id,s.order_date,s.product_id,m.join_date from
dannys_diner.sales s
inner join
dannys_diner.members m
on
s.customer_id = m.customer_id
where s.order_date >= m.join_date
) s2
inner join dannys_diner.menu m
on s2.product_id = m.product_id


-- 7. Which item was purchased just before the customer became a member?
select distinct s2.customer_id,
FIRST_VALUE(m.product_name)
OVER(
  PARTITION BY s2.customer_id
  ORDER BY s2.order_date desc ) first_purchase
FROM
(
select s.customer_id,s.order_date,s.product_id,m.join_date from
dannys_diner.sales s
inner join
dannys_diner.members m
on
s.customer_id = m.customer_id
where s.order_date < m.join_date
) s2
inner join dannys_diner.menu m
on s2.product_id = m.product_id



-- 8. What is the total items and amount spent for each member before they became a member?
select distinct s2.customer_id,
sum(m.price) as total_spent
FROM
(
select s.customer_id,s.order_date,s.product_id,m.join_date from
dannys_diner.sales s
inner join
dannys_diner.members m
on
s.customer_id = m.customer_id
where s.order_date < m.join_date
) s2
inner join dannys_diner.menu m
on s2.product_id = m.product_id
group by s2.customer_id



-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select s.customer_id,
sum(points) as total_points
from dannys_diner.sales s
inner join
(select m.product_id, m.price * 20 as points
from dannys_diner.menu m
where m.product_name = 'sushi'
union
select m.product_id, m.price * 10 as points
from dannys_diner.menu m
where m.product_name != 'sushi') s2
on s.product_id = s2.product_id
group by s.customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

select s.customer_id,s.order_date,s.product_id,m.join_date, m2.price * 20 as points from
dannys_diner.sales s
inner join
dannys_diner.members m
on
s.customer_id = m.customer_id
inner join
dannys_diner.menu m2
on
s.product_id = m2.product_id
where s.order_date < '2021-01-31' and
s.order_date >= m.join_date and s.order_date < m.join_date + 7