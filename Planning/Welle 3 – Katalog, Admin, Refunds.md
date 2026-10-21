# Welle 3 – Katalog, Admin, Refunds (angefordert 2026-09-14)

Quelle: Nutzer-Feedback zu Admin-Screenshots (Produkt-Editor, Orders, Dashboard, Order-Detail).

## Teil A – Admin & Kundenbereich
| ID | Inhalt |
|---|---|
| W3-A1 | Bugs: Bestelldatum leer (Liste, Dashboard, Detail); Best Sellers gruppiert falsch; Refund-Betrag in Minor Units statt Währung; „Next steps: Connect a payment gateway“ trotz Stripe; WP-Cron-Hinweis trotz Cron-Container |
| W3-A2 | Dashboard-Verkaufsgraph (Umsatz + Käufe, Zeitraum wählbar) |
| W3-A3 | Kunden-Detailseite: was wann gekauft, Lizenzen, Abos, offener Warenkorb |
| W3-A4 | Refund Requests: Kunde fragt an → „Refund requested“ → „Grant refund“/„Decline“; Setting „automatisch genehmigen“ → sofortige Erstattung (inkl. Lizenzsperre + Upgrade-Bestellungen). Deckt die EU-Widerrufsfunktion ab |
| W3-A5 | Dokumente in Admin + My Account: Angebot (neu), Rechnung, Quittung, Gutschrift – ansehen und PDF-Download |
| W3-A6 | Admin-Menü: doppelte Einträge „Products“/„All Products“ zusammenführen, Menü neu ordnen |
| W3-A7 | Integrations-Dashboard: Kachel je Drittanbieter-Verbindung mit Live-Status, letztem Kontakt/Fehler, Einrichten-/Test-Button (Zahlungen, E-Mail, Automatisierung, LMS, Page Builder, Steuer/Rechnung, KI) |

## Teil B – Katalog
| ID | Inhalt |
|---|---|
| W3-B1 | Physische Produkte: Lager, Gewicht, Versandzonen/-arten, Versandadresse, Status „Versendet“ + Tracking |
| W3-B2 | Varianten mit Attributen und Hauptvariante |
| W3-B3 | Hierarchische Produktkategorien; Permalinks `%product-category%` / `%product%`, Basis `/shop/` oder direkt unter der Domain |
| W3-B4 | Zeitplanung „online ab / bis“; Limitierung (Stückzahl gesamt, pro Kunde) |

## Umsetzung
- Plugin ist kein Git-Repo → Snapshot `digital-cart.bak-20260914-before-wave3` vor Beginn.
- Zwei Agents parallel mit getrennter Dateihoheit (A: Admin/Orders/Customers/Refunds/Dokumente; B: Katalog/Checkout-Versand/Permalinks). Gemeinsame Dateien (`Schema.php`, `Plugin.php`, `Options.php`, `Settings.php`) nur mit frischem Lesen vor jeder Änderung; DB-Versionen: A → 1.4.0, B → 1.5.0.
- Danach: gemeinsame Test-Suite, Review, Deploy nach Freigabe, E2E-Test.
- Asana: Aufgaben W3-A1 … W3-B4 im Projekt „WopCart — Feature-Roadmap bis zum Launch“.

## Stand 2026-09-14 (beide Teile gebaut, nicht deployt)
- Test-Suite: 898 Tests grün (vorher 772), `php -l` über src/ und templates/ fehlerfrei. Kein Live-WordPress-Test bisher.
- **Teil A:** Datum-Bug (Timestamp an `mysql2date`), Report-Definition brutto/erstattet/netto einheitlich (Summary, Dashboard, Adminbar, REST, MCP, Graph), Best Sellers je Preisoption, Refund-Betrag in Währung, Next Steps zustandsabhängig, Cron-Hinweis nach letztem Lauf. Neu: `Refunds/*` (Tabelle `wopcart_refund_requests`, atomarer Claim gegen Doppelerstattung, verknüpfte Upgrade-Bestellungen), `Documents/*`, `Quotes/*` (Q-2026-00001), `Customers/CustomerInsights`, `Admin/{Integrations,IntegrationStatus,IntegrationMonitor,MenuOrganizer,NextSteps}`. Bugfix `Invoices::can_view` (int vs. String). Schema 1.4.0 über eigene Migrations-Markierung.
- **Teil B:** Varianten = Preisoptionen mit Attributwerten (IDs aus Attributwerten, Standard = `_wopcart_default_price`); „Physisch“ als Flag; gemeinsamer Zähler `inventory` (stock/sold/reserved) für Lager + Gesamtlimit, Holds 60 min, lazy Sweep; MwSt. auf Versand = Satz der wertvollsten physischen Position; Stripe: Versand als Line Item + `payment_intent_data.shipping`, Fee auf Gesamtsumme inkl. Versand; Widerrufsverzicht-Checkbox nur bei digitalen Inhalten. Neu: `Shipping/*`, `Inventory/*`, `Catalog/*`, `Permalinks/*` (Bestandsshops behalten `/products/…`, neue Shops `/shop/`), Tabellen `inventory`, `stock_holds`, `shipments`, `redirects`; DB 1.5.0.
- **Code-Review 2026-09-14 – Ergebnis „bedingtes GO“ für wopcart.com im Testmodus** (Shop verkauft nur Digitales):
  - Kritisch: 2Checkout (und generell Gateways ohne Versand) kann physische Bestellungen ohne Versandkosten abschließen; keine Gateway-Einschränkung bei `needs_shipping()`.
  - Hoch: Rechnungen/Gutschriften/PDF ohne Versandposition; Auto-Genehmigung übergeht Teil-Erstattung/Ablehnung des Händlers.
  - Mittel: MwSt.-Report (Netto ohne Versand, Steuer mit Versand); PayPal `NO_SHIPPING` bei physischen Bestellungen; Refund-Anfrage kann in „granting“ hängen bleiben.
  - Niedrig: Mollie ohne `shipping_fee`-Zeile; Apple-Pay-Betrag kann vom Bestellbetrag abweichen; `/shop/`-Catch-all-Regeln im Legacy-Modus.
  - Geprüft und in Ordnung: keine Doppel-/unbefugte Erstattung (außer Punkt 3), kein IDOR bei Dokumenten/Angeboten, Fee inkl. Versand nicht umgehbar, keine Preismanipulation, Merges sauber, Upgrade von DB 1.3.0 legt alle Tabellen an, bestehende URLs (`/products/wopcart/`, `/pricing/`, `/checkout/`, `/my-account/`) bleiben.
  - Fix-Agent arbeitet alle 9 Punkte ab (+ DejaVu-Credit in readme.txt, doppelter Menüeintrag an der Quelle in `PostTypes/Product.php`). Snapshot `digital-cart.bak-20260914-before-reviewfix`.
  - Bedingungen fürs Deploy: Upgrade-Test von DB 1.3.0 (Staging) + Smoke-Test der Kernseiten + eine Refund-Anfrage Ende-zu-Ende; Auto-Genehmigung bis Fix aus; keine physischen Produkte vor Fix 1+2.

### Review-Fixes abgeschlossen (2026-09-14)
- 963 Tests grün, `php -l` sauber (60 Dateien), phpcs 0 Befunde auf geänderten Zeilen. Nicht deployt.
- Alle 9 Befunde behoben; Gateways mit Versand-Freigabe: **nur Stripe + Apple Pay** (PayPal/Mollie-Versandcode vorhanden und getestet, aber nicht freigeschaltet; 2Checkout verweigert Versand-Bestellungen und Unterzahlung).
- Nutzerentscheidungen umgesetzt: Rechnungsnummer bei Zahlung (Default, Proforma bei Annahme), Lager-Reservierung 60 min (5–1440), Versandklassen (Aufpreis oder klassenspezifische Kosten), Größenlimits L/B/H/Gurtmaß, Volumengewicht mit Divisor.
- Stripe-Payload-Kompatibilität: neue Klasse `StripePayload` (alte + basil/dahlia-Form), Invoice-Refetch mit gepinnter Version, Proxy-Route `GET invoices/in_*`, Warnung im Integrations-Dashboard bei abweichender Event-API-Version.
- Restrisiken: nichts live getestet; Abo-Verlängerungen mit Versand berechnen nur Planpreis; Proforma ohne Retry, wenn Nummernvergabe bei Zahlung fehlschlägt; Menü/Permalinks im echten WP prüfen.

### Deploy Welle 3 auf wopcart.com (2026-09-14 12:00 UTC, Testmodus)
- DB-Backup `backups/db-prewave3-20260914-115943.sql.gz`, Rollback `/opt/wopcart/rollback/wopcart-prev-20260914-115953`, 358 Dateien.
- Smoke-Test bestanden: DB 1.5.0, alle 6 neuen Tabellen vorhanden; Permalinks im Bestandsmodus (`/products/…`); `/pricing/`, `/cart/`, `/checkout/`, `/my-account/`, `/products/wopcart/` → 200, Warenkorb mit „10 sites, lifetime $150.00“ auf Cart und Checkout; Admin-Menü ohne Duplikat in neuer Reihenfolge inkl. Quotes und Integrations; 18 MCP-Abilities; Report korrekt (3 Bestellungen, brutto $200, erstattet $80, netto $120); keine neuen PHP-Fehler.
- **Neue Seite `/cart/`** (ID 79, `[wopcart_cart]`, noindex) angelegt. Plugin hat noch keine Cart-Page-Einstellung und leitet nach „In den Warenkorb“ auf die Startseite → Agent baut `page_cart`, Einstellung „Nach dem Hinzufügen: bleiben / Warenkorb / Checkout“, Shortcode-Attribut `redirect`, und fixt die Seitenauswahl (Entwürfe, int-IDs).
- Laufend: Sandbox-E2E (Abo-Wechsel mit Webhook, Refund-Anfrage → Grant, Dokumente, Reports, Integrations-Status).

### Sandbox-E2E nach Deploy (2026-09-14 12:07 UTC)
| Test | Ergebnis |
|---|---|
| Abo-Wechsel site1-yearly → site10-yearly | ❌ PHP-Fatal `name() on null` (Stripe.php, `$product` nur gesetzt wenn kein Betrag übergeben) → **lokal behoben**, zusätzlich `PlanChange::guarded()` fängt Gateway-Abstürze ab (kein HTTP 500 mehr); Nachtest nach nächstem Deploy |
| Refund-Anfrage Kunde → Admin-Grant | ✅ genau eine Stripe-Erstattung (`re_3UFWVNLTW7dodt6I1YwTpLPx`, $70), Status granted, 3 Mails, Upgrade zurückgesetzt, zweiter Grant/zweite Anfrage abgelehnt |
| `charge.refunded`-Webhook | ✅ HTTP 200, keine Doppel-Erstattung |
| Gutschrift | ❌ Bestellungen 000002/000003 hatten nie eine Rechnung (vor dem Nummern-Fix) → keine Gutschrift. An Rechnungs-Agent übergeben (fehlende Rechnung nachträglich ausstellen, dann Gutschrift) |
| Dokumente + Zugriffsschutz | ✅ |
| Report | ✅ erstattet/netto ändern sich konsistent (brutto $200, erstattet $150, netto $50) |
| Integrations-Status | ✅ Stripe verbunden, Webhook zuletzt 12:07, API 2024-06-20, keine Versionswarnung |
| PHP-Fehler im Container | ✅ keine |
- Kleiner Fix: Admin sieht bei bereits entschiedener Anfrage „already decided“ statt „nothing left to refund“.
- **Sicherheitshinweis:** Der Test-Agent hat versehentlich das Sandbox-Connect-Webhook-Secret im Klartext in seine Sitzungsausgabe geschrieben (nirgendwo sonst). Empfehlung: in Stripe „Roll secret“ und neuen Wert in `/opt/wopcart/.env` eintragen (Schreiben in .env ist für Claude blockiert).

### Warenkorb-Seite + Weiterleitung (fertig, nicht deployt, 2026-09-14)
- Ursache Startseiten-Redirect: Buy-Button postet auf dieselbe Seite, `wp_get_referer()` liefert dann false → Fallback Startseite. Fix: roher Referer (same-site) bzw. aktuelle URL, Status 303.
- Neu: Option `page_cart` (0 = automatisch erkennen), `cart_after_add` (bleiben / Warenkorb / Checkout; Standard Warenkorb), Shortcode-/Block-Attribut `redirect="cart|checkout|none"`, AJAX liefert `redirect`, Hinweise neben dem Button, „← Back to cart“ im Checkout, „Continue shopping“ bei leerem Warenkorb.
- Settings-Bug behoben: Seitenauswahl listet Entwürfe/privat/geplant, speichert int; fehlende Datenschutz-Seitenauswahl ergänzt.
- 982 Tests grün. Nach Deploy auf wopcart.com: Cart-Seite in Settings wählen, „After adding to cart“ speichern, Terms-/Seitenauswahl prüfen, Cache leeren.

### Entscheidungen des Nutzers (2026-09-14)
- Rechnungsnummer bei Angeboten: **einstellbar, Default bei Zahlung** (vorher Proforma ohne Rechnungsnummer).
- Lager-Reservierung: **einstellbar, Default 60 Minuten**.
- Physische Warenkörbe **vorerst nur über Stripe**.
- Versand braucht **Versandgruppen** und **Versandarten nach Gewicht & Größe** (inkl. Volumengewicht) → an Fix-Agent übergeben.
- **Versanddienstleister (UPS/DHL/FedEx/Post) → Backlog.**
- Nicht beantwortet, Empfehlung als Default übernommen: Gratisversand-Schwelle brutto; Erstattungen im Monat der Erstattung verbuchen; Varianten mit geerbtem Preis ohne eigenen Sale-Preis; Label „Widerruf“ bei Anfragen < 14 Tage. Deploy-Testweg (direkt mit Backup/Rollback vs. Staging-Kopie) noch offen.

### Offene Fragen an den Nutzer (Stand vor Entscheidungen)
1. Erstattungen im Zeitraum der Erstattung (Standard) oder im Zeitraum des Verkaufs verbuchen?
2. Label „Widerruf“ bei Anfragen < 14 Tage auch wenn Verzicht erklärt wurde?
3. Angebot angenommen → Rechnungsnummer sofort oder erst bei Zahlung (vorher Proforma)?
4. Varianten mit geerbtem Preis ohne eigenen Sale-Preis ok?
5. Gratisversand-Schwelle brutto oder netto?
6. Lager-Reservierung 60 min oder länger (Stripe-Session bis 24 h)?
7. Physische Warenkörbe vorerst nur über Stripe (PayPal/Mollie ohne Versand-Unterstützung)?

## Getroffene Standardannahmen (vom Nutzer bestätigen lassen)
- Versand v1: Zonen + Pauschal/kostenlos ab Betrag/nach Gewicht; keine Carrier-APIs; US-Sales-Tax für physische Ware später.
- Refund-Anfrage: jederzeit möglich; innerhalb 14 Tagen als Widerruf gekennzeichnet; Auto-Genehmigung standardmäßig aus.
- Angebote: vom Admin erstellt, Annahme durch Kunden erzeugt Bestellung mit Zahlungslink.
