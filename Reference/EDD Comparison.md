# EDD Comparison

The positioning. Compared against **Easy Digital Downloads' free version**; the tier prices
are from the user's own screenshot of EDD's pricing page.

## EDD Free's three real weaknesses

1. **Its free Stripe gateway charges an extra 3% per transaction.** A store doing €50k/year
   hands Stripe ~€1,450 *and* EDD ~€1,500. This is the single strongest wedge and the
   reason [[../06 Open Questions|the 2% fee question]] matters so much.
2. Everything in the user's 17-item brief that EDD gates behind $199–$499/year.
3. **No EU VAT handling at all.** For a European seller that is a legal blocker, not a
   missing feature.

## Where EDD Free is genuinely strong — parity we must match

Unlimited products, cart and checkout, PayPal, basic discounts, file downloads,
**a REST API**, **CSV exporters**, **GDPR privacy tools**, product bundles, basic reports.

Status: REST API written (untested), GDPR done, **CSV exporters still missing** (Task 12).

## Feature table

**Verified against easydigitaldownloads.com/pricing on 2026-08-17.** Earlier versions of
this file quoted dollar figures from memory; these are the tiers as published.

EDD tiers: **All Access €499.50** (3 sites) · **Professional €299.50** (2) ·
**Extended €199.50** (1) · **Personal €99.50** (1) · **Lite free**.

| | Lite (free) | Personal €99.50 | Extended €199.50 | Professional €299.50 | DigitalCart |
|---|---|---|---|---|---|
| Platform fee on payments | **3%** | **3%** | 0% | 0% | **2% free / 0% paid** |
| Subscriptions & trials | ❌ | ✅ | ✅ | ✅ | ✅ |
| Variable Pricing Switcher (upgrades) | ❌ | ✅ | ✅ | ✅ | ❌ **gap (#128)** |
| Software Licensing | ❌ | ❌ | ❌ | ✅ | ✅ |
| Multi-currency | ❌ | ✅ | ✅ | ✅ | ✅ |
| EU VAT compliance | ❌ | ✅ | ✅ | ✅ | ✅ (+ VIES reverse charge) |
| Abandoned cart recovery | ❌ | ✅ | ✅ | ✅ | ✅ |
| AI recommendations | ❌ | ✅ | ✅ | ✅ | ✅ (Claude) |
| Content restriction | ❌ | ✅ | ✅ | ✅ | ✅ |
| Product bundles | ❌ | ✅ | ✅ | ✅ | ✅ |
| Customer reviews | ❌ | ✅ | ✅ | ✅ | ✅ |
| Authorize.net / 2Checkout | ❌ | ❌ | ✅ | ✅ | ✅ |
| Apple Pay | ✅ | ✅ | ✅ | ✅ | ✅ |
| Mailing-list integrations (8) | ❌ | ✅ | ✅ | ✅ | ❌ (via Zapier) |
| Multi-vendor marketplace | ❌ | ❌ | ❌ | ✅ | ❌ (different product) |
| Fraud monitor / MaxMind | ❌ | ❌ | ❌ | ❌ (All Access only) | ❌ |

## The two conclusions that matter

**1. Price threshold.** Doing "subscription levels with different licence types" on EDD needs
**Professional, €299.50/yr** — Software Licensing does not appear before that tier, while
Subscriptions arrive at Personal. DigitalCart does it on the free plan.

**2. The fee is the real wedge, not the feature count.** EDD is fee-bearing on its two
cheapest plans and only reaches 0% at €199.50/yr. Evidence on the pricing page: Stripe,
Square and PayPal carry amber rather than green marks on Lite and Personal, and
"No Platform Fees" is absent from Personal's own feature list while present from Extended
upward.

## The one genuine gap

**Variable Pricing Switcher** — EDD ships it in *every* paid tier from €99.50. It is the
only feature EDD's cheapest paid plan has that DigitalCart lacks, and it sits in exactly the
subscription/licence area the product leads on. Tracked as **#128**.
