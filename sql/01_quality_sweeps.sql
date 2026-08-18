-- 01: the three data-quality sweeps, run against RAW on purpose.
-- Boring output is the goal; anything interesting is a finding.

-- Sweep 1: distinct values per categorical (catches Q2, the 'west' row)
SELECT Region,   count(*) FROM raw GROUP BY Region   ORDER BY 1;
SELECT Channel,  count(*) FROM raw GROUP BY Channel  ORDER BY 1;
SELECT Product,  count(*) FROM raw GROUP BY Product  ORDER BY 1;
SELECT Returned, count(*) FROM raw GROUP BY Returned ORDER BY 1;

-- Sweep 2: ranges per numeric (catches Q3's 90% discount, Q4's 10 units)
SELECT min(Units) , max(Units),
       min(Unit_Price), max(Unit_Price),
       min("Discount_%"), max("Discount_%"),
       min(Shipping_Cost), max(Shipping_Cost),
       min(Date), max(Date)
FROM raw;

-- Sweep 3: id uniqueness and sequence (catches Q1, both halves)
SELECT Order_ID, count(*) FROM raw GROUP BY Order_ID HAVING count(*) > 1;

SELECT min(Order_ID) AS lo, max(Order_ID) AS hi,
       max(Order_ID) - min(Order_ID) + 1 AS expected_ids,
       count(DISTINCT Order_ID)          AS actual_ids
FROM raw;

-- The anti-join that names the hole: expected sequence LEFT JOIN reality,
-- keep what never matched. Returns 1029.
SELECT gs.id
FROM generate_series(1001, 1035) AS gs(id)
LEFT JOIN raw ON raw.Order_ID = gs.id
WHERE raw.Order_ID IS NULL;
