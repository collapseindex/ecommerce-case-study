-- 04: every other number REPORT.md quotes, in one place.

-- headline
SELECT count(*) AS orders, round(sum(revenue),2) AS gross_revenue,
       round(sum(net_revenue),2) AS net_revenue,
       round(sum(net_revenue) - sum(shipping_cost),2) AS net_contribution,
       sum(CASE WHEN returned='Yes' THEN 1 ELSE 0 END) AS returns
FROM enriched;

-- by product / region
SELECT product, count(*) AS n, round(sum(net_revenue),2) AS net_revenue,
       round(sum(net_revenue)-sum(shipping_cost),2) AS contribution,
       sum(CASE WHEN returned='Yes' THEN 1 ELSE 0 END) AS returns
FROM enriched GROUP BY product ORDER BY contribution DESC;

SELECT region, count(*) AS n, round(sum(net_revenue),2) AS net_revenue,
       round(sum(net_revenue)-sum(shipping_cost),2) AS contribution
FROM enriched GROUP BY region ORDER BY contribution DESC;

-- repeat customers (spoiler: one, barely)
SELECT customer_id, count(*) AS orders
FROM orders GROUP BY customer_id HAVING count(*) > 1;

-- order 1016's weight inside its product (finding Q4)
SELECT round(avg(units),2)  AS avg_units_all,
       round(avg(CASE WHEN order_id != 1016 THEN units END),2) AS avg_units_without_1016,
       max(units) AS biggest, sum(units) AS total_units
FROM enriched WHERE product = 'Mouse';
