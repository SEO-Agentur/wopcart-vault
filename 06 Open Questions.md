# 06 Open Questions

Things needing the user's decision. **Ask before assuming.**

## 1. Monetisation — RESOLVED 2026-08-17

**Decided: 2% on the free plan via Stripe Connect, 0% on paid. €9/mo up to €50k annual
sales, €29/mo above.** Full rationale in [[05 Decisions Log]].

`readme.txt` has been rewritten: the "No Platform Fees" claim is gone and the fee, the
Connect routing and the gateway restriction are disclosed explicitly.

**Not yet built.** The code still runs at 0% with direct merchant keys. What Connect needs
is tracked on the kanban board (project `digital-cart`). Blocking inputs before that work
can start are listed as question 6 below.

## 2. InvoicesGenerator API spec — not needed, but useful

The connector is push+poll so their side needs nothing from us. But I still do not know:
- Does their service return a hosted PDF URL, a binary, or both?
- Does it send the invoice email itself, or should DigitalCart attach it to our receipt?

Neither blocks anything. The `ack` endpoint accepts `external_id` + `external_url` already.

## 3. Software licensing scope — CONFIRMED, now fully built

User confirmed: *"confirmed. this is what i need"*. Keys, activation API, update server and
the client drop-in were already done. **Task 21 is now complete**: `Licensing\ExpiryNotices`
sends the pre-expiry warning and the lapsed notice, the renewal discount rides in on the
existing `?discount=` handler that `DiscountController` already understands, and
**DigitalCart → Licenses** lists keys with extend / disable / enable controls.

Both emails deliberately say the software keeps working and only updates stop — consistent
with the settled decision that expiry is not a kill switch.

## 4. Design direction — ANSWERED

User chose, from options offered:

- **Storefront: neutral and theme-deferring.** Inherit the theme's type and buttons; style
  only layout and structure; one `--dcart-accent`; 1px borders; no shadows or gradients.
- **Admin: native wp-admin.** Reuse `.wrap`, `.wp-list-table`, `.postbox`,
  `.nav-tab-wrapper`; `admin.css` adds only what core has no equivalent for, so admin
  colour schemes keep working.

Both are built. This question is closed unless the user wants to revisit it once they can
see it rendered.

## 5. Screenshots for readme.txt — outstanding

`readme.txt` references six screenshots that do not exist. They are needed for a
WordPress.org listing but for nothing else, and they cannot be taken until the plugin has
been run in a real install with sample data.

## 6. Stripe Connect implementation — BLOCKING INPUTS NEEDED

Before the 2% can be built, three things have to come from the user:

1. **Does a platform Stripe account exist**, with Connect enabled, and is it Standard,
   Express or Custom? This decides the onboarding flow and who carries chargeback
   liability. Express is the usual choice for this shape of product.
2. **What is the source of truth for "this site is on a paid plan"?** The fee is
   structural, but the own-keys unlock is not — something has to answer the question.
   Options: an entitlement endpoint on the user's own server, or Connect account metadata.
3. **Who is the merchant of record on the free plan?** With `application_fee_amount` on a
   direct charge to a connected account, the merchant stays the merchant — which is what
   keeps EU VAT and invoicing correct and must not change.

## 7. Third-party compatibility — SCOPE UNCLEAR

User asked for compatibility with **WPML, Divi, Elementor, BuddyPress, WP Job Board,
WooCommerce**. Elementor is already done (8 widgets). The rest is unscoped:

- **WPML** — needs `wpml-config.xml`, translatable product meta, and a decision on whether
  a translated product shares the parent's licences, orders and stock.
- **Divi** — a module set mirroring the Elementor widgets. Both delegate to the shortcodes,
  so this is presentation work rather than logic.
- **BuddyPress** — unclear what is wanted: purchases on a member profile, group-gated
  products, or activity entries. Needs a decision.
- **WP Job Board** — ambiguous plugin name. Probably WP Job Manager, but must be confirmed
  before anything is written against it.
- **WooCommerce** — this is *coexistence*, not integration: both plugins define a cart, a
  session and a checkout, and the requirement is that having both active breaks neither.
  Needs a conflict audit, not a feature.
