# File Map

```
digital-cart/
├── digital-cart.php              bootstrap, constants, activation hooks
├── client/
│   └── class-digitalcart-updater.php   drop-in for the merchant's own product
├── src/
│   ├── Autoloader.php  Plugin.php
│   ├── Contracts/      Bootable
│   ├── Support/        Money Options Logger Http Tables Util Geo
│   ├── Install/        Schema Installer
│   ├── Model/          Product Price Order OrderItem Subscription
│   ├── Repository/     Order Customer Subscription Cart Review
│   ├── PostTypes/      Product Taxonomies
│   ├── Cart/           Cart CartItem CartController Calculator Totals
│   ├── Checkout/       Checkout OrderBuilder Fulfillment
│   ├── Gateways/       GatewayInterface AbstractGateway Registry
│   │                   Stripe ApplePay PayPal AuthorizeNet TwoCheckout
│   ├── Subscriptions/  SubscriptionManager
│   ├── Tax/            VatRates Vies TaxContext TaxManager
│   ├── Currency/       Currencies Rates CurrencyManager
│   ├── Discounts/      Discount DiscountRepository DiscountEngine DiscountController
│   ├── Downloads/      Access DownloadLog DownloadHandler
│   ├── Restriction/    ContentRestriction
│   ├── Reviews/        Reviews
│   ├── Bundles/        Bundles
│   ├── AbandonedCart/  Tracker Recovery
│   ├── Ai/             ClaudeClient Recommendations
│   ├── Invoices/       InvoiceNumbers Invoice Invoices
│   ├── Licensing/      LicenseKeys License LicenseManager Api Updates
│   ├── Webhooks/       Webhooks Payloads
│   ├── Emails/         Mailer
│   ├── Reports/        Reports
│   ├── Privacy/        Privacy
│   ├── Rest/           ApiKeys Routes
│   ├── Cron/           Scheduler
│   ├── Frontend/       Templates Assets Shortcodes Blocks
│   ├── Admin/          Admin Settings ProductMeta SystemInfo
│   └── Integrations/
│       ├── Elementor/  Elementor + Widgets/ (8)
│       ├── Zapier/     Zapier
│       └── InvoicesGenerator/ Connector
├── templates/          16 files — storefront done, admin/ and emails/ MISSING
└── assets/             EMPTY — all 5 files missing
```

## The 16 database tables

`orders` `order_items` `customers` `customer_meta` `subscriptions` `discounts`
`discount_uses` `reviews` `carts` `download_log` `currency_rates` `invoices`
`invoice_counters` `licenses` `license_activations` `webhooks` `webhook_deliveries` `logs`
