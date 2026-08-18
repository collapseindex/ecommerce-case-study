-- 00: load and clean.
-- Corrections applied here are FINDINGS, not housekeeping: each one is
-- documented in FINDINGS.md (Q1, Q2) and disclosed in the report.

INSTALL excel; LOAD excel;

CREATE OR REPLACE TABLE raw AS
SELECT * FROM read_xlsx('data/raw/ecommerce_analyst_practice_dataset.xlsx',
                        sheet = 'Orders', header = true);

CREATE OR REPLACE TABLE orders AS
SELECT DISTINCT                     -- Q1: order 1028 is duplicated verbatim
  CAST(Order_ID AS INT)   AS order_id,
  Date                    AS order_date,
  Customer_ID             AS customer_id,
  CASE WHEN lower(trim(Region)) = 'west' THEN 'West'
       ELSE trim(Region) END AS region,   -- Q2: order 1024 arrives as 'west'
  Channel                 AS channel,
  Product                 AS product,
  CAST(Units AS INT)      AS units,
  Unit_Price              AS unit_price,
  "Discount_%"            AS discount_pct,
  Shipping_Cost           AS shipping_cost,
  Returned                AS returned
FROM raw;

-- Definitions (stated once, used everywhere):
--   revenue      = units * unit_price * (1 - discount_pct/100)
--   returned     = revenue counts as 0, shipping kept as sunk cost
--   contribution = net revenue - shipping (manufacturing cost out of scope)
CREATE OR REPLACE VIEW enriched AS
SELECT *,
  units * unit_price * (1 - discount_pct/100) AS revenue,
  CASE WHEN returned = 'No'
       THEN units * unit_price * (1 - discount_pct/100) ELSE 0 END AS net_revenue
FROM orders;
