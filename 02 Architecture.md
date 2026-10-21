# 02 Architecture

## Bootstrap

`digital-cart.php` → `src/Autoloader.php` (PSR-4, no Composer) → `Plugin::instance()->init()`
on `plugins_loaded` priority 5.

`Plugin::modules()` instantiates ~34 classes implementing `Contracts\Bootable` and calls
`hooks()` on each. Admin, CLI, Zapier and Elementor modules are conditionally added.

## Why no Composer autoloader

A distributed WordPress plugin cannot rely on Composer being installed, and bundling a
vendored autoloader invites fatal class collisions with other plugins. `src/Autoloader.php`
is a 50-line PSR-4 mapper.

## Data layer

**Custom tables, not `wp_posts`.** 16 tables under `wp_dcart_*`. Orders, customers and
subscriptions do not belong in `wp_posts` — a store with 100k orders should not share an
index with every page, revision and menu item on the site.

Products *are* a CPT (`dcart_product`) because they genuinely benefit from the editor,
taxonomies and permalinks.

Schema lives in `src/Install/Schema.php`, written for `dbDelta` (strict: one field per line,
two spaces after `PRIMARY KEY`, `KEY` not `INDEX`).

## Layer map

| Layer | Location | Notes |
|---|---|---|
| Models | `src/Model/` | `Product`, `Order`, `OrderItem`, `Subscription`, `Price` |
| Repositories | `src/Repository/` | Order, Customer, Subscription, Cart, Review |
| Gateways | `src/Gateways/` | Interface + abstract + 5 implementations + registry |
| Frontend | `src/Frontend/` | Assets, Shortcodes, Blocks, Templates |
| Admin | `src/Admin/` | Admin, Settings, ProductMeta, SystemInfo |
| Support | `src/Support/` | Money, Options, Logger, Http, Tables, Util, Geo |

## One rendering path

Shortcodes are the single implementation. Gutenberg blocks (`Frontend\Blocks`) and Elementor
widgets (`Integrations\Elementor\Widgets\*`) both delegate to them. One set of templates
serves all three editors.

## Template overrides

`Frontend\Templates::render($name, $args)` checks `yourtheme/digital-cart/$name.php` first,
then `templates/$name.php`. Themes can override anything.

## See also

[[Components/Payments]] · [[Components/VAT and Currency]] · [[Components/Licensing]] ·
[[Components/Invoicing]] · [[Components/Webhooks]] · [[Components/AI Recommendations]]
