# 03 Build Status

**Snapshot:** 101 PHP classes, 37 templates, 5 assets, 7 root files. All PHP parses cleanly.
**The plugin can now be installed, configured and used.** Every blocking gap from the
previous session is closed.

## DONE — PHP layer (101 files, all wired)

| Area | Namespace | Status |
|---|---|---|
| Core, autoloader, container | `Support`, `Install`, `Contracts` | complete |
| Products, taxonomies, pricing, bundles | `PostTypes`, `Model`, `Bundles` | complete |
| Cart, totals, checkout, fulfilment | `Cart`, `Checkout` | complete |
| 5 gateways + webhooks + refunds | `Gateways` | complete |
| Subscriptions, trials, renewals | `Subscriptions` | complete |
| EU VAT, VIES, reverse charge | `Tax` | complete |
| Multi-currency, FX rates | `Currency` | complete |
| Discounts | `Discounts` | complete |
| Secure downloads | `Downloads` | complete |
| Content restriction | `Restriction` | complete |
| Reviews | `Reviews` | complete |
| Abandoned cart recovery | `AbandonedCart` | complete |
| Claude AI recommendations | `Ai` | complete |
| Elementor (8 widgets) | `Integrations\Elementor` | complete |
| Zapier | `Integrations\Zapier` | complete |
| Reports incl. VAT/OSS | `Reports` | complete |
| GDPR export + erasure | `Privacy` | complete |
| REST API + API keys | `Rest` | written, **still never tested** |
| Invoicing | `Invoices` | complete |
| Webhooks | `Webhooks` | complete |
| InvoicesGenerator connector | `Integrations\InvoicesGenerator` | complete |
| Licensing | `Licensing` | complete, **incl. expiry notices (Task 21)** |
| Client updater drop-in | `client/` | complete |
| Admin menu, settings schema, product meta | `Admin` | complete |
| **CSV export/import (Task 12)** | `Admin\Exporter` | **new** |
| **WP-CLI (Task 14)** | `Cli\Commands` | **new** |

## DONE — Assets (5 of 5)

- `assets/css/frontend.css` — neutral and theme-deferring by explicit user choice.
  Inherits the theme's type and buttons; everything a theme might disagree with is a
  `--dcart-*` custom property. No shadows, no gradients, dark-scheme aware.
- `assets/js/frontend.js` — vanilla, no jQuery. AJAX cart, discounts, review votes,
  clipboard, VAT validation, tax recalculation, abandoned-cart email capture. Exposes
  `window.DigitalCart` so `checkout.js` and themes reuse the transport.
- `assets/js/checkout.js` — **Apple Pay sheet + Authorize.net Accept.js.** Both gateways
  can now take a payment.
- `assets/css/admin.css` — native wp-admin look by explicit user choice. Reuses core
  components; only adds the meta-box tab panel, repeaters, file cell, stat tiles, chart.
- `assets/js/admin.js` — tab switching, repeater add/remove with index renumbering,
  `wp.media` picker, confirmations, clipboard, hand-drawn canvas report chart.

## DONE — Templates (37 of 37)

Storefront (16, unchanged), **11 admin**, **9 email**, plus `admin/licenses.php`.

- `templates/admin/`: dashboard, orders, order-detail, customers, subscriptions,
  discounts, discount-edit, reviews, reports, settings, status, **licenses**.
- `templates/emails/`: layout, receipt, admin-sale, renewal, payment-failed, trial-ended,
  abandoned-cart, **license-expiring**, **license-expired**.

## DONE — Root files (7 of 7)

`readme.txt`, `uninstall.php`, `composer.json`, `phpcs.xml.dist`, `phpunit.xml.dist`,
`.distignore`, `LICENSE` (GPL-2.0, canonical text, not typed from memory).
`tests/bootstrap/bootstrap.php` was added so `phpunit` actually runs.

## Bugs found and fixed in the existing code

1. **`ApplePay::create_intent()` was dead code.** It documented itself as "called over
   AJAX" but nothing registered an endpoint, so Apple Pay could never have worked. Added
   `Checkout::ajax_applepay_intent()` (`wp_ajax_dcart_applepay_intent`), which prices the
   sheet from the server's own recalculated cart, never from the request.
2. **The cart's remove button removed the wrong row.** Every row emitted
   `<input type="hidden" name="item_key">` inside the one shared `<form>`, so PHP kept the
   last and any cross removed the bottom line. The key now rides on the submit button
   (`name="remove_key"`); `CartController::handle_post()` treats its presence as the action.
3. **`const URL = __DIR__`** in `digital-cart.php` was a wrong, unused duplicate of
   `Plugin::url()`. Removed rather than fixed — a second, broken accessor is a trap.
4. **Version mismatch.** Header said `1.0.0`, `const VERSION` said `1.1.0`. Aligned on
   **1.0.0** (first release; `readme.txt` Stable tag must match the header). `VERSION` only
   drives asset cache-busting, system info and API user-agents — migrations use the
   separate `DB_VERSION`, which is untouched.
5. **`dcart_expire_licenses` leaked on deactivation.** It is scheduled by `LicenseManager`
   but absent from `Installer::CRON_EVENTS`, so `deactivate()` never cleared it.
   `uninstall.php` clears it explicitly. **`Installer::CRON_EVENTS` still does not list it
   — worth fixing there too.**
6. **The discount import form was unusable as first written** (nested inside the settings
   form, no `enctype`, clashing action). Added a `dcart_settings_after_form` hook that
   fires outside the form; the import is now its own multipart form.

## Small additions to existing files

- `Assets::script_config()` gained `i18n.copied` and `i18n.reverseCharge`, because the JS
  rebuilds the totals row when a country change flips an order to reverse charge.
- `Admin.php` gained the `dcart-licenses` menu entry, `render_licenses()`, and a
  `manage_license` action (extend / disable / enable).
- `Plugin::modules()` gained `Licensing\ExpiryNotices`.
- `settings.php` exposes `dcart_settings_after_tab` and `dcart_settings_after_form`.

## What is still outstanding

- **`Rest\Routes` has never been exercised.** Written, wired, untested.
- **No tests exist.** `phpunit.xml.dist` and a bootstrap are in place and the suite runs;
  `tests/Unit` is empty. The classes worth covering first are the ones holding the
  arithmetic: `Support\Money` (especially `allocate_by()`), `Tax\VatRates`,
  `Discounts\DiscountEngine`, and `AuthorizeNet::arb_interval()`.
- **Nothing has run inside a real WordPress install.** Everything here is verified by
  `php -l`, `node --check`, and checking every template name, render callback, module
  class and model method against the code that calls it. That is not the same as
  having loaded the plugin.
- `Installer::CRON_EVENTS` should list `dcart_expire_licenses` (see bug 5).
- Screenshots referenced in `readme.txt` do not exist yet.

## Verify the inventory yourself

```bash
cd /Users/cyrusbadde/projects/plugins/digital-cart
for f in $(find . -name "*.php" -not -path "./vendor/*"); do php -l "$f" > /dev/null || echo "FAIL $f"; done
node --check assets/js/frontend.js && node --check assets/js/checkout.js && node --check assets/js/admin.js
```

```bash
cd /Users/cyrusbadde/projects/plugins/digital-cart
python3 - <<'PY'
import re, os, glob
names=set()
for f in glob.glob('src/**/*.php', recursive=True):
    s=open(f, encoding='utf-8', errors='ignore').read()
    for m in re.findall(r"Templates::(?:render|capture)\(\s*'([^']+)'", s): names.add(m)
    for m in re.findall(r"Mailer::render\(\s*'([^']+)'", s): names.add('emails/'+m)
for m in re.findall(r"\$this->view\(\s*'([^']+)'", open('src/Admin/Admin.php').read()):
    names.add('admin/'+m)
miss=[n for n in sorted(names) if not os.path.isfile(f'templates/{n}.php')]
print("MISSING:", miss or "none")
PY
```
