-- 02: monitor discount economics (finding B1).
-- Buckets chosen so nothing falls between them: 0 monitor orders sit in the
-- 15-20% gap (checked below). Returned orders: revenue 0, shipping sunk.

WITH m AS (
  SELECT *, CASE WHEN discount_pct <= 15 THEN '<=15%' ELSE '>=20%' END AS bucket
  FROM enriched WHERE product = 'Monitor'
)
SELECT bucket,
       count(*)                                          AS orders,
       round(sum(revenue), 2)                            AS rev_before_returns,
       sum(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END) AS returned,
       round(sum(net_revenue), 2)                        AS net_revenue,
       round(sum(net_revenue) - sum(shipping_cost), 2)   AS net_contribution,
       round((sum(net_revenue) - sum(shipping_cost)) / count(*), 2) AS per_order
FROM m GROUP BY bucket ORDER BY bucket;

-- gap check: parts must cover the whole
SELECT count(*) AS monitors,
       sum(CASE WHEN discount_pct > 15 AND discount_pct < 20 THEN 1 ELSE 0 END) AS in_gap
FROM enriched WHERE product = 'Monitor';

-- the confound that keeps this descriptive, not causal
SELECT CASE WHEN discount_pct <= 15 THEN '<=15%' ELSE '>=20%' END AS bucket,
       region, channel, count(*) AS n
FROM enriched WHERE product = 'Monitor'
GROUP BY ALL ORDER BY bucket, n DESC;
