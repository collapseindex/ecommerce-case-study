-- 03: return rate and contribution by channel (finding B2).
-- The dimension test: Social had appeared in return anecdotes across two
-- products and two regions, so the channel cut settles whether it is the
-- common thread. Every rate ships with its n. All rates are FLOORS (L1:
-- the Returned flag has no date; window is one month).

SELECT channel,
       count(*)                                          AS n,
       sum(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END) AS returns,
       round(100.0 * sum(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END) / count(*)) AS return_pct,
       round(sum(net_revenue), 2)                        AS net_revenue,
       round(sum(net_revenue) - sum(shipping_cost), 2)   AS net_contribution
FROM enriched
GROUP BY channel ORDER BY return_pct DESC;

-- which orders those Social returns actually are, for the review request
SELECT order_id, order_date, region, product, discount_pct, returned
FROM enriched WHERE channel = 'Social' ORDER BY order_id;
