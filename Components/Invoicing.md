# Invoicing

`src/Invoices/` + `src/Integrations/InvoicesGenerator/Connector.php`

## Two tiers

1. **Built-in, free, no dependency** — sequential numbering, VAT-compliant document,
   print stylesheet. Works standalone.
2. **Connected** — pushes to invoicesgenerator.net (the user's own SaaS) for hosted PDFs.
   Off by default.

## Numbering

`InvoiceNumbers.php`. Atomic via MySQL `LAST_INSERT_ID(next_value + 1)` — a read-then-write
in PHP would hand two concurrent checkouts the same number.

Format `WP-2026-00001`. Series restarts yearly. Numbers are allocated **only when an order
is genuinely payable**; allocating at pending-order time burns numbers on abandoned
checkouts and leaves the gaps auditors object to. `find_gaps()` lets the merchant see a gap
before an inspector does.

## The snapshot

`Invoice::issue()` freezes seller, buyer, lines, per-rate tax breakdown and legal notes.
The document renders from the freeze, never live order data. Fields follow **Article 226 of
the EU VAT Directive**.

Refunds issue a separately-numbered **credit note**.

## The connector — push + poll

Per the user's other session: DigitalCart is just another `IntegrationProvider`, same shape
as WooCommerce/Shopify. **We do not implement their API.**

| Purpose | Endpoint |
|---|---|
| Connection test | `GET /wp-json/digital-cart/v1/invoicing/ping` |
| Backfill | `GET …/invoicing/invoices?since=&unsynced=true` |
| Single | `GET …/invoicing/invoices/{id}` |
| Acknowledge | `POST …/invoicing/invoices/{id}/ack` |

Auth: one shared secret, Bearer or `X-DCart-Token`. It both signs outbound pushes and
authenticates inbound polls, so the merchant pastes one credential.

`ping` returns `numbering.owner: "digitalcart"` explicitly, so their side records the number
rather than minting one.

`unsynced_count()` surfaces on the status screen — a climbing number is the earliest visible
sign the connection has broken.

See [[../05 Decisions Log]] and [[Webhooks]].
