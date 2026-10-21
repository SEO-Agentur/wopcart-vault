# Webhooks

`src/Webhooks/Webhooks.php` + `Payloads.php`. The transport [[Invoicing]] rides on.

## Properties

- **Queued, not inline.** A slow endpoint must never add latency to a checkout or be able
  to fail one. Drains on cron plus a best-effort flush at `shutdown`.
- **HMAC-SHA256 signed**, Stripe-shaped header: `X-DCart-Signature: t=…,v1=…` over
  `{timestamp}.{body}`. The timestamp is inside the signed material, which is what stops
  replay.
- **Exponential backoff**, parked after 6 attempts, manually replayable.
- **HTTPS only** — plaintext would put names, addresses and VAT numbers on the wire.

## Events

`order.completed`, `order.refunded`, `invoice.issued`, `invoice.credited`,
`subscription.renewed`.

## Payload conventions

- **Money is sent twice** — integer minor units *and* a decimal string. The integer is
  authoritative and survives any language's float handling; the decimal spares the receiver
  needing to know the currency's decimal places.
- **Tax is broken down per rate**, never summarised — an invoice mixing standard and reduced
  rates legally has to show both, and a receiver cannot reconstruct that from a total.

## Tables

`wp_dcart_webhooks`, `wp_dcart_webhook_deliveries`.

Note: `Integrations\Zapier\Zapier` has its own older, simpler delivery queue. It predates
this subsystem and could be migrated onto it later.
