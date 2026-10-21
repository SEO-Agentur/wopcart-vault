# Licensing

`src/Licensing/` + `client/class-digitalcart-updater.php`. EDD's strongest paid feature.

## Files

| File | Role |
|---|---|
| `LicenseKeys.php` | 128-bit key generation, site URL normalisation, environment classification |
| `License.php` | Model: status, seats, expiry, activations |
| `LicenseManager.php` | Issuance, activate/deactivate, expiry cron, renewal extension |
| `Api.php` | Public REST + legacy form-post endpoints |
| `Updates.php` | Version metadata + signed package delivery |
| `client/class-digitalcart-updater.php` | Drop-in the merchant ships inside their product |

## Tables

`wp_dcart_licenses`, `wp_dcart_license_activations`.

## Load-bearing decisions

- **`is_valid()` ≠ `can_receive_updates()`.** Expiry stops updates, not the software.
- **Site identity is normalised** (protocol/www/port/path stripped) before comparison, so
  `https://www.x.com` and `x.com` are one seat.
- **Local/staging activate free.** Configurable via `dcart_license_free_environments`.
- **Bundles issue a parent key plus child keys**, so each contained product's own updater
  validates against a real license while the customer holds one key.
- **A key for product A must not validate product B** — `Api::covers_product()`.
- **Malformed and not-found keys return identical responses** so probing cannot distinguish.
- **Metadata is public, the package is not.** Download URLs are signed, expire in an hour,
  and bind license + product + site + expiry. Entitlement is re-checked *at download time*.

## Endpoints

REST: `/wp-json/digital-cart/v1/license/{activate,deactivate,check,version}`
Legacy form-post: `?dcart_action={activate_license,deactivate_license,check_license,get_version}`

Both accept `license`, `item_id`, `url`, `version`. Errors return stable machine-readable
codes: `missing_license`, `license_expired`, `no_activations_left`, `invalid_item_id`,
`rate_limited`.

## Remaining — Task 21

Expiry reminder emails, renewal discount flow, admin license management screen
(extend, disable, raise seat limit, view activations).
