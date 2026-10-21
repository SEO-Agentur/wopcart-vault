# Payments

`src/Gateways/` — interface, abstract base, registry, five implementations.

## Contract

`GatewayInterface`: `slug()`, `label()`, `is_available()`, `supports()`, `process()`,
`refund()`, `renew()`, `cancel_subscription()`, `handle_webhook()`, `handle_return()`,
`checkout_fields()`.

`AbstractGateway` supplies settings access, webhook/return URLs, idempotent `complete()`,
raw body + header reading, and the boilerplate refusals.

## Routing

`Registry::route()` on `init` dispatches:
- `?dcart-webhook=<slug>` → `handle_webhook()`
- `?dcart-return=<slug>&order=&key=` → `handle_return()` (order key verified first)
- `?dcart-cancel=<slug>&order=` → marks a pending order failed

## The five

| Gateway | Mechanism | Subscriptions | Refunds |
|---|---|---|---|
| Stripe | hosted Checkout Session | Stripe bills | API |
| Apple Pay | on-page PaymentIntent via Stripe | no — falls back to Stripe Checkout | API |
| PayPal | Orders v2 approve→capture; Billing Subscriptions | PayPal bills | API |
| Authorize.net | Accept.js opaque token; ARB | ARB bills | API, needs card last-4 |
| 2Checkout | hosted ConvertPlus redirect | 2CO bills | **control panel only** — MoR |

## Things that will bite you

- **Stripe line items are `quantity: 1` priced at the line total.** Splitting by quantity
  reintroduces rounding drift on discounted lines.
- **Apple Pay verifies the PaymentIntent server-side** against the order's amount and
  currency. Never trust what the browser claims it paid.
- **Authorize.net answers HTTP 200 on failure.** The result code inside the body decides.
  It also returns a UTF-8 BOM that breaks `json_decode` unless stripped.
- **2Checkout requires an echoed acknowledgement** (`<EPAYMENT>date|hash</EPAYMENT>`) or it
  retries for days.
- **PayPal signature verification requires a configured webhook ID.** Without one, events
  are refused rather than trusted.

## Blocked on assets

Apple Pay and Authorize.net **cannot take a payment** until `assets/js/checkout.js` exists.
Apple Pay needs the Payment Request sheet; Authorize.net needs Accept.js tokenisation into
`data-dcart-payment-token` / `data-dcart-payment-nonce`.

See [[../03 Build Status]].
