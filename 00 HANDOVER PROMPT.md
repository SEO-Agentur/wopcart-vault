# 00 HANDOVER PROMPT

> **Paste everything below the line into a fresh Claude Code session** started in
> `/Users/cyrusbadde/projects/plugins/`. It is written to be read by an AI, not a human.

---

You are continuing work on **DigitalCart**, a WordPress e-commerce plugin at
`/Users/cyrusbadde/projects/plugins/digital-cart/`. A previous session built the entire
PHP layer. Your job is to finish the presentation layer and ship it.

**Read these first, in this order:**
1. `../digital-cart-vault/03 Build Status.md` — exactly what exists and what does not
2. `../digital-cart-vault/04 Conventions.md` — how to write code in this project
3. `../digital-cart-vault/05 Decisions Log.md` — choices already made; do not relitigate them
4. `../digital-cart-vault/06 Open Questions.md` — what still needs the user's input

## What this is

A free WordPress plugin positioned as a direct replacement for **Easy Digital Downloads'
free version**. It ships, for free, roughly $300/year of features EDD gates behind its
$199–$499 tiers, plus three things EDD has at no price: multi-currency, LLM-based product
recommendations, and VIES-validated EU reverse charge.

## Current state

- **98 PHP classes** in `src/` — all parse cleanly, all wired into the container
- **16 templates** in `templates/` — storefront is done, admin is not
- **0 assets** — this is blocking
- The plugin **cannot yet be installed and used**: no CSS/JS, no admin screens, no readme

## Your critical path, in order

1. **Assets** (blocking) — `assets/css/frontend.css`, `assets/js/frontend.js`,
   `assets/js/checkout.js`, `assets/css/admin.css`, `assets/js/admin.js`.
   `checkout.js` is not cosmetic: it drives the Apple Pay payment sheet and
   Authorize.net Accept.js tokenisation. Those two gateways cannot take a payment without it.
2. **Admin templates** (blocking) — 11 files under `templates/admin/`. Without
   `settings.php` nothing in the plugin can be configured at all.
3. **Root files** — `readme.txt`, `uninstall.php`, `composer.json`, `phpcs.xml.dist`,
   `phpunit.xml.dist`, `.distignore`, `LICENSE`.
4. **Task 21** — license expiry emails, renewal discount flow, admin license controls.
5. **Tasks 12 and 14** — CSV export/import, WP-CLI commands. Both are EDD-free parity gaps.

## Hard rules

- **Monetisation is DECIDED (2026-08-17): 2% on the free plan via Stripe Connect Express,
  0% on paid (€9/mo to €50k sales, €29/mo above).** This supersedes the earlier "never add
  a platform fee" rule. See `05 Decisions Log.md`. The code still runs at 0% with direct
  keys; Connect is tracked as epic #130 on the kanban board.
- **Keep DigitalCart's own plan separate from the merchant's `Licensing` module.** They are
  different things: the plan is you billing the shop owner, `Licensing` is the shop owner
  billing their customers. Never resolve one through the other.
- **Do not invent the InvoicesGenerator API.** The connector is built as push+poll precisely
  so their side needs no client library from us. Do not add an HTTP client for it.
- **Money is always integer minor units** in storage and calculation. Convert to major units
  only at the display boundary and when accepting user input. `Support\Money` does this.
- **Run `php -l` on every file you write.** The previous session did this on all 114 files.
- Match the existing code style exactly — see `04 Conventions.md`.

## Verify before you start

```bash
cd /Users/cyrusbadde/projects/plugins/digital-cart
for f in $(find . -name "*.php" -not -path "./vendor/*"); do php -l "$f" > /dev/null || echo "FAIL $f"; done
```

Then read `03 Build Status.md` for the file-by-file inventory.
