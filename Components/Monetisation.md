# Monetisation

**Decided 2026-08-17.** Supersedes the earlier "no platform fees" positioning.

## The model

| Plan | Fee | Gateways | How payments route |
|---|---|---|---|
| **Free** | **2%** per transaction | Stripe + Apple Pay only | Through DigitalCart's Stripe Connect **Express** platform |
| **€89 flat** | 0% | all five | Merchant's own API keys |

**Open:** €89 per year or one-off? Per year is assumed throughout, because it matches the
EDD comparison and because a one-off price cannot fund ongoing gateway maintenance.

The earlier €9/€29 revenue ladder was dropped deliberately: a revenue threshold means
telling a merchant at €49,980 that €20 more will break their shop, which is not a
defensible product experience. A flat price removes the measurement, the warnings and the
blocking mechanism entirely.

## Shape: one plugin, settings unlock (decided 2026-08-17)

A single GPL plugin on WordPress.org containing every feature. Paying unlocks the fields
for the merchant's own gateway keys; no extra code is shipped. Licensing, downloads,
subscriptions, VAT, paywall — all identical on both plans. The plan decides **how a payment
is routed**, never what the merchant can do.

Consequence: a free-plan merchant can run a complete software business — sell licences,
issue keys, serve updates — and pays 2% of it. That is the model working, not a concession:
the more they earn, the more we do, and nothing has to be withheld to make that true.

The plan check runs **only when a licence key is present**, so a free install never phones
home.

## Why this shape

A flat fee written into a GPL plugin is roughly twenty deletable lines, so advertising one
would be a claim that could not be stood behind. Here the fee is **structural**: on the free
plan the merchant has no gateway credentials of their own, and the only way they can take a
payment at all is through the platform account. Nothing has to be enforced, so no licence
server is needed for the fee.

Free users are therefore *pushed* onto the ladder by the fee itself rather than by a feature
wall — which is why no feature is withheld from the free plan.

## Connect Express, and why

Stripe hosts onboarding and identity verification. Crucially the charge is a **direct charge
to the connected account with `application_fee_amount`**, so:

- the **merchant remains merchant of record** — which is what keeps the existing EU VAT
  determination, invoice numbering and reverse charge correct. Any arrangement that made
  DigitalCart the merchant of record would invalidate all of that.
- **chargeback liability stays with the merchant**, not the platform.

## Free plan is Stripe and Apple Pay only

PayPal, Authorize.net and 2Checkout expose no application-fee mechanism. Offering them on
the free plan would be an open bypass of the 2%, so they are paid-plan only — where the
merchant is using their own credentials anyway and there is nothing to bypass.

## The enforcement asymmetry — known and accepted

- The **2% is structural** and cannot be removed without giving up the ability to charge.
- The **paid-plan gate** that unlocks own-key entry is ordinary GPL code and *is* deletable.
  Someone who removes it becomes a 0% user.

The exposure is bounded by having to re-patch on every update, and it is simply the price of
shipping GPL. It is not worth building obfuscation against.

## Two different "licences" — never conflate them

This is the single easiest thing to get wrong in this codebase.

| | Who licenses whom | Where it lives |
|---|---|---|
| **DigitalCart plan** | You → the shop owner. Free/2% or paid/0%. | not built yet, see #130 |
| **`Licensing` module** | The shop owner → their own customers. Keys, seats, updates. | `src/Licensing/`, complete |

A merchant who sells no software at all still has a DigitalCart plan. Resolving the plan
through `Licensing` would make revenue depend on a table the merchant fills in themselves.

## Competitive position

EDD charges **3%** on Lite and Personal and only reaches 0% at **Extended, €199.50/yr**.
So 2% undercuts their free tier, and €89/yr undercuts EDD's cheapest paid plan (€99.50) as
well as their €199.50 fee-free threshold. See [[Reference/EDD Comparison]].

## Build status

**Built (#132):** `Gateways\Connect` holds the platform state and the fee arithmetic.
`Stripe::api()` swaps in the platform key and sends `Stripe-Account`; the Checkout Session
carries `application_fee_amount` for one-off payments and `application_fee_percent` for
subscriptions; `ApplePay::create_intent()` carries the fee too; `Registry::available()`
hides fee-less gateways on the free plan. 8 unit tests cover the arithmetic and the clamps.

**Not built:** Express onboarding (#131), the entitlement check behind
`dcart_is_paid_plan` (#133/#134), and the privacy documentation of the new data flows
(#147).

`Connect::is_paid_plan()` currently returns **false** by default, so a fresh install is on
the free plan with no connected account — and therefore cannot take a payment at all until
onboarding exists. That is the correct starting state, not a bug.

## See also

[[Components/Payments]] · [[Components/Licensing]] · [[05 Decisions Log]]

## Mindestlaufzeit (seit Kern 1.5.0)

**Stand:** 2026-10-24 · **Asana:** [STORY] Mindestlaufzeit für Abos

Eine Preisoption kann eine **Mindestlaufzeit in Abrechnungsperioden** tragen. Sie ist
ausdrücklich **keine Vorauszahlung**: Abgerechnet wird weiter Periode für Periode, nur die
Wirkung einer Kündigung verschiebt sich auf das Ende der Bindung. Anlass war der erste
echte Händler mit Paketen zu 2.500 und 5.000 im Monat — quartalsweise Abrechnung hätte
7.500 bis 15.000 im Voraus bedeutet und wäre unverkäuflich gewesen.

### Wie es läuft

1. `Price::minimum_term` am Preis, gedeckelt auf 10 Perioden (`wopcart_maximum_minimum_term`),
   und nur bei wiederkehrenden Optionen.
2. Beim Anlegen des Abos wird daraus das Datum `committed_until`, berechnet mit
   `Price::commitment_ends_at()`. Es läuft **den Abrechnungskalender entlang**, landet also
   immer auf einem Buchungstag: drei Monatsperioden ab dem 31. Januar enden am 28. April,
   weil der Buchungstag im Februar auf die 28 klemmt und dort bleibt. Eine Testphase liegt
   **vor** der Bindung, nicht darin.
3. Kündigt der Kunde, während noch eine Buchung in die Bindung fällt, wird **das Gateway
   nicht angefasst**. Es bekäme sonst „zum Ende dieser Periode beenden" — genau das, was
   während einer Bindung nicht passieren darf. Stattdessen: Vermerk in den Meta-Daten,
   `expiration` auf das Bindungsende.
4. Nach der Buchung, die die letzte Periode der Bindung abdeckt, wird daraus eine ganz
   gewöhnliche Kündigung zum Periodenende — und die endet auf den Tag genau mit der Bindung.
   Die Übergabe sitzt dort, wo Verlängerungen verbucht werden, gilt also für Webhook-Gateways
   und selbst abgerechnete gleichermaßen. Im Verlängerungslauf steht ein zweites Netz.
5. Kündigung in der letzten Periode wird **nicht** aufgeschoben: Die normale Kündigung endet
   ohnehin mit der Bindung.

### Warum kein `cancel_at` bei Stripe

Der erste Entwurf wollte Stripe ein absolutes Enddatum schicken und dafür die
`ProxyPolicy` der Plattform öffnen. Nicht nötig: Die Übergabe nach der letzten Buchung
benutzt den vorhandenen, erprobten Weg „zum Periodenende kündigen" und funktioniert für
jedes Gateway gleich. Die Feldliste der Plattform bleibt damit so eng wie sie ist — sie
existiert, weil `application_fee_percent` und `transfer_data` dort Geld umleiten könnten.

### Wo es sichtbar ist

Vor dem Kauf als Länge (Produktseite, Warenkorb, Kaufknopf), danach als Datum (Konto,
Kündigungsdialog und -strecke, Adminliste, `committed_until` in Webhooks und MCP).
Eine aufgeschobene Kündigung zählt sofort als Abwanderung im At-Risk-Bericht.

### Grenzen

Bestandsabos haben keine Bindung und bekommen keine. Upgrade, Erstattung und
fehlgeschlagene Zahlung **innerhalb** der Bindung laufen wie bisher — dort ist noch nicht
entschieden, ob die Bindung mitwandern soll. Der 14-Tage-Widerruf für Verbraucher bleibt
unberührt und sticht jede Bindung.
