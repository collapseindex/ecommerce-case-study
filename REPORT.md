# July Orders Review

**To:** Growth Manager
**From:** Data Analysis
**Date:** 2026-08-17
**Scope:** all orders, July 1-29, 2026 (34 orders after corrections below)
**Full workings:** [FINDINGS.md](FINDINGS.md) · [sql/](sql/)

## Executive summary

1. **July generated $6,076 net revenue and $5,623 contribution** across 34
   orders after returns and shipping. Organic is the strongest channel
   ($2,472 contribution, zero returns).
2. **The Social channel is close to worthless net of returns**: 4 of its 7
   orders came back (57%, where every other channel is 11% or lower), leaving
   $102 of contribution for the month, 1.8% of the total from 21% of orders.
3. **Deep-discounted monitors lose the contribution the discount was meant to
   buy**: monitor orders at >=20% discount averaged $43 contribution per order
   against $407 for the rest. With four orders we cannot say whether discount
   depth or channel is the cause; both patterns are present.
4. **Two records need source-system attention**: order 1029 is missing from
   the extract entirely (its row appears overwritten by a copy of 1028), and
   one order was filed under a region spelling the system should not accept.

## Corrections applied to the data

| issue | action | revenue impact |
|---|---|---|
| Order 1028 entered twice | deduplicated | -$151.98 gross |
| Order 1029 absent from extract | requested from source | unknown, revenue understated |
| Region "west" on order 1024 | normalized to West | none (classification only) |

The pair in rows 1 and 2 is consistent with a single paste-over during data
entry or export: totals were simultaneously overstated by one known order and
understated by one unknown one.

## Findings

### Channel: Social returns most of what it sells

| channel | orders | return rate | net contribution |
|---|--:|--:|--:|
| Organic | 9 | 0% | $2,472 |
| Paid Search | 9 | 11% | $1,667 |
| Email | 9 | 0% | $1,382 |
| Social | 7 | **57%** | **$102** |

Return rates are floors: the extract records whether an order was returned as
of export, not when, so recent orders may yet come back.

### Pricing: monitor discounts >=20%

$43 contribution per order (n=4) vs $407 (n=5) for monitors at <=15%. Two of
the four deep-discount orders returned, including one at 50% off. One order
(1025) sold at 90% off, grossing $32.90 against $27.00 shipping; whether that
is a mis-entry or a real clearance needs the order record.

### Watch item: order 1016

One order of 10 mice, in a file where no other order of anything exceeds 4
units; it alone is 42% of July mouse units. Most likely a bulk buyer, but the
drain-and-mass-return abuse pattern predicts these units come back, which the
current extract cannot show. No action beyond monitoring; it is excluded from
per-order averages where it would dominate them.

### Customers

33 of 34 orders came from distinct customers (one repeat: C101, twice). One
month of data supports no retention analysis; see the data requests.

## What we cannot conclude yet

- Whether Social's return problem is the channel, its promotions, or its
  products: the deep-discount monitors and the Social returns overlap, and
  n=4-7 cannot separate them.
- Any trend: this is one month with no baseline.
- True return rates: no return dates in the extract.

## Requests, each mapped to what it settles

| request | settles |
|---|---|
| Return reasons per returned order | defective/open-box vs changed-mind, splitting the clearance story from the channel story |
| Promotion and ad detail for Social, July | what those 7 orders were acquired with |
| Order 1029 from the source system | the missing record |
| Order records for 1009, 1025 | whether 50% and 90% discounts were authorized |
| Return dates, and return policy terms | real return rates instead of floors |
| Order history, prior 12 months | baseline, seasonality, and whether any of this is new |
| Post-export return status of order 1016 and C115 history | bulk buyer vs drain pattern |

## Appendix: definitions

Revenue = units x unit price x (1 - discount%). Returned orders count $0
revenue with shipping treated as sunk. Contribution = net revenue - shipping;
manufacturing cost out of scope per the brief. Every figure computed from
[sql/](sql/) and independently recomputed before publication.
