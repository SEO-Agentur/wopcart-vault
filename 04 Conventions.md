# 04 Conventions

Match these exactly. The existing 114 files are consistent.

## PHP style

- **WordPress Coding Standards.** Tabs for indent. `array()` not `[]`. Yoda not required
  but spacing inside parens is: `foo( $bar )`.
- `declare(strict_types=1);` at the top of every file, after the docblock.
- Every file, class, method and property has a docblock. Typed `@param` / `@return`.
- `final class` unless something genuinely needs extending (`AbstractGateway`, `Stripe`).
- PHP 8.1 features are used freely: `match`, enums-as-constants, readonly promoted
  properties, union return types (`array|\WP_Error`), nullsafe `?->`.

## Comments

**Comment the *why*, never the *what*.** The codebase's distinguishing feature is that
non-obvious decisions are explained where they are made. Examples of the register:

> *"Allocating at pending-order time would burn numbers on abandoned checkouts, leaving
> exactly the gaps the rules object to."*

> *"Deliberately identical to the 'not found' response. A caller probing for valid keys
> should not be able to tell a malformed guess from a well-formed one that does not exist."*

Do not write `// Loop through items`. Do write a sentence explaining a subtle constraint.

## Money

**Integer minor units everywhere** in storage and calculation. `Support\Money` handles
conversion, currency decimals (0/2/3), formatting, and proportional allocation
(`allocate_by()` splits a discount across lines without losing a cent).

Convert to major units only for display and when reading user input.

## Security

- Every mutating form/AJAX endpoint verifies a nonce.
- Every admin action checks a capability.
- All output escaped: `esc_html`, `esc_attr`, `esc_url`, `wp_kses_post`.
- All SQL via `$wpdb->prepare()`. Direct queries carry a `phpcs:ignore` comment.
- Bearer-style credentials compared with `hash_equals()`.
- File paths confined to the uploads tree with `realpath()` + prefix check.

## Hooks

Prefix `dcart_`. Every extension point has a docblock. Filters are named for what they
return: `dcart_calculate_totals`, `dcart_tax_rate`, `dcart_license_issued`.

## Templates

- Docblock listing every `@var` the template receives.
- `if ( ! defined( 'ABSPATH' ) ) { exit; }` guard.
- Header comment: `Override by copying to yourtheme/digital-cart/<name>.php`
- Classes namespaced `dcart-` following loose BEM: `.dcart-card__title`.
- Data attributes for JS hooks: `data-dcart-cart`, `data-dcart-submit`.

## Verification

```bash
for f in $(find . -name "*.php" -not -path "./vendor/*"); do php -l "$f" > /dev/null || echo "FAIL $f"; done
```
