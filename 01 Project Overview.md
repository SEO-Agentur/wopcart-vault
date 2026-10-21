# 01 Project Overview

**Name:** DigitalCart
**Slug:** `digital-cart` · **Namespace:** `DigitalCart\` · **Prefix:** `dcart_` · **Tables:** `wp_dcart_*`
**Path:** `/Users/cyrusbadde/projects/plugins/digital-cart/`
**Version:** 1.1.0 · **DB Version:** 1.2.0
**Requires:** WordPress 6.4+, PHP 8.1+

## The pitch

A free WordPress plugin that replaces [[Reference/EDD Comparison|Easy Digital Downloads]]'
free tier and much of its paid tiers.

## Original feature brief

The user asked for all seventeen of these. All are implemented in PHP:

Unlimited Products · Full Checkout & Cart · Elementor Integration ·
Subscriptions & Free Trials · Stripe, PayPal & Apple Pay · Authorize.net & 2Checkout ·
Custom Discount Codes · EU VAT Compliance · AI Recommendations · Abandoned Cart Recovery ·
Multi-Currency Support · Content Restriction · Product Bundles · Customer Reviews ·
Zapier Integration · Revenue Reporting

> **Note:** the brief's original "No Platform Fees" item was superseded on 2026-08-17. The
> free plan now carries **2%** via Stripe Connect and only paid plans are 0%. Still a
> better deal than EDD, which charges 3% free and needs €199.50/yr to reach 0% — but it is
> no longer a "no fees" product and must not be described as one.

## Added later, at the user's request

- **[[Components/Licensing]]** — software licensing with an activation API and update
  server. This is EDD's strongest paid feature and the reason plugin/theme sellers stay
  on it. The user confirmed this explicitly: *"confirmed. this is what i need"*.
- **[[Components/Invoicing]]** — EU-compliant VAT invoices plus a connector to
  **invoicesgenerator.net**, a separate SaaS the user built.

## Related links

- [[02 Architecture]] · [[03 Build Status]] · [[04 Conventions]]
- [[05 Decisions Log]] · [[06 Open Questions]]
