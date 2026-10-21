# 05 Decisions Log

Settled choices. **Do not relitigate these** unless the user reopens them.

## Naming
`DigitalCart` / `digital-cart` / `DigitalCart\` / `dcart_` / `wp_dcart_*`. User chose from
three options. Baked into every file.

## AI recommendations use the Claude API only
User explicitly chose "Claude API only" over a built-in co-purchase algorithm.
Default model **`claude-opus-5`**, effort `low`, structured JSON via
`output_config.format`, catalogue sent as a **cached prompt prefix** so a busy product page
costs one API call per cache window rather than one per visitor. Monthly call cap is a hard
spend ceiling. See [[Components/AI Recommendations]].

## Money as integer minor units
Floats are never used for money. `Money::allocate_by()` distributes discounts across lines
proportionally without losing a cent.

## Custom tables, not `wp_posts`
For orders, customers, subscriptions, licenses, invoices. Products remain a CPT.

## Monetisation: 2% on the free plan, 0% on paid — DECIDED 2026-08-17
User decided. Free plan settles through **DigitalCart's own Stripe Connect platform** and
retains a **2% application fee**; paid plans unlock "paste your own keys" and take 0%.
Paid plan is a **flat €89** (see Monetisation note for the open per-year/one-off question).
**Superseded 2026-08-17:** the earlier €9/€29 revenue ladder was dropped. Telling a merchant
at €49,980 of sales that €20 more breaks their shop is not a defensible product experience,
and it would have required continuous revenue measurement, threshold warnings and a
blocking mechanism — all of which disappear with a flat price.

**Why this shape and not a flat fee:** the plugin is GPL, so a fee written into the code is
~20 deletable lines. Routing free users through the platform account makes the fee
structural — it is the only way they can take a payment at all — so no licence server is
needed to enforce it.

**Consequence, now baked into readme.txt:** the "No Platform Fees" headline is gone. A 2%
fee alongside that claim would have been a straight falsehood and a WordPress.org review
blocker.

**Competitive position (EDD pricing page, verified 2026-08-17):** EDD charges **3%** on its
Lite and Personal plans and only becomes fee-free at **Extended, €199.50/yr**. 2% free
undercuts their free tier, and €9/mo undercuts their fee-free threshold by a wide margin.

**Enforcement asymmetry — known and accepted:** the 2% is structural, but the paid-plan
gate that unlocks own-key entry is ordinary GPL code and therefore deletable. Someone who
removes it becomes a 0% user. The exposure is bounded by having to re-patch on every
update, and it is the price of shipping GPL.

**Free plan is Stripe/Apple Pay only.** PayPal, Authorize.net and 2Checkout expose no
application-fee mechanism, so offering them on the free plan would be an open bypass.

## Paid plan is a settings unlock, not a separate Pro plugin — DECIDED 2026-08-17

**One plugin, on WordPress.org, with every feature in it.** The paid plan unlocks the
fields for the merchant's own gateway credentials — no additional code is delivered, so
there is nothing to download and no second codebase.

**Why not a separate Pro plugin:** it would be *additional* work, not alternative — the
free plugin must stay on WP.org regardless, because that reach is what makes the 2% model
work. Pro would add a second distribution channel, a second codebase, a cliff-edge upgrade
(deactivate, download, reinstall) and a self-inflicted single point of failure: a broken
release would block the very channel the fix has to travel down.

**On licensing the Pro plugin proprietarily / obfuscating it:** legally more open than
first stated — the WordPress derivative-work question is untested, and since we hold all
copyright we may dual-licence our own code. It was rejected on practical grounds instead:
real PHP encoders (ionCube, SourceGuardian) need a server extension the average shared host
lacks, which is disqualifying for a mass-market plugin; weaker obfuscation is trivially
undone; and an encoded blob sitting in the checkout path makes merchants *less* willing to
trust it, not more. Worth revisiting only if the paid tier ever carries substantial extra
code. **The licence question should be checked by a lawyer before launch.**

**What this does not change:** enforcement. The 2% is structural in both variants — it is
collected because the free merchant holds no credentials, not because of any line of code.
See [[Components/Monetisation]].

## Stripe uses hosted Checkout Sessions
Brings SCA, wallet buttons and PCI scope reduction. Apple Pay is a *separate* gateway using
the on-page Payment Request API, because a wallet sheet and a redirect are different UX.

## Gateways that bill their own subscriptions return `dcart_gateway_bills_externally`
The renewal cron treats that error code as "leave this one alone" and pushes the local date
forward. All five gateways bill externally; the cron exists for any gateway that cannot.

## Expiry stops updates, not the software
`License::is_valid()` and `License::can_receive_updates()` are deliberately different
questions. Treating a lapsed license as a kill switch is bad practice and, against a
perpetual licence, unenforceable in several jurisdictions.

## Local and staging sites do not consume a license seat
`.local`, `.test`, private IPs and known host staging patterns activate free. A customer
with one production site who runs out of activations before shipping reads that as a bug.

## Invoice numbering is owned by DigitalCart, namespaced by series
User chose this explicitly. Numbers look like `WP-2026-00001`. The prefix means
invoicesgenerator.net can run its own separate series for manual invoices without
collision. Allocation is atomic via MySQL `LAST_INSERT_ID(next_value + 1)`.

## Invoices render from a frozen snapshot
A product rename or address change must not rewrite a document already filed with a tax
authority. Refunds produce a separately-numbered **credit note**, not a deletion.

## InvoicesGenerator is connected via push + poll, never a client library
Per guidance from the user's other session: DigitalCart is just another `IntegrationProvider`
on their side, same shape as WooCommerce/Shopify. We sign and push invoices, and expose a
poll endpoint for backfill. **We do not implement their API.** See [[Components/Invoicing]].

## Licensing stays in DigitalCart, not in InvoicesGenerator
Same guidance. Licensing is the EDD moat and belongs in the WordPress plugin.
InvoicesGenerator just receives an order webhook and issues an invoice.

## GDPR erasure is anonymisation, not deletion
Tax law requires invoice records for 6–10 years; deleting order rows to satisfy GDPR would
breach it. Personal identifiers are cleared, the financial record survives.

## `wp_remote_post` rather than the official Anthropic PHP SDK
A distributed WordPress plugin cannot require Composer, and bundling a vendored SDK invites
fatal version collisions. The Messages API contract is pinned via `anthropic-version`.

## Zwei Editionen statt gesperrter Funktionen — DECIDED 2026-09-18
Für WordPress.org wird das Plugin aufgeteilt: **WopCart** (kostenlos, vollständig,
Abrechnung über die Plattform mit 2 %), **WopCart Direct** (bezahltes Add-on mit den
eigenen Gateway-Zugängen, 0 %) und **WopCart Platform** (nicht öffentlich, Server-Seite).
Name „Direct“ statt „Pro“, weil „Pro“ mehr Funktionen verspricht, die es nicht gibt.
Add-on statt zweier vollständiger Plugins, weil Kunden beim Kauf nichts austauschen und
der Shop-Code nur einmal existiert. Gelöscht wird in der kostenlosen Version erst, wenn
Direct veröffentlicht ist und eine Release-Runde vergangen ist.
Siehe [[Planning/WordPress-org-Launch]] und [[Components/Editions]].

## Länderabweichung blockiert den Kauf nicht mehr — DECIDED 2026-09-17
IP-Land und Rechnungsland dürfen auseinandergehen (Reise, VPN, Firmensitz). Der Kauf
läuft durch, beide Länder werden gespeichert, die Abweichung wird markiert und ist im
Bestell-Admin und im MwSt.-Bericht sichtbar. Die strenge Prüfung bleibt als Einstellung,
standardmäßig aus, nötig erst ab der EU-Schwelle von 10.000 €. Kartenbetrug erkennt
Stripe Radar besser, als wir es nachbauen könnten. Negative Beträge sind dagegen überall
gesperrt, weil sie im Shop manipulierbar wären.
Siehe [[Security/2026-09-17-Fixes-1.2.3]].

## Ein Schlüssel, und nur im Add-on — DECIDED 2026-09-23
Der Plan-Schlüssel entfällt ersatzlos, statt ins Add-on zu wandern: Es gibt noch keine
Bestandskunden, also muss nichts mitgeschleppt werden. WopCart Direct trägt genau einen
Schlüssel, seine eigene Produktlizenz, ausgestellt von wopcart.com mit WopCart selbst.
Er sichert die Updates ab und zählt die Produktivdomains (Preise nach 1, 10, 100 Domains).
`Platform/Plan.php`, `PlanVerdict.php`, das Plan-Feld, die Plan-Karte und die
Plan-Endpunkte fallen weg (≈750 Zeilen plus Serverseite). Läuft die Lizenz ab, bleiben die
eigenen Gateway-Zugänge aktiv und nur die Updates hören auf.
Siehe [[Components/Editions]].

## Schutz gegen Weiterverkauf: Versorgung statt Sperre — DECIDED 2026-09-24
Die GPL erlaubt Weitergabe und Weiterverkauf; das wird nicht bekämpft. Geschützt wird, was
uns wirklich gehört: Updates und Support hängen an einer gültigen Lizenz, die Plattform
(Stripe Connect, API, Site-Token) betreiben nur wir, die Marke „WopCart“ wird eingetragen,
und jeder Download trägt Kunden- und Lizenznummer, damit ein Leak zuzuordnen ist.
Ausdrücklich **nicht**: Funktionen ohne Schlüssel abschalten oder das Plugin bei
unerreichbarem Server lahmlegen — das trifft nur zahlende Kunden.
Siehe [[Components/Weitergabe und Lizenzschutz]].

## wopcart.com nutzt selbst WopCart Direct — DECIDED 2026-10-20
Ab Kern 1.4.0 gibt es keine Plan-Logik mehr, also auch keine Erkennung der eigenen
Plattform. Statt eine Sonderregel für wopcart.com in das kostenlose Plugin zurückzubauen,
läuft der eigene Shop wie jeder Händler mit eigenen Konten: **WopCart Direct wird dort
installiert**, bevor der Kern auf 1.4.0 geht. Ein Lizenzschlüssel ist dafür nicht nötig,
weil Direct keine Funktion freischaltet.
Die Plattformgebühr von 2 % bei Händlershops ist davon **nicht** betroffen: Sie läuft
weiter über `Platform/ConnectClient.php` im Kern und das Plugin WopCart Platform auf dem
Server. Siehe [[Deployment/WopCart Platform ausrollen]] und [[Components/Editions]].

## Inhaltsseiten ins Markendesign, Karten statt Tabellen — DECIDED 2026-10-21
Die sieben Inhaltsseiten waren im Rumpf ungestaltet. Sie sind in der Blockauszeichnung von
Changelog und Roadmap neu geschrieben. Preise und Vergleiche stehen in Karten, nicht in
Tabellen: `wc-price-card` und `wc-compare-table` sind im Stylesheet auf `.home`
beschränkt, und Karten lesen auf dem Telefon besser. Im Menü gibt es zwei Dropdowns, Docs
und Help; der Punkt „Checkout“ entfällt, weil er nur einen Abschnitt der Startseite
ansprang. Siehe [[Website/Seiten-Redesign 2026-10-21]].

## Design-Klasse über ein zweites mu-plugin — DECIDED 2026-10-21
`body.wc-design` wird von `04-site-design.php` für die September-Seiten gesetzt; wie genau,
ließ sich von hier aus nicht lesen. Statt die Logik zu erraten oder die Datei umzubauen,
kommt `05-design-pages.php` mit einem eigenen `body_class`-Filter für die sieben Slugs
daneben. Ein Filter fügt nur hinzu, WordPress entdoppelt, und das Löschen der einen Datei
nimmt alles zurück. Siehe [[Website/Seiten-Redesign 2026-10-21]].

## Lifetime bleibt unverändert — ERWOGEN UND VERWORFEN 2026-10-21
Erwogen war, die Lifetime-Lizenz nur für die beim Kauf aktuelle Version gelten zu lassen.
Vom Nutzer am selben Tag zurückgezogen. Es bleibt: einmal zahlen, keine Verlängerung,
Updates solange WopCart angeboten wird. Die Fassung auf `/pricing/` und
`/plan-changes-refunds/` bildet das so ab.

## Vault kommt ins Git, privat — DECIDED 2026-10-21
Die Dokumentation ist jetzt ein eigenes Repository (`SEO-Agentur/wopcart-vault`, privat),
weil sie Betriebswissen enthält: VPS-Adresse, Containernamen, Ausroll-Abläufe. Geheimnisse
stehen nicht darin und bleiben in `/opt/wopcart/.env`. Siehe [[Deployment/Git-Repositories]].

## Fremde Plugin-Namen werden doppelt gehakt — DECIDED 2026-10-21
Das Toolkit hat sich von SEO-WP zu Seooptimierung Toolkit umbenannt und Namensraum wie
Filterpräfix mitgenommen, worauf WopCarts Anbindung stillschweigend aufhörte zu greifen.
Statt nur die neuen Namen einzusetzen, hakt 1.4.1 **beide** Präfixe und erkennt **beide**
Konstanten: ein Filter auf einen Haken, der nie feuert, kostet nichts, und eine
Installation, die das Toolkit noch nicht aktualisiert hat, verliert nichts. Dieselbe Regel
gilt künftig für Yoast, Rank Math und AIOSEO. Siehe [[Components/SEO und strukturierte Daten]].
