# Findings

Data quality (Q), business (B), limitations (L). Every claim carries its row
ids; every number was independently recomputed before being written down.

## Data quality

### Q1. One paste destroyed one order and duplicated another

Order 1028 (C127, Headphones) appears twice, identical on **all eleven
columns**. Order 1029 never appears: the sequence 1001-1035 should hold 35
ids and holds 34, and the anti-join in [sql/01](sql/01_quality_sweeps.sql)
names the hole as 1029, directly adjacent to the duplicate.

One action explains both: a row paste-over (1028 copied over 1029) creates an
identical duplicate and deletes an order in the same keystroke. The rival
story needs two unrelated errors that happen to sit next to each other.
Byte-identical rows are what copies look like, not what coincidences look like.

**Impact runs both directions at once:** deduping removes double-counted
revenue, but 1029 is revenue the file never had. Totals were simultaneously
overstated by one known order and understated by one unknown one.

**Disposition:** dedupe applied in [sql/00](sql/00_load.sql) and disclosed;
order 1029 requested from the source system.

### Q2. A region that does not exist

Order 1024 (C123) carries region `west`, lowercase. GROUP BY matches bytes,
so every regional breakdown gains a phantom fifth region and understates West
by one order, with no error raised. Found by the distinct-values sweep, which
reads value lists as a proofread rather than an analysis.

**Disposition:** normalized at load, disclosed, and flagged upstream: the
interesting fact is that the source system accepts freetext regions at all.

### Q3. Discounts of 50% and 90%

Both on North-region Monitors (orders 1009, 1025). The 90% order grossed
$32.90 against $27.00 of shipping. Fat-finger (9 entered as 90) and genuine
clearance are both live; the data cannot adjudicate.

**Disposition:** flagged by id, not corrected. A business really selling at
that price has a different problem than a typo, and both need a human.

### Q4. The ten-mouse order

Order 1016 (C115, West, Paid Search): 10 units where every other order in the
file is 1-4 of anything. That one row is 42% of all mouse units and moves the
product's per-order average from 2.0 to 3.0.

Hypotheses in base-rate order: bulk/B2B buyer; or the inventory-drain pattern
(a competitor drains a listing, shoppers route elsewhere, units mass-return
later). Only the second predicts the units come back, and the Returned flag
cannot show that yet (L1).

**Disposition:** flagged, monitored, and excluded/included sensitivity applied
to every aggregate it drives.

## Business

### B1. Deep-discount monitor orders earned a tenth of the per-order contribution

| bucket | orders | rev before returns | returned | net revenue | net contribution | per order |
|---|--:|--:|--:|--:|--:|--:|
| <=15% | 5 | $2,171.40 | 0 | $2,171.40 | $2,033.40 | $406.68 |
| >=20% | 4 | $707.35 | 2 | $279.65 | $173.65 | $43.41 |

Buckets cover all 9 monitor orders (0 in the 15-20 gap). The >=20% rows: 1004,
1009, 1019, 1025; the returned pair: 1004, 1009.

**This is a description, not a causal story.** The >=20% group is confounded
with channel (2 of 4 are North/Social vs 4 of 5 East/Organic in the other
bucket) and n=4 cannot separate discount depth from channel. The small n cuts
both explanations symmetrically.

### B2. The Social channel returns most of what it sells

| channel | n | returns | return rate | net revenue | net contribution |
|---|--:|--:|--:|--:|--:|
| Social | 7 | 4 | 57% | $192.87 | $101.87 |
| Paid Search | 9 | 1 | 11% | $1,788.16 | $1,667.16 |
| Organic | 9 | 0 | 0% | $2,621.10 | $2,472.10 |
| Email | 9 | 0 | 0% | $1,474.30 | $1,381.55 |

Found by escalating two anecdotes (keyboard returns 1012 and 1032, both
West/Social; monitor returns implicating North/Social) into a dimension test.
Social contributed $101.87 across an entire month: 1.8% of total contribution
from 21% of orders, and 70% of the revenue it booked was returned ($450.69 of
$643.56 gross). All rates are floors per L1.

## Limitations

- **L1. Return rates are floors.** The Returned flag has no date and the
  window is one month; late-July orders have had days to come back, early-July
  orders had weeks. Right-censoring, biased hardest at the recent edge.
  Documented as [sql-notes trap T-009](https://github.com/collapseindex/sql-notes/blob/main/notes/traps.md).
- **L2. Small n everywhere.** 34 orders, buckets of 4-9. Descriptions are
  solid; every causal reading is labeled as hypothesis.
- **L3. No baseline.** One month, no history: no seasonality, no trend, no
  way to say whether any of this is new.

## Scorecard

The workbook plants issues without an answer key. Findable defects found: 5 of
5 (Q1 both halves, Q2, Q3, Q4). The censoring limitation (L1) was surfaced
during coaching rather than independently. Three of five were caught by
reading rows, which works at 35 rows; the two that required queries (the
missing 1029, the lowercase region) are the two classes row-reading cannot
catch at any real scale: absence and near-identity.
