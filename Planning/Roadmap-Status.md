# Roadmap-Status bis zum Launch

**Spiegel von Asana:** [WopCart — Feature-Roadmap bis zum Launch](https://app.asana.com/1/262428162084225/project/1218436856750320)
**Grundlage:** [[Feature-Liste zur Freigabe]] · [[Wettbewerb WPSmartPay – Funktionsplan]]
**Regel (Nutzer, 2026-09-14):** WordPress.org und AppSumo erst, wenn alles fertig ist. wopcart.com bleibt online.
**Arbeitsweise:** Parallele Agents mit fester Datei-Zuständigkeit. Danach Zusammenführung, Sicherheits-Review, gemeinsamer Test, Deploy auf wopcart.com. Snapshots vor großen Umbauten: `digital-cart.bak-pre-connect-*`.

Legende: ✅ fertig (lokal) · 🚀 live · 🔨 in Arbeit · ⏳ wartet · 💤 später · ❌ abgelehnt

## Stand 2026-09-14 06:50 UTC (Welle 2 live auf wopcart.com)

| ID | Aufgabe | Status | Hinweis |
|---|---|---|---|
| A1 | Stripe-Connect-Onboarding (Gratis-Plan) | 🚀 | Plattform-Routen, Proxy mit Gebühren-Durchsetzung, Webhook-Weiterleitung, Händler-UI, DB 1.3.0. Wartet auf Stripe-Dashboard-Schritte + Webhook-Secret |
| A2 | WordPress.org-Veröffentlichung | ⏳ Launch | erst wenn alles fertig |
| A3 | Preismodell (Domains pro Paket) | ⏳ Entscheidung Nutzer | WPSmartPay: $99/1 · $149/5 · $279/50 |
| B1 | AppSumo-Codes, stapelbar | ⏳ Launch | |
| B2 | Lifetime-Pakete | ⏳ Launch | |
| B3 | Money-back-Garantie | ⏳ | nach A1 (Erstattung über Gateway); 2 % werden bei normaler Erstattung nicht zurückgegeben |
| B4 | Partnerprogramm 2 Stufen | ⏳ | nach A1 |
| B5 | Affiliate-System für Händler | ⏳ | nach B4 |
| C1 | Mollie | 🚀 | Hosted Checkout, Webhook mit Re-Fetch, Abos über Subscriptions API, Erstattungen; nur Bezahlplan; Upgrades bei Mollie-Abos abgelehnt |
| C2 | Paddle (MoR) | ⏳ | nach A1 |
| C3 | Weitere Stripe-Zahlarten | 🚀 | Dashboard-Zahlungsarten, SEPA-Async-Flow, Allowlist mit Fee-Tests |
| C4 | Zahlungsformulare (Blöcke) + Vorlagen-Galerie + einbindbare Formulare (Block/Shortcode) | ✅ gebaut, nicht deployt (2026-09-14) | CPT `wopcart_form`, 19 Feldtypen, 17 Vorlagen, Tabellen `form_entries`/`form_counters` (Migration 1.6.0-forms), Backing-Produkt je Formular, Betrag serverseitig, 2 %-Gebühr unverändert; Lückenschluss läuft (Webhook-Events, MCP-Schalter, order.created, Captcha, Deinstallation, Ziele mit Verlängerungen) |
| H10 | Integrations-Hub (Karten, Schalter, Einstellungen, Kategorien) – ersetzt H1, H2, H4, H5, H6, H8, H9 (Nutzer 2026-09-14: „integration should be available for these“) – ✅ gebaut, nicht deployt: 32 Kacheln, Schalter, Einstellungsdialog, Event-Zuordnung, Test, Retry-Queue, Consent, SSRF-Schutz, MCP `list-integrations`; 1119 Tests grün; Live-Prüfung je Dienst offen; MemberPress fehlt; Lettermark-Icons statt Markenlogos + 25+ Integrationen (Mailchimp, MailerLite, ActiveCampaign, FluentCRM, Brevo, Zapier, Pabbly, Integrately, Make, n8n, Uncanny Automator, WPFunnels, Slack, Telegram, Twilio, Discord, Google Sheets, Fluent Support, FluentCommunity, LearnDash, Tutor, LifterLMS, Wishlist Member, RCP, AffiliateWP, SliceWP, GA4, Meta CAPI) | 🔨 in Arbeit (2026-09-14) | Referenz WPSmartPay; Asana H8 |
| E4 | Rechnungen rechtskonform (EU Art. 226), Zahlungslink, erneut senden, stornieren (Storno-Gutschrift), Aktivitätsverlauf, Zahlungsseite mit optional angehängtem Formular | ✅ gebaut, nicht deployt (2026-09-14) | 1054 Tests grün. Details unten „E4 – Rechnungen“ |
| C5 | Freie Beträge / Spenden | 🔨 mit C4 | Staffeln, min/max, Häufigkeit, anonym, Gebühren übernehmen |
| C6 | Ziele / Fortschrittsbalken | 🔨 mit C4 | Betrag / Verkäufe / Einsendungen, Deadline |
| C7 | KI-Formular-Builder | ⏳ | nach C4 + G1 |
| C8 | Zahlungslinks / QR | ⏳ nächste Welle | |
| D1 | Order Bumps + 1-Klick-Upsell | ⏳ | nach A1 |
| D2 | Sale-Preis mit Zeitraum + Omnibus | 🚀 | Nacharbeit erledigt: Upgrade::targets() nutzt den gültigen Preis, PlanChange den Verlängerungspreis |
| D3 | Gutscheine massenhaft + CSV | 🚀 | Chargen bis 5000, wiederholungssicher, Filter/Massenaktionen, CSV; Scope-Bug im Editor behoben |
| D4 | Umsatzrettung | 🚀 | Mahn-Mails 0/3/7, Zahlungsmethode per Setup-Checkout, Kartenablauf-Hinweis, revenue_recovery-Meta |
| D5 | Kündigungsdialog / Pausieren | 🚀 | Gründe, Pause 1–3 Perioden, günstigeres Paket, Halte-Rabatt, Fortsetzen |
| D6 | Preisanzeige netto/brutto (Option) + Grundpreis | 🚀 | Modi auto/net/gross_store, CF-IPCountry, Rundung = Calculator, Grundpreis mit Schema |
| E1 | Manuelle Rechnungen + Zahlungslink | 🚀 | Nummer erst beim Senden, Token-Zahlungslink, Gutschrift statt Löschen, Erinnerungen, Aktivitätslog |
| E2 | Echtes PDF | 🚀 | eigener PDF-Writer mit eingebetteter DejaVu (UTF-8 inkl. Maltesisch), alle Rechnungen und Gutschriften |
| E3 | E-Rechnung XRechnung/ZUGFeRD | ⏳ | nach E1/E2 |
| F1 | Kundenportal erweitern | ⏳ | nach A1 |
| F2 | Login-Pflicht, Checkout-Layout | ⏳ nächste Welle | nach I1 (checkout.php) |
| F3 | Abo-Analyse | 🚀 | MRR je Währung + Verlauf, Churn, gefährdete Abos, Erstattungs- und Recovery-Tab, SVG-Diagramme |
| G1 | MCP / Abilities API | 🚀 | 18 Abilities, Admin-Seite „AI / MCP"; Registrierung in Plugin.php beim Zusammenführen |
| G2 | KI-Analyse im Admin | 💤 | |
| H1 | Integrationsseite | ⏳ nächste Welle | |
| H2 | E-Mail/CRM (Brevo, Mailchimp, MailerLite, ActiveCampaign, FluentCRM) | ⏳ nächste Welle | Opt-in am Checkout nach I1 |
| H3 | LMS (LearnDash, Tutor, LifterLMS) | 🚀 | Abgleich aus allen gültigen Käufen, entzieht nur selbst vergebenen Zugang, Shortcode [wopcart_courses] |
| H4 | Membership-Plugins | 💤 | |
| H5 | Slack, Telegram, Google Sheets | ⏳ | nach H7 |
| H6 | FluentSupport, FluentCommunity | 💤 | |
| H7 | Webhook-Events + Automator/Make/n8n/Pabbly | 🚀 | 21 Events, Presets, Secret-Rotation, Zustellprotokoll, Auto-Deaktivierung, 13 Automator-Trigger; Suite 530 grün |
| H8 | AffiliateWP | 💤 | |
| H9 | Twilio SMS | 🔨 in H10 | früher abgelehnt, 2026-09-14 vom Nutzer mit der WPSmartPay-Integrationsliste angefordert |
| I1 | Anti-Spam | 🚀 | Honeypot, Turnstile/hCaptcha/reCAPTCHA, Rate-Limits, Consent-Filter |
| I2 | Dateischutz (Wasserzeichen, S3/R2) | 💤 | |
| I3 | Lizenz-SDKs + GitHub-Releases + Beta-Kanäle | 🚀 | Releases stable/beta, Instanz-Aktivierung, Ed25519-signierte Antworten, GitHub-Deploy, SDKs JS/Python/PHP (je 8/8) |
| J1–J3 | Marktplatz, Admin-UI, Event-Tickets | 💤 | |
| J4, J5 | Buchungen, Umfragen | ❌ | |
| K1 | Demo, Changelog, Roadmap, Wissensdatenbank | ⏳ Launch | |
| K2 | Vergleichsseite WopCart vs. WPSmartPay | ⏳ Launch | |
| K3 | Neue Homepage nach Nutzer-Mockup + Header/Footer im Markendesign | 🚀 live (2026-09-14) – Seite 15, Header-Part 85, Footer-Part 30, mu-plugin `04-site-design.php` (einzeln gemountet → Mount-Zeile beim nächsten gewollten Recreate ergänzen; `import.php` nicht mehr ausführen), Site-Icon, Titel „WopCart“; K4-Seiten About/Roadmap/Changelog/Affiliates live; Doppel-H1 Imprint/Privacy/Terms behoben | Mockup `Website/mockups/home-mockup.html`; Korrekturen: kein erfundenes Testimonial, „0 % fee on paid plans“, Illustrationen gekennzeichnet |
| K4 | Footer-Seiten Roadmap, Changelog, Affiliates, About | 🔨 mit K3 | wahrheitsgemäß, Partnerprogramm „coming soon“ |
| UI1 | Admin-Dashboard + Checkout im Mockup-Design | ✅ gebaut, nicht deployt (1165 Tests) – Button-Text „Buy now — pay $X“ (Button-Lösung), Layout-/Akzent-Einstellungen unter Settings → Appearance | Kennzahlen mit Vorperiode, Flächendiagramm, Checkout-Karte, Zahlungsart-Kacheln, Split-Layout, Akzentfarbe einstellbar |
| I18N | WPML + Polylang | ✅ gebaut, nicht deployt (1178 Tests) | wpml-config.xml, Compat\Wpml/Polylang, gemeinsame Zähler, Systemseiten je Sprache, Mails in Bestellsprache, RTL; Live-Test mit echten Plugins offen |
| BLD | Divi-Module, Bricks, Elementor-Lücken | ✅ gebaut, nicht deployt | Divi 7 Module, Bricks 7 Elemente, Elementor 11 Widgets, Beaver/Oxygen/Breakdance via Shortcodes; Live-Test offen |
| M1 | Mitgliedschaftsstufen (Kunde/Premium/Exklusiv) mit Rollen & Rechten, Sichtbarkeit pro Seite/Block/Menü, eigene Inhalte (Directory-Einträge), MemberPress-Kompatibilität | ✅ gebaut, nicht deployt (1257 Tests) | Migration 1.7.0-memberships; Vorlage Customer/Premium/Exclusive; Live-Test MemberPress + Directory-Plugins offen; Fragen: Pause = Kündigung?, Review-Modus offline?, native Builder-Elemente?, Automator-Trigger? |
| FIX4 | Review-Fixes Memberships (C1, C2, H1, H2, M1–M6, Gast-Verknüpfung, Teaser), Integrations-Hub (doppelte/verlorene Zustellung → Tabelle `wopcart_integration_jobs` + Migration 1.8.0-integrations, Analytics-Einwilligung nur explizit/WP Consent API, SSRF mit DNS-Prüfung + IP-Pinning, keine PII in Queue, Secrets nicht autoload), Warenkorb (Einstellungs-Default, Hinweis-Codes, Pay-Label, doppeltes Inline-CSS) | ✅ lokal (2026-09-14), 1333 Tests grün | Default nach „Buy“ = Warenkorb bis Nutzerentscheidung (`CartRedirect::DEFAULT_MODE`); bereits gespeicherte Rechte-Bestätigungen neu bestätigen |
| FIX5 | Review Formulare + Rechnungen: GO nach 3 Must-Fixes (alte Proformas würden beim ersten Cron Mahnungen bekommen; versteckter Betragsblock wird trotzdem berechnet; Migration als erledigt markiert obwohl Tabellen fehlen) + vor Live (einmaliger Gutschein bei Abo-Formular überberechnet, Reservierungs-Missbrauch, Plan-Rücksetzung ohne Produkt, Requires PHP 8.2) + Low | 🔨 Fix-Agent läuft (2026-09-14) | |
| DEC6 | Nutzer-Entscheidungen 2026-09-14: „Buy“-Ziel in Settings (Default Checkout); Pause → Settings (Default kein Zugang, optional Free-Stufe als Rückfall, pro Stufe überschreibbar); Directory/eigene Inhalte nur vordenken → UI raus, Code hinter Filter aus; keine eigenen Member-Elemente für Builder (Shortcode/Block-Sichtbarkeit reicht); 3 Automator-Auslöser für Mitgliedschaften | ✅ lokal (1366 Tests grün) | Checkout-Default; Status `paused` + PausePolicy; Own-Content hinter Filter aus; Automator-Trigger |
| REL110 | Release 1.1.0 bereit (2026-09-14): 1398 Tests grün; enthält Formulare, Integrations-Hub (neu: geführte Einrichtung, Bereiche, Beta-Label), Memberships + MemberPress, Rechnungen, Warenkorb-Seite, Redesign, WPML/Polylang, Divi/Bricks, VIES-Fix (Connection: keep-alive), Abo-Gutschein-Fix, Einrichtungsgebühr Stripe/PayPal, alle Review-Fixes | 🚀 live 2026-09-14 17:59 UTC (Backup db-pre110-20260914-175901, Rollback wopcart-prev-20260914-175902, alle 6 Migrationen gelaufen, Changelog #83 + Roadmap #82 veröffentlicht, Produkt-Download wopcart-1.1.0.zip) | Offen (nicht in 1.1.0): Authorize.net Einrichtungsgebühr, gemischte Testphasen |
| REV3 | Gesamt-Review aller nicht deployten Plugin-Änderungen | 🔨 läuft (2026-09-14) | danach Deploy nach Freigabe + Live-Tests |

## Betrieb wopcart.com (parallel)

| Punkt | Stand |
|---|---|
| Stripe-Plattform-Schlüssel (.env) | 🚀 aktiv, Test-Modus, Konto MT, Connect-API nutzbar |
| Store-Daten (C. Badde, Einzelunternehmer, Mellieha, MT24104415, info@wopcart.com) | 🚀 gesetzt, VIES gültig |
| EU-VAT | 🚀 eingeschaltet (MT 18 %), Preise netto – **Brutto/Netto-Anzeige: Entscheidung Nutzer offen** |
| Rechtstexte | Entwürfe mit Betreiberdaten; Anwaltsprüfung offen |
| Shop-Stripe-Schlüssel in WopCart-Einstellungen | ⏳ Nutzer |
| Stripe Connect im Dashboard aktivieren, Kontodaten vervollständigen | ⏳ Nutzer |
| Testmail an info@wopcart.com (Postfach vorhanden?) | ⏳ Nutzer |
| Restore-Test Backup | ⏳ |

Details zu Server und Deployment: [[wopcart.com]] (Deployment-Protokoll).

## Zusammenführung – offene Punkte (vor dem nächsten Deploy)

- [x] Module in `src/Plugin.php` registrieren: `Mcp\Abilities` (immer), `Mcp\AdminPage` (Admin), `Security\AntiSpam`, dazu die Klassen der noch laufenden Agents – 12 Module registriert (AntiSpam, Mcp, Releases, GithubDeploy, StripeMethods, Recovery, CancelFlow, ManualInvoices, Admin-Seiten, Lms bedingt) 2026-09-14
- [x] Hook `wopcart_form_protection('review')` in `templates/reviews/form.php` (2026-09-14)
- [x] Datenschutztext „Spam protection" in `src/Privacy/Privacy.php` + Mollie-Text (2026-09-14)
- [x] **Bug `Settings::save()`:** Beim Speichern eines Tabs werden die Checkboxen anderer Tabs auf false gesetzt (gemeldet vom Anti-Spam-Agent). Beheben und testen. – behoben 2026-09-14: abwesende Checkboxen werden nur noch auf dem gesendeten Tab als „aus" gespeichert
- [ ] Secret-Felder einheitlich als nur schreibbar anzeigen (Anti-Spam macht es schon, Stripe und PayPal zeigen gespeicherte Werte noch an)
- [x] `.pot` neu erzeugen (2026-09-14)
- [x] Schema: Spalten `batch`, `batch_run` + Keys in Discounts-Tabelle (D3) (2026-09-14)
- [x] CSV-Import von Rabatten: `products` → `product` (gleicher Scope-Bug wie im Editor) (2026-09-14)
- [ ] A1: im Testmodus prüfen, ob die Proration-Rechnung eines Upgrades die 2 % Application Fee trägt (Stripe sagt ja)
- [x] Registrieren: `Integrations\Lms\Lms` nur wenn `Lms::any_available()` (2026-09-14)
- [ ] Hooks für Kurse in `templates/account.php` und in der Bestelldetail-Ansicht (statt admin_notices)
- [x] F3: Indizes `date_created`, `date_cancelled` auf Abo-Tabelle (2026-09-14)
- [ ] F3: `SubscriptionRepository::update()` soll `Reports::flush_cache` auslösen
- [ ] F3: alte `stats()['mrr']` (addiert Währungen) durch neue MRR-Berechnung ersetzen
- [ ] F3: `Admin::render_reports()` übergibt benutzerdefinierte Zeiträume
- [x] H7: Hook `wopcart_download_completed` in `DownloadHandler::deliver()` ergänzen (2026-09-14)
- [ ] H7: `view_url` (enthält Order-Key) in `invoice.*`-Payloads prüfen
- [x] H7: `assets/js/admin-webhooks.js` syntaktisch prüfen (lokales Node defekt) – ok mit /usr/local/bin/node (2026-09-14)
- [x] I3: registrieren `Licensing\Releases`, `Licensing\GithubDeploy` (Liste), `Licensing\ReleasesAdmin` (Admin) (2026-09-14)
- [ ] I3: Beta-Flag pro Lizenz als Spalte statt Option; Admin-Hinweis bei fehlgeschlagenem GitHub-Import; GitHub-Token/Secrets nicht im Klartext
- [ ] C1: Privacy-Text Mollie; Mollie im Bezahlplan-Hinweis (Settings)
- [x] C3/D4/D5: registrieren `Gateways\StripeMethods`, `Subscriptions\Recovery`, `Subscriptions\CancelFlow` (2026-09-14)
- [ ] D4: Altverhalten `record_failure()` setzt Abo nach 3 Fehlversuchen lokal auf EXPIRED, obwohl Stripe Smart Retries weiterlaufen – angleichen
- [x] **Sicherheit:** `Checkout::maybe_process()` nutzt `get()` statt `available()` → Gateway außerhalb des Plans per POST wählbar – behoben 2026-09-14
- [x] E1/E2: registrieren `Invoices\ManualInvoices` (Liste), `Invoices\InvoicesAdmin` (Admin) (2026-09-14)
- [ ] E1/E2: Privacy-Export/-Löschung für manuelle Rechnungen; Einstellung „PDF an E-Mails anhängen"; DejaVu-Lizenz (GPL-Kompatibilität) prüfen + Credit in readme.txt
- [ ] D6: Empfehlung für wopcart.com: Modus `auto`, Nettopreise eingeben; Full-Page-Cache nur mit Länder-Variante
- [x] Tests: Suite wieder grün (634 Tests), 2026-09-14
- [x] Gesamt-Review (Sicherheit) über alle neuen Module, dann Deploy auf wopcart.com mit Rauchtest – Review, 4 Fix-Agents, Deploy 06:44 UTC, Rauchtest bestanden
  - Erste bestätigte Befunde: Privacy-Exporter/-Eraser fehlt für Käuferdaten in manuellen Rechnungen (`_wopcart_data`, ManualInvoices.php:208); Kündigungsgründe/-kommentare fehlen im Abo-Export. Weitere Befunde folgen.
  - Teil-Review MCP/LMS: **H1** `extend-license` (auch Admin-Extend) reaktiviert erstattete/deaktivierte Lizenzen (`License::extend` überschreibt DISABLED) · **M1** kein Schalter pro MCP-Ability, Schreib-Abilities per Default öffentlich · **M2** zweite gleich hohe Teilerstattung bei Stripe wird ohne Geldfluss verbucht (Idempotency-Key order+amount) + Race auf `refunded` · **M3** LMS-Zugang wird nach Rücksetzen einer Bestellung auf „complete" nicht wiederhergestellt · Low: Kurs-Refs ungeprüft, 500-Order-Limit, Rate-Limit resend/extend, Produkt-IDs bei Rabatten ungeprüft
    - Behoben 2026-09-14: H1 (`License::extend` behält DISABLED), M2 (Refund-Idempotency-Key enthält bereits erstatteten Betrag), M3 (LMS-Sync auch beim Wechsel zurück in einen gewährenden Status). Offen: M1 MCP-Schalter pro Ability, atomares `refunded`-Update, Lows.
  - Teil-Review Mollie/Preise/Rabatte: **M1** Mollie 401/403 wird wie 404 behandelt → Webhook antwortet 200, Retries enden, Bestellungen bleiben offen · **M2** Einweg-Gutschein gleichzeitig mehrfach einlösbar (`record_use` ohne Bedingung) · Low: Marker-Optionen fehlgeschlagener Mollie-Renewals bleiben ewig, Mollie-Abo auch nach Erstattung anlegbar, Kundendaten im Debug-Log, `wopcart-cancel`-Route ohne Order-Key (Altbestand)
  - Teil-Review Rechnungen/Berichte: **H** erstattete manuelle Rechnung lässt sich ein zweites Mal per Gutschrift stornieren (zwei Gutschriften für eine Rechnung) · **M** Erinnerungen erreichen bei &gt;200 offenen Rechnungen die ältesten nicht · **M** Privacy-Export/-Löschung für manuelle Rechnungen fehlt · Low: mark_paid/void ohne gemeinsamen Lock, Draft nach Versand editierbar, Zahlung bei „processing" neu startbar, Delete-Draft-Button ohne Refund-Recht, Zahlungs-Token rotiert nie
  - Teil-Review Webhooks/Anti-Spam/Releases: **M** SSRF über „Send test" (Antwort sichtbar) und Zapier-Subscribe → `wp_safe_remote_post`, keine Redirects · **M** Rate-Limiter nicht atomar (parallele Requests) · **M** `wopcart_check_discount` ohne Rate-Limit (Code-Enumeration) + Lockout hinter Proxy ohne REMOTE_ADDR-Umschreibung · Low: X-Forwarded-For links statt rechts, Honeypot durch Weglassen umgehbar (Review/Login), Refund-Upgrade ohne Seat-Lock, GitHub-Redelivery nach Fehlschlag blockiert, Webhook-Handle bricht bei Payload-Fehler ab, Captcha-hostname ungeprüft
  - Teil-Review Connect/Stripe: **H** Übernahme einer anderen Seite auf demselben Host (Pfad-Prüfung fehlt in connect/start) · **H** Gratis-Plan mit noch gespeicherten eigenen Stripe-Keys umgeht die 2 % komplett · **M** Stripe-Webhook wartet auf jede Händlerseite (Weiterleitung im selben Request) · **M** Proxy prüft nicht, dass ein Connect-Konto existiert · Low: doppelte Renewal-Orders bei parallelen Events
  - **Fix-Runde gestartet 2026-09-14:** 4 Agents (Rechnungen+Datenschutz · Webhooks/Anti-Spam/Releases · Mollie/Rabatte/MCP/LMS/Erstattung · Connect/Stripe)
    - ✅ Webhooks/Anti-Spam/Releases behoben: SSRF (wp_safe_remote_*, keine Redirects, private Hosts abgelehnt), atomarer Rate-Limiter (Object-Cache incr oder GET_LOCK), check_discount limitiert, Proxy-Hinweis, XFF rechts, Honeypot strikt für Review/Login, Seat-Lock bei Upgrade/Refund, GitHub-Redelivery, Webhook-Payload-Fehler, Captcha-Hostname. Eigene Tests 213 OK; Suite zeigt 4 Fehler in Invoice-/MCP-Tests (Agents laufen noch)
    - ✅ Mollie/Rabatte/MCP/LMS/Erstattung behoben: Mollie 401/403 → 503 + Admin-Hinweis, fehlgeschlagene Renewals als Order-Meta, Abo nur bei abgeschlossener Order, Abbruch-Route prüft Order-Key; Einweg-Gutscheine atomar gezählt (Überschreitung wird markiert); MCP-Schalter pro Ability (Schreiben standardmäßig aus), 409 bei deaktivierter Lizenz, Audit-Log + Rate-Limits, Produkt-IDs validiert; Stripe-Erstattung atomar (`increment_refunded`); LMS-Kurs-Refs validiert, Orders ohne 500er-Limit. Http-Option `log_body` ergänzt (2026-09-14), Mollie-PII nicht mehr im Debug-Log.
    - ✅ Connect/Stripe behoben: Pfad-Prüfung + feste Challenge-URL in connect/start, Warnmail bei Token-Neuausgabe; Gratis-Plan nutzt gespeicherte eigene Stripe-Keys nie (Stripe + Apple Pay); Webhook-Weiterleitung nach fastcgi_finish_request bzw. per Cron; Proxy 409 ohne gültiges acct_; Renewal-Claim gegen Doppel-Orders; Event-ID-Dedupe im Client. Offen: Spalte notify_email, Stripe-Keys im Free-Plan beim Speichern verwerfen, Event-Dedupe nicht atomar
    - ✅ Rechnungen/Datenschutz behoben: idempotente Gutschrift, Status „refunded" nach Erstattung, Reminder paginiert, Privacy-Exporter/-Eraser manuelle Rechnungen + Kündigungsfeedback, gemeinsamer Lock, keine Doppelzahlung bei „processing", Delete-Draft ohne Refund-Recht, Zahlungslinks verfallen 90 Tage nach Begleichung
    - Suite nach allen Fixes: 753 Tests grün (2026-09-14)
- [ ] Nach dem Deploy: je eine Lese- und eine Schreib-Ability per MCP gegen WordPress 7.1 testen; Editor und Storefront der Sale-Preise prüfen

## A1 – Stripe-Dashboard-Schritte (Nutzer)

1. Connect aktivieren und Plattformprofil ausfüllen: https://dashboard.stripe.com/connect/registration
2. Connect-Einstellungen: Branding (Name, Farbe, Icon), Länder fürs Onboarding, Express-Konfiguration prüfen
3. Workbench → Webhooks → Event-Ziel, **Events from: Connected accounts**
   - URL `https://wopcart.com/wp-json/wopcart/v1/platform/connect/webhook`
   - Events: `account.updated`, `checkout.session.completed`, `checkout.session.async_payment_succeeded`, `invoice.paid`, `invoice.payment_failed`, `customer.subscription.deleted`, `charge.refunded`
4. `whsec_…` als `STRIPE_CONNECT_WEBHOOK_SECRET` in `/opt/wopcart/.env`, dann Container neu erstellen
   - Hinweis: `account.application.deauthorized` gibt es in der API („Sent to the related application only"), taucht aber bei „Connected accounts" ggf. nicht auf. Bei Express-Konten unter Plattform-Kontrolle ist es praktisch irrelevant, darf also fehlen.
5. ~~Bestätigen, dass `fees.payer=account` + Express-Dashboard erlaubt ist~~ ✅ Stripe-Antwort 2026-09-14 (siehe unten)

**A1-Restrisiken / Folgeaufgaben:**
- Upgrade-Prorations: laut Stripe-Antwort gilt `application_fee_percent` auch für sofortige Proration-Rechnungen → im Testmodus Ende-zu-Ende nachprüfen (widerspricht der Doku-Lesart des A1-Agents)
- Nach Disconnect behalten bestehende Abos die Gebühr; der Händler kann sie entfernen
- `forward_key` liegt im Klartext in der Plattform-DB
- Im Free Plan entscheidet der Plattform-Key über Test oder Live; die Händler-Einstellung `test_mode` wirkt dort nicht

## Unterbrechung 2026-09-14 (~05:00 UTC)

Die Agents für E1/E2, C3/D4/D5, D6, I3, H7 und C1 wurden durch das API-Sitzungslimit abgebrochen. Ihre Teilarbeit liegt im Dateibaum: `php -l` meldet für 305 Dateien keine Fehler, PHPUnit zeigt 523 Tests mit 6 Errors, u. a. `WebhookSignatureTest`.
Um 06:00 UTC wurden alle sechs mit ihrem bisherigen Kontext fortgesetzt. Vor dem nächsten Deploy muss die Test-Suite wieder komplett grün sein.

## Stripe-Bestätigung zur Connect-Konfiguration (2026-09-14)

Antwort von Stripe auf unsere Architektur-Anfrage (Direct Charges, Händler bleibt Merchant of Record):
1. **Controller-Properties** `fees.payer=account`, `losses.payments=stripe`, `requirement_collection=stripe`, `stripe_dashboard.type=express` sind erlaubt und brauchen keine Freischaltung.
2. **Gebühren:** Das verbundene Konto zahlt Stripe-Gebühren und Dispute-Gebühren selbst. Die 2 % Application Fee kommen oben drauf und werden nicht gekürzt. Connect-Gebühren fallen weder für die Plattform noch für das Konto an.
3. **US-Händler** können sich bei der Malta-Plattform anmelden. Die Länder werden in den Connect-Einstellungen einzeln freigeschaltet. Steuerliche und bilanzielle Folgen trägt die Plattform selbst. Das „recipient service agreement" betrifft Transfers, bei Direct Charges nicht zwingend relevant.
4. **Erstattungen:** Die Application Fee bleibt standardmäßig bei der Plattform. `refund_application_fee=true` würde sie anteilig erstatten; der Proxy blockiert das.
5. **Prorations:** `application_fee_percent` gilt laut Stripe auch für sofortige Proration-Rechnungen. Wird im Testmodus nachgeprüft.

**Nächste Schritte (Nutzer):** Connect aktivieren, Länder freischalten (USA + EU), Webhook „Connected accounts" anlegen, `whsec_…` in `.env` eintragen.

## Stripe-Sandbox – Hinweise (2026-09-14)
- Geschäftsmodell im Setup-Guide: **„Your merchants collect payments directly"** (Platform, Direct Charges) gewählt.
- Stripe hat automatisch ein Test-Konto `testaccount@example.com` angelegt, Status „Provide a business website – Past due". Das Dummy-Konto des Setup-Guides ist für WopCart nicht relevant, weil unsere Händlerkonten per API vom Plugin angelegt werden. Keinen Remediation-Link verschicken.
- **„Platform pricing tool" NICHT aktivieren:** WopCart erhebt die 2 % per `application_fee`. Das Tool würde zusätzliche Plattformgebühren von den Händlern einziehen → Doppelbelastung.
- Relevante Connect-Einstellungen: Onboarding interface (Branding), Onboarding options (Länder: USA + EU), Payment methods, Express Dashboard. Webhook separat unter Developers → Webhooks (Connected accounts).

## Entscheidungen Rechtstexte & Stripe-Live (2026-09-14)
- **Rechtsseiten online** (ohne Anwaltsprüfung, Prüfung später): `/privacy` (vorher `/privacy-policy`, Seite 3), `/imprint` (26), `/terms` (28), `/support` (57, neu, Footer). Quellen im Vault `Website/pages/`, Backups `*.bak-20260914b`.
- **Widerruf:** 14 Tage für **alle** Käufer (Verbraucher und Unternehmen), auch nach Lieferung/Aktivierung. Bei Widerruf volle Erstattung, Lizenzschlüssel wird widerrufen → Seiten fallen auf den Free-Plan. Checkbox „Verzicht auf Widerrufsrecht“ auf wopcart.com deaktiviert (`require_withdrawal_waiver=false`). Refund-Seite, FAQ, Support angepasst. Offen: gilt der Widerruf auch nach automatischer Verlängerung? (derzeit: nein)
- **Recht:** maltesisches Recht für alle; zwingender Verbraucherschutz des Wohnsitzlandes bleibt, wo gesetzlich vorgeschrieben.
- **Haftung:** Ausschluss für Inkompatibilität mit Drittsoftware inkl. entgangener Käufe, soweit gesetzlich zulässig.
- **Lizenzen:** personengebunden, dürfen für Domains Dritter genutzt werden, nicht übertragbar.
- **Datenschutz:** Steuerberater als Empfänger entfernt. Offen: DPA mit Hostinger und Brevo im Kundenkonto annehmen.
- **Stripe Live-Konto:** Radar „Standard“ empfohlen (nur eigene Verkäufe). Support/Privacy/Terms-URLs: `/support`, `/privacy`, `/terms`.
- **Server:** Container `wopcart-web` (Service `wordpress`) neu erstellt, `WOPCART_CONNECT_WEBHOOK_SECRET` geladen; Webhook-Endpoint antwortet ohne Signatur mit 400 (korrekt).
- **Neue Asana-Aufgaben:** G1 Betrugsschutz Free-Plan, F5 Verlängerungs-Erinnerung (US Auto-Renewal Laws), F6 Abo → Lifetime-Lizenz umwandeln, Widerruf-Automatik (Lizenz sperren + Free-Plan).
- **E-Mails:** WopCart-Mails bleiben führend; Stripe „Successful payments“/„Refunds“ aus, Mandats-Mails an. Vorschlag F4 (Testmail-Button, Zustellcheck) noch nicht freigegeben.

## A3 – Neue Preise (Entscheidung 2026-09-14)
| Stufe | Jährlich | Lifetime (einmalig) |
|---|---|---|
| Free | $0 (2 % Plattformgebühr) | – |
| 1 Site | $50 | $80 |
| 10 Sites | $99 | $150 |
| 100 Sites | $200 | $280 |

- Ersetzt die EUR-Pakete Single/Studio/Agency/Pro/Enterprise. Währung USD, EU-Verbraucher zahlen MwSt. zusätzlich.
- Price-IDs: `site1-yearly`, `site1-lifetime`, `site10-yearly`, `site10-lifetime`, `site100-yearly`, `site100-lifetime`.
- Umsetzung: (1) Plugin – Lizenzlaufzeit pro Preisoption (Agent), (2) Website-Texte (Agent), (3) Deploy + Produkt #14 umstellen + Seiten veröffentlichen, (4) Stripe-E2E-Test.
- Umwandlung Jahr → Lifetime = F6 (später). Asana: A3-Aufgabe angelegt.
- **Live seit 2026-09-14 09:33 UTC:** Plugin mit Lizenzlaufzeit pro Preisoption deployt (771 Tests grün, Rollback `/opt/wopcart/rollback/wopcart-prev-20260914-093232`), DB-Backup `backups/db-preprices-20260914-093324.sql.gz`, Produkt #14 auf USD + 6 Preisoptionen umgestellt (Lifetime-Optionen mit `_wopcart_license_terms`), alle Seiten neu veröffentlicht (Preisseite mit 6 Kauf-Buttons).
- AGB-Ergänzungen: Preisänderungen gelten nicht für gekaufte Lifetime-Pläne; Einstellung von WopCart wird Lifetime-Kunden 12 Monate vorher mitgeteilt. Preisseite: „EU prices at checkout include VAT“. Keine Launch-Preis-Kennzeichnung.
- **Stripe-E2E-Test (Testmodus) 2026-09-14 – Ergebnisse:**

| Test | Ergebnis |
|---|---|
| Buy-Button /pricing/ | FAIL → **behoben** (CartController wurde wegen `use`-Alias nie geladen; Hotfix 09:54 UTC, live geprüft: Warenkorb $80 + 18 % = $94.40) |
| Jahreskauf site1-yearly (Abo, Lizenz 365 Tage, Mail, My Account) | PASS |
| Lifetime-Kauf site1-lifetime (einmalig, lifetime=1) | PASS |
| Upgrade Lifetime 1 → 10 Sites ($70, bleibt lifetime) | PASS |
| Rechnungsnummern | FAIL → **behoben** (`insert_id` nach UPDATE; jetzt `SELECT LAST_INSERT_ID()`), Zähler WP-2026 auf 2 zurückgesetzt |
| Abo-Wechsel yearly 1 → 10 (Proration) | FAIL → **behoben** (neuer Preis hing an inaktivem Inline-Produkt; jetzt aktives Produkt via `product_data`), Nachtest offen |
| Voll-Erstattung → Lizenz gesperrt | PASS (Gutschrift fehlte wegen Rechnungs-Bug) |
| Plan-Check aktiv/erstattet | PASS |
| EU-Verbraucher DE (19 %) | Steuer korrekt, Checkout blockiert durch fehlenden IP-Nachweis (erwartet) |
| Free-Plan via Connect | nicht durchführbar (braucht öffentliche Test-Händlerseite) |

- Neuer Regressionstest `PluginModulesTest` (alle Modulklassen existieren) + `_doing_it_wrong` statt stillem Überspringen; 772 Tests grün. Rollback `/opt/wopcart/rollback/wopcart-prev-20260914-095453`.
- **Fehlt:** Shop-Webhook `https://wopcart.com/?wopcart-webhook=stripe` (Nutzer), Webhook-Secret des Shops ist derzeit identisch mit dem Connect-Secret.
- Testdaten (nicht gelöscht): Bestellungen 000001–000003, Lizenzen 1–2, WP-User 2 „info“, Kunde 1.
- Asana-Folgeaufgaben: Shop-Webhook (Nutzer), Checkout-Zusammenfassung Länderwechsel, Erstattung inkl. Upgrade-Bestellungen, Free-Plan-E2E mit öffentlicher Testseite, Buy-Button-Weiterleitung auf Checkout.

## Stripe-Webhooks Sandbox (2026-09-14, per API mit Nutzerfreigabe)
- **Shop-Webhook angelegt:** `we_1UFY8vLTW7dodt6IlvHfBP3z`, URL `https://wopcart.com/?wopcart-webhook=stripe`, API **2024-06-20** (im Dashboard nicht wählbar), 8 Events. Signing Secret direkt in WopCart gespeichert (nicht angezeigt) – das doppelte Connect-Secret ist damit ersetzt.
- **Test:** Metadaten-Update am Test-Abo `sub_1UFWRTLTW7dodt6I98wYnuxs` → `customer.subscription.updated` → Stripe liefert an wopcart.com, Antwort **HTTP 200**, `pending_webhooks=0`.
- **Connect-Webhook** `we_1UFQPmLTW7dodt6IStgMnTCS`: Events ergänzt (`account.updated`, `checkout.session.async_payment_failed`, `customer.subscription.updated`). Läuft weiter auf API **2026-08-26.dahlia** – Version eines bestehenden Endpoints ist nicht änderbar; ein neuer Endpoint bräuchte ein neues Secret in `/opt/wopcart/.env`, das Schreiben dorthin wurde für Claude blockiert. Lösung: Plugin wird tolerant für alte und neue Payload-Formate (Fix-Agent, Punkt 15). Asana-Aufgabe „NUTZER: Connect-Webhook (Sandbox) auf API 2024-06-20 umstellen“ als Option B.
- **Live-Konto:** nichts angelegt. Live-Gang erst, wenn alles steht (Entscheidung Nutzer).
- Fix-Agent der Review-Befunde wurde durch Sitzungsende unterbrochen (Stand: 952 Tests grün, viele Fixes drin); ein neuer Agent prüft alle Punkte 1–14, ergänzt Fehlendes und baut Punkt 15 (Stripe-Payload-Kompatibilität + Warnung im Integrations-Dashboard).

## Nach Deploy Welle 2 – offen
- [ ] Seiten-Auswahl in Settings: Entwurfsseiten (z. B. Terms) nicht verwerfen, IDs als int speichern
- [ ] Eigenes Block-Template für `wopcart_product` ohne „Written by"-Byline
- [ ] Stripe-Ende-zu-Ende im Testmodus (braucht Shop-Stripe-Keys in den Einstellungen + `STRIPE_CONNECT_WEBHOOK_SECRET`)
- [x] MCP live getestet (2026-09-14, WP 7.1): 18 Abilities registriert (11 lesen, 7 schreiben). `list-orders` liefert als Admin Daten, anonym `ability_invalid_permissions`. Schreib-Abilities (z. B. `refund-order`) sind standardmäßig abgeschaltet („switched off … enable under WopCart → AI / MCP“). `get-store-summary` verlangt `from`/`to` (korrekt). **Fund:** Summary zählt erstattete Bestellungen weder im Umsatz noch unter `refunded` (refunded=0 trotz $80-Erstattung) → an Welle-3-Agent A (W3-A1) übergeben. Schreib-Ability live erst nach Freigabe testen.
- [ ] Offene Low-Punkte aus dem Review: Spalte `notify_email`, Event-Dedupe atomar, Gutschein-Reservierung beim Order-Anlegen, Aufräumen alter Mollie-Marker-Options
- [x] DejaVu-Lizenz geprüft (2026-09-14): Bitstream-Vera-Lizenz (freizügig, GPL-kompatibel), DejaVu-Änderungen Public Domain; `lib/fonts/dejavu/LICENSE` wird mitgeliefert. Offen: Credit in `readme.txt` ergänzen (nach Welle 3, da beide Agents readme.txt bearbeiten)

## E4 – Rechnungen (gebaut 2026-09-14, nicht deployt)
- **Compliance:** Stückpreis netto + Rabatt, MwSt-Satz je Position, Aufschlüsselung je Satz (auch 0 %), Leistungsdatum wenn abweichend, vollständige Verkäuferadresse, OSS-/Befreiungshinweis, „Sales tax“-Label ohne Steuerspalten (USA), MwSt in EUR mit Kurs und Quelle bei Fremdwährung. Ausstellen blockiert ohne Verkäufername/-adresse/USt-IdNr. oder ohne Kundenadresse.
- **Stornieren:** Entwurf löschbar; ausgestellte unbezahlte Rechnung → Storno-Gutschrift mit nächster Nummer und Bezug, Original bleibt als VOID sichtbar (Wasserzeichen); bezahlte Rechnung nicht stornierbar → Erstattung + Gutschrift. Grund Pflicht.
- **Aufbewahrung:** Löschen ausgestellter Rechnungen 6 Jahre gesperrt (einstellbar). Doppelklick-Schutz für Senden/Erneut senden/Storno/Erstattung/Duplizieren.
- **Admin:** Tabs (Alle/Entwurf/Gesendet/Bezahlt/Überfällig/Storniert) mit Anzahl, Suche, Quelle-Spalte, Aktionen; Detailseite mit Zahlungslink (Kopieren/Öffnen), interner vs. Kundennotiz, Verlauf inkl. erstem/letztem Ansehen, Aktionen Erneut senden (Nachricht, CC), Als bezahlt markieren, Stornieren, Erstatten + Gutschrift, Duplizieren, PDF.
- **Kunden-Zahlungsseite:** Übersicht, Details, Zahlungsarten, Zustände bezahlt/storniert/erstattet/überfällig, Hooks für angehängtes Formular (Betrag gesperrt).
- **Erinnerungen:** vor / am / nach Fälligkeit, ohne Duplikate. Mails: storniert (mit Gutschrift-PDF), bezahlt, PDF-Anhang einstellbar.
- **Fehlende Rechnung bei Erstattung:** wird nachträglich ausgestellt (echtes Ausstellungsdatum, Zahlungsdatum als Leistungsdatum, Hinweis „nachträglich ausgestellt“), dann Gutschrift.
- **Offene Fragen an Nutzer/Steuerberater:** (1) Storno per Gutschrift + Datierung nachträglicher Rechnungen ok? (2) Deinstallation „alle Daten löschen“ während Aufbewahrungsfrist blockieren? (3) Adresse bei Angeboten Pflicht? (4) Eigener täglicher EZB-Kursabruf je Datum statt aktueller Kurs? (5) Mehrere Mahnstufen (7/14/30 Tage)?

## Live-Test 1.1.0 + Hotfix 1.1.1 (2026-09-14)
| Test | Ergebnis |
|---|---|
| Öffentliche Seiten, „Buy“ → 303 /checkout/ | ✅ |
| Admin-Seiten (Dashboard, Formulare, Rechnungen, Angebote, Mitgliedschaften, Integrationen, Settings) | ✅ – Webhooks-Tab 403 ❌ (→ 1.1.1) |
| VIES MT24104415 | ✅ valid – Status-Anzeige blieb „unavailable“ ❌ (→ 1.1.1) |
| Abo-Wechsel 1 → 10 Sites | ❌ Stripe-Idempotency-Konflikt (→ 1.1.1) |
| Zahlungsformular | ❌ Felder mit falschem Namen gerendert, Einsendung unmöglich (kritisch, → 1.1.1); Manipulation $1 abgelehnt ✅ |
| Rechnung: Nummer, PDF, Zahlungsseite, Storno → Gutschrift | ✅ (Zahlung selbst nicht abgeschlossen) |
| Mitgliedschaft: Rolle, Sichtbarkeit Seite + REST, Pause/Fortsetzen | ✅ |
| Erstattungs-Anfrage | nicht testbar (keine bezahlte Bestellung) |
| PHP-Fehler seit Deploy | ✅ keine |

- Hotfix **1.1.1** lokal fertig (1400 Tests grün): Template-Variablen (`Templates::include_template`), Stripe-Idempotency-Keys über Request-Body, `MenuOrganizer::hide_nested` in `admin_head`, `Vies::check` → IntegrationMonitor; readme: „own content“-Aussage entfernt (Funktion abgeschaltet), 11 Elementor-Widgets. Changelog-Seite hat Eintrag 1.1.1. 🚀 **Live 2026-09-14 18:23 UTC** (Backup db-pre111-20260914-182313, Rollback wopcart-prev-20260914-182314). Live verifiziert: Formularfeld-Namen korrekt, Webhooks-Tab 200, VIES valid + Monitor-Erfolg, Abo-Wechsel site1 → site10 erfolgreich (99,00, Lizenz-Limit 10, Stripe-Webhooks 200). Offen: bezahlter Formular-/Rechnungs-Pfad + Erstattung per manuellem Testkauf.
- Hosted Stripe Checkout kann nicht per API mit Testkarte bezahlt werden → bezahlte Pfade (Formular, Rechnung, Erstattung) brauchen einen manuellen Testkauf mit Karte 4242.

### Manueller Testkauf 1.1.1 (Nutzer, 2026-09-14 18:34 UTC)
- ✅ Spendenformular $10 (Karte 4242): Bestellung 000007 complete, Formular-Eintrag paid, Zähler +1 / $10, Rechnung WP-2026-00006, Beleg an cyrusbadde@gmail.com.
- ✅ Erstattung: genau eine Stripe-Erstattung ($10), zweiter Versuch abgelehnt, Eintrag refunded, Zähler zurück auf 0, Gutschrift WP-2026-00007.
- ✅ Plan-Upgrade-Bestellung 000006 ($48,95 anteilig) mit Rechnung WP-2026-00005.
- ❌ Rechnungs-Zahlungsseite: nur „Zahlung läuft“ ohne Link (ältere offene Stripe-Session aus dem Agent-Test; 30-Minuten-Sperre, Stripe-Session aber 24 h gültig) → Fix für 1.1.2 in Arbeit: „Continue to payment“ / „Start over“, Session-Ablauf = Sperrfenster, Abgleich abgeschlossener Sessions.
- Testseite /e2e-form-test/ wieder entfernt (404).
- **1.1.2 vorbereitet** (lokal, 1411 Tests grün): Rechnungs-Zahlungsseite mit „Continue to payment“ / „Start over“, Stripe-Session-Ablauf = Sperrfenster, Abgleich abgeschlossener Sessions beim Seitenaufruf, „Start over“ für PayPal/Mollie/2Checkout, Rate-Limit `invoice_pay`, Proxy erlaubt Session-Expire. Version + readme + Changelog-Seite aktualisiert. 🚀 **Live 2026-09-14 20:09 UTC** (Backup db-pre112-20260914-200951, Rollback wopcart-prev-20260914-200952). Vorher manueller Testkauf Rechnung WP-2026-00002 ($10) → Bestellung 000005 complete, Rechnung paid.

## 2026-09-15
### demo.wopcart.com (Test-Händler für Free Plan / Connect)
- Stack `/opt/wopcart-demo` (MariaDB 256 MB + WordPress 384 MB, 127.0.0.1:4205) läuft, WordPress installiert (noindex), WopCart 1.1.2 ohne Lizenz aktiviert. Admin-Zugang in `/opt/wopcart-demo/admin-login.txt` (600).
- ❌ Kein DNS-Eintrag für demo.wopcart.com (NXDOMAIN, kein Wildcard) → Nutzer: Cloudflare CNAME `demo` → `wopcart.com`, Proxy an.
- ❌ Caddy-Reload fehlgeschlagen (Log-Datei `/var/log/caddy/demo.wopcart.com.log` durfte nicht angelegt werden) → alte Konfig läuft weiter, alle Seiten 200; systemd-Unit hängt in `reloading/reload-notify`. Log-Datei inzwischen mit caddy:caddy angelegt, Demo-Block am Ende des Caddyfile, Backup `Caddyfile.bak-20260915-121440-pre-demo`. Wartet auf Nutzerentscheidung: A) `caddy reload` direkt (kein Neustart) oder B) Block entfernen.

### Release 1.1.3 (lokal, in Arbeit)
- Fertig (1419 Tests): Authorize.net-Guard (Gebühr, Erst-Rabatt, Einführungspreis, mehrere Abos, Einmal-Artikel), gemischte Testphasen/Intervalle abgelehnt (Warenkorb, Checkout, Stripe), PayPal/Mollie bei mehreren Abos ausgeblendet, Checkout verlangt abo-fähiges Gateway.
- Läuft: PayPal-Guard (Einmal-Artikel, Erst-Rabatt, Einführungspreis), 2Checkout-Guard (Testphasen).
- Später: Authorize.net CIM-Vollumbau nach Sandbox-Test.

### RV1 – Bewertungsanfragen (angefordert 2026-09-15, in Arbeit)
- Bewertungen bleiben optional. Neue Einstellung „Bewertung anfragen“: aus / in der Kaufbestätigung / separate Mail nach N Tagen (Standard 7) / beides; pro Produkt überschreibbar; nie bei Erstattung/Storno, nie doppelt pro Bestellposition.
- Mail enthält 5 Sterne-Links (echte Formulare in E-Mails funktionieren in Gmail/Outlook nicht) → kurze Bewertungsseite mit vorausgewählten Sternen, optionalem Text und Absenden-Button; ohne Login über signierten Link (60 Tage).
- Mail-Scanner (z. B. Outlook Safe Links) dürfen durch Vorab-Aufruf nichts veröffentlichen.
- Schema: aggregateRating + bis zu 10 Reviews auf Produktseiten, keine Dopplung mit Yoast/Rank Math/AIOSEO.
- Abmelde-Link für Bewertungsmails, DSGVO-Export/-Löschung. Asana RV1.
- 2Checkout-Guard fertig (1428 Tests): kein 2Checkout bei Einrichtungsgebühr, Erstzahlungs-Rabatt oder Einführungspreis (kein separater Verlängerungspreis möglich). Alle 1.1.3-Guards fertig. **Release-Plan:** Da der Bewertungs-Agent (RV1) im selben Plugin-Baum arbeitet, wird nicht vorher deployt; Guards + Bewertungsanfragen gehen zusammen als **1.2.0** (neue Funktion → Minor).
- demo.wopcart.com: DNS vom Nutzer angelegt; Caddy per `caddy reload` (Freigabe, kein Neustart) übernommen, systemd wieder active/running; wopcart.com, seo-wp.net und demo.wopcart.com antworten 200. Demo-Shop auf Testmodus/USD mit Testprodukt $10. Nächster Schritt: Nutzer verbindet Stripe (Test-Onboarding) im Demo-Admin.
- 12:44 UTC: Connect-Versuch → 403 „ownership“. Ursache: Hostinger-Resolver 153.92.2.6 cached NXDOMAIN für demo.wopcart.com aus der Zeit vor dem DNS-Eintrag (1.1.1.1/8.8.8.8 lösen korrekt). Lokaler Cache geleert; Upstream-Negativcache läuft spätestens ~13:05 UTC ab (SOA-TTL 1800 s). Danach erneut „Connect with Stripe“.

### Release 1.2.0 (vorbereitet 2026-09-15, nicht deployt)
- Inhalt: Bewertungsanfragen per Mail (Sterne-Links, scanner-sicher, Abmelde-Link) + Review-Schema; alle Abo-Guards (Authorize.net, PayPal, Mollie, 2Checkout, unterschiedliche Testphasen/Intervalle); Migration `1.9.0-review-requests`.
- Version 1.2.0 in wopcart.php/readme, Changelog-Seite mit Eintrag `id="1-2-0"` (Datum RELEASE_DATE beim Deploy setzen). 1452 Tests grün.
- ⚠️ Im Baum liegen außerdem Änderungen aus einer anderen Claude-Sitzung (15.09. ~14:46 Ortszeit): SEO-WP-Kompatibilität in `src/Seo/StructuredData.php` (Hooks `seo_wp/schema/graph`, `seo_wp/meta_description`, `seo_wp/opengraph/tags`) und `src/Seo/SystemPages.php` (`seo_wp/sitemap/excluded_post_ids`). Nicht von dieser Sitzung gebaut/geprüft → Nutzer fragen, ob sie in 1.2.0 mit ausgeliefert werden.
- SEO-WP-Integration (2026-09-15, auf Nutzer-Anweisung in dieser Sitzung gebaut; die fremden Änderungen der SEO-WP-Sitzung waren bereits zurückgenommen, sonst keine fremden Änderungen im Baum): `StructuredData` hookt `seo_wp/schema/graph` (filter_list_graph, 20), `seo_wp/meta_description` (guard_description, 20), `seo_wp/opengraph/tags` (guard_aioseo_tags, 20), `print_head()` überspringt bei aktivem SEO-WP; `SystemPages` hookt `seo_wp/sitemap/excluded_post_ids`. Gate `defined('SeoWp\VERSION')`. Filter-Signaturen gegen SEO-WP 1.4.8 Quellcode geprüft. Test `SeoWpIntegrationTest` (separater Prozess). Changelog 1.2.0 ergänzt.

### Git-Repository (2026-09-15)
- Lokales Git-Repo im Plugin-Ordner `/Users/cyrusbadde/projects/plugins/digital-cart` (Branch `main`). Commit 1: Plugin-Quellcode 1.2.0 (862 Dateien; `vendor/`, Build-Ausgaben, `.claude/` ignoriert; keine Secrets).
- Dokumentation entsteht in `docs/` + `README.md`, `CONTRIBUTING.md`, `SECURITY.md` (aus dem Code verifiziert, ohne Server-/Rechts-/Steuer-/Business-Interna), wird nicht ins Plugin-Zip gepackt (`.distignore`) → Commit 2.
- Obsidian bleibt für interne Planung/Betrieb; das Repo ist die Produkt- und Entwicklerdoku.
- Offen: Remote (GitHub/GitLab). `gh` CLI ist nicht installiert → Nutzer legt privates Repo an und nennt die URL (oder erlaubt Installation von `gh`).

## 2026-09-15 — Doku-Repo und Befunde aus dem Doku-Abgleich

- Plugin-Repo `/Users/cyrusbadde/projects/plugins/digital-cart` (Branch `main`): Plugin + Doku (`docs/`, 74 Seiten; README, CONTRIBUTING, SECURITY). Doku nicht im Release-Zip (`.distignore`). Remote noch offen (A: privates Repo-URL vom User, B: gh installieren).
- Links/Anker geprüft (0 kaputt), keine Server-Details/Secrets.
- In 1.2.0 behoben (noch nicht deployed): Rechnungspräfix/-stellen wirkungslos; LMS-Defaults; Sign-up-Gebühr wurde beim Speichern im Pricing-Tab genullt; Steuerklasse E-publication ignoriert; Webhook `invoice.credited` nie gesendet; Breadcrumb-Schema doppelt mit SEO-WP; Systemstatus PHP 8.2; Abo-Mischmeldung; API-Scope-Text; readme-Korrekturen.
- Backlog aus Befunden: Abandoned-Cart-Sequenz ohne Editor und ohne Abmeldelink; Authorize.net-Renewal-Fehler nicht erfasst (zu CIM-Fix); `allow_plan_change`, `quote_validity_days` ohne Settings-Feld; VAT-Override ohne UI; Licensing-API Rate-Limit nur pro IP; Polylang kopiert weniger Meta als WPML; Templates im Theme-Root überschreiben WopCart-Templates; `.pot` noch 1.0.0; `rate_refresh_hours`/`applepay_domain_verified` ungenutzt; Reports: Zahlungsarten/VAT ohne Refund-Abzug.
- 2026-09-15: Remote `origin` = https://github.com/SEO-Agentur/wopcart.git eingetragen; Push offen (keine GitHub-Anmeldung auf dem Mac). Deploy 1.2.0 vom User freigegeben, aber von der Claude-Code-Rechteprüfung („Production Deploy“) blockiert. Changelog-Datum (15 September 2026) und Roadmap-Einträge für 1.2.0 lokal vorbereitet.

## 2026-09-16 — 1.2.1 Security-Release (vorbereitet, nicht deployed)
- Alle Audit-Funde behoben (K1, H1–H2, M1–M7, N1–N11, I1–I5; N12: PWYW-Untergrenze bewusst unverändert, Anti-Spam fail-open bleibt Standard). 1577 Tests grün.
- Neue Migrationen: 1.9.1-license-issue-line, 1.9.1-customer-links, 1.10.0-gateway-secrets, 1.10.0-protected-htaccess.
- Verhaltensänderungen: Zapier-Key nur Header; Update-Pakete nur für aktivierte Seiten; Free-Environments 0 = keine; Kundenverknüpfung nur bei gleicher E-Mail.
- Changelog 1.2.1 (readme, docs, Vault-Seite mit RELEASE_DATE) und Roadmap-Eintrag vorbereitet. Offen: Regression-Review, Apple-Pay-Nachkorrektur, Doku-Update, Commit, Deploy nach Freigabe.
- 2026-09-16 (später): Zwei Regressionsprüfungen der Security-Fixes durchgeführt, alle Funde behoben (Stripe Adaptive Pricing, Auto-Aktivierung nur für neue Seiten, Kunden-Migration mit PHP-Vergleich und strengerer Behalten-Regel, Mitarbeiter-Käufe, E-Mail-Sync nur für Datensätze ohne Historie, Erstattungs-ID vor Betrag, Status-Retry-Regeln, atomare Metadaten, GitHub-„edited“). 1642 Tests grün, keine neuen phpcs-Funde. Doku und Changelog 1.2.1 nachgezogen.
- Restrisiko (Backlog): Ein Nutzer, der seine E-Mail ohne Bestätigung ändert (REST `/wp/v2/users/me`, Admin), sieht den nicht verknüpften Kundendatensatz der neuen Adresse. War schon vor 1.2.1 so. Lösung braucht Identitätsprüfung der E-Mail (z. B. Bestätigungslink vor Zuordnung).
- 2026-09-17: 1.2.1 live (Deploy 04:40 UTC durch User, nach dem finalen Commit 3f54b0e; entspricht dem Endstand). Code auf GitHub `SEO-Agentur/wopcart` (main = 3f54b0e, SSH-Key des MacBooks hinterlegt). Changelog-Datum 17 September 2026 gesetzt. Neues Skript `Deployment/scripts/push-release-pages.sh` veröffentlicht Changelog- und Roadmap-Seite (sichert vorher den alten Inhalt); noch auszuführen, auch die 1.2.0-Einträge sind noch nicht live. Offen: Download-Problem auf wopcart.com.
- 2026-09-17: Changelog-Seite (#83) und Roadmap-Seite (#82) auf wopcart.com aktualisiert (1.2.0 und 1.2.1 sichtbar, von außen geprüft). Offen: Download-Problem auf wopcart.com.
- 2026-09-17: 1.2.2 committet (8914a43): Download-Dateiname mit Endung, Checkout-Aktualisierung nach Landwechsel, Eingaben bleiben nach Ablehnung, Produktvorlage für Block-Themes. Deploy-Skript setzt jetzt die Update-Metadaten von Produkt 14 (Version, Requires, Tested, Requires PHP, Autor, Changelog); `META_ONLY=1` setzt nur diese. Noch nicht deployed.
- Entscheidung (User, 2026-09-17): Zwei Editionen – kostenlose, voll funktionsfähige Version (WordPress.org, Zahlungen über Stripe Connect mit 2 %) und Bezahlversion mit eigenen Gateway-Schlüsseln, Name **WopCart Direct**. Aufbau (Add-on vs. zwei getrennte Plugins) noch offen.
- 2026-09-17: Stufe 1+2 der Qualitätsprüfung behoben → Version 1.2.3 vorbereitet (Details: Security/2026-09-17-Fixes-1.2.3.md). 22 Asana-Aufgaben (18× P0, 4× P1) mit Beschreibung angelegt. Entscheidung Inhaber: Länderabweichung blockiert nicht mehr (Betrugserkennung bleibt bei Stripe), negative Beträge überall gesperrt. Noch nicht committed/deployed.

## 2026-09-18 — Entscheidung: zwei Editionen (Variante A)
- **Kostenlos:** „WopCart“ auf WordPress.org, alle Funktionen, Zahlungen über Stripe Connect mit 2 %.
- **Bezahlt:** Add-on **„WopCart Direct“** (Verkauf über wopcart.com), setzt WopCart voraus, schaltet eigene Gateway-Schlüssel (Stripe, PayPal, Authorize.net, Mollie, 2Checkout, Apple Pay) und den Plan-Schlüssel frei, 0 % Plattformgebühr. Werbesatz: „Deine eigenen Zahlungskonten, 0 % Plattformgebühr.“
- Name „Pro“ verworfen: Er verspricht mehr Funktionen, obwohl die kostenlose Version vollständig ist, und widerspricht der WordPress.org-Regel gegen gesperrte Funktionen. `/pro/` soll auf die Direct-Seite weiterleiten, Hinweis auf der Preisseite.
- **Umbau als 1.3.0:** (1) Erweiterungspunkte im kostenlosen Plugin, (2) eigene Schlüssel + Plan-Schlüssel + Updater wandern nach WopCart Direct, (3) `src/Platform` wird eigenes, nicht öffentliches Plattform-Plugin für wopcart.com, (4) `client/`-Updater-Vorlage geht ins Kunden-SDK, (5) readme-Abschnitt „External services“ und Namensangleichung für WordPress.org, (6) Produkt 14 liefert künftig das Add-on aus, bestehende Plan-Kunden bekommen es als Download.
- 1.2.3 ist live (Deploy durch User); Changelog-Seite datiert 18 September 2026, 1.2.2 als „nicht einzeln veröffentlicht, in 1.2.3 enthalten“ gekennzeichnet; Seiten noch zu veröffentlichen.
- 2026-09-20: Version 1.2.4 committet (1e081e0) — Vorbereitung der WordPress.org-Einreichung, ohne Funktionsänderung. (1) `client/class-wopcart-updater.php` nicht mehr im Release-Paket (hakt sich in WordPress-Update-Transients, im Verzeichnis nicht erlaubt); geht künftig mit den SDK-Downloads an Kunden; Doku an fünf Stellen angepasst. (2) readme neu: Titel = Plugin-Name, Kurzbeschreibung 120 Zeichen ohne Preise, Beschreibung von 10.287 auf 1.718 Zeichen (Limit 2.500, sonst Abschnitt im Verzeichnis abgeschnitten), Details in die FAQ verschoben, neuer Abschnitt „External services“ mit 25 Diensten, alle Angaben am Code geprüft, alle 52 Links mit HTTP 200 getestet; Preis (89 €), EDD-Vergleich und „no locked features“ entfernt. (3) Plugin Check: 170 → erwartet 4 Fehler; 154 SQL-Fehlalarme korrekt annotiert (Annotation muss direkt über der gemeldeten Zeile stehen, sonst wirkungslos), 10 überflüssige `suppress_filters` aus `get_posts()` entfernt, 2 `WP_Query`-Fälle begründet annotiert, 3 Eingabeprüfungen in erkennbare Form gebracht (Reviews-Seitenzahl bleibt `intval`, nicht `absint`, sonst würde -3 zu Seite 3). (4) `.pot` auf 1.2.4, 3.964 Strings. Paket: 606 Dateien, 1,9 MB.
- Offen für die Einreichung: sechs Screenshots (gehören in den SVN-/assets-Ordner, nicht ins Zip) oder Abschnitt kürzen; „Tested up to“ zum Einreichungsdatum prüfen; Einreichung über das WordPress.org-Konto des Inhabers.
- 2026-09-23: Aufteilung dokumentiert und geplant. Neu im Vault: [[Planning/WordPress-org-Launch]] (Epic-Designdokument mit Zielen, Befund, Reihenfolge, Risiken, Abnahmekriterien) und [[Components/Editions]] (Architektur der drei Pakete, Schnittstelle, gemeinsame Daten); Entscheidungen im Protokoll ergänzt (zwei Editionen, Name „Direct“; Länderabweichung blockiert nicht mehr). Asana: [EPIC] WordPress.org-Launch mit 6 Stories und 20 Tasks in der Konvention Status / Task / Ziel-Zustand / Weg dahin / Obsidian-Links; die sechs vorläufigen 1.3.0-Punkte vom 2026-09-18 wurden gelöscht (in Asana wiederherstellbar). Slug `wopcart` ist im Verzeichnis frei.
- 2026-09-24: Entscheidungen zum Lizenzmodell geschärft. (1) Ein Schlüssel, und nur im Add-on: Der Plan-Schlüssel entfällt ersatzlos (keine Bestandskunden), WopCart Direct trägt seine eigene Produktlizenz, ausgestellt von wopcart.com mit WopCart selbst; ≈750 Zeilen Plan-Logik plus Serverseite fallen weg. (2) Schutz gegen Weiterverkauf: Versorgung statt Sperre — Updates und Support an der Lizenz, Plattform bleibt bei uns, Marke anmelden, Downloads je Kunde kennzeichnen; ausdrücklich keine Funktionssperre und kein Lahmlegen bei unerreichbarem Server. Neu im Vault: [[Components/Weitergabe und Lizenzschutz]]; Entscheidungsprotokoll um zwei Einträge ergänzt. Asana: neue Story „Weitergabe absichern“ mit drei Tasks; Lizenz-, Gateway- und Verkaufsaufgaben entsprechend umgeschrieben.
- 2026-09-28: Story 1 der Aufteilung erledigt, committet als 1.3.0 (d87d302). Elf Erweiterungspunkte eingebaut, ohne Verhaltensänderung: `wopcart_stripe_secret_key`, `wopcart_stripe_publishable_key`, `wopcart_uses_own_gateway_credentials` (alter Schalter bleibt als Alias), `wopcart_secret_setting_keys`, zweites Argument für `wopcart_settings_saved`, `wopcart_integration_cards`, `wopcart_integration_test`, `wopcart_system_webhook_checks`, `wopcart_privacy_third_party_content`, `wopcart_enqueue_gateway_scripts`, dazu `Plugin::supports()`. `Connect::is_paid_plan()` heißt jetzt `uses_own_credentials()` (Alias bleibt), neun Aufrufstellen umgestellt. Fehlermeldung vereinheitlicht: ein Code, aber ein nicht verbundener Shop wird auf Einstellungen → Zahlungen hingewiesen (Wortlaut aus ConnectClient übernommen). 1887 Tests grün (29 neue), phpcs ohne neue Funde, `.pot` auf 1.3.0. Doku: 14 Seiten, Hook-Register neu gezählt (282 Zeilen), neue Seite `docs/developers/extending-with-add-ons.md` für Add-on-Autoren, Links geprüft (75 Dateien, 642 Links, 0 Fehler). Offen: Push, Deploy, Release-Datum auf der Changelog-Seite; danach Story 2 (Plattform-Code abtrennen).
- 2026-10-06: Story 2 erledigt. Neues Plugin **WopCart Platform 1.0.0** (`projects/plugins/wopcart-platform`, eigenes Git, `d0ba3a7`): Server.php, ConnectServer.php, ProxyPolicy.php, die zwei Connect-Methoden und die Tabellen `platform_sites`/`platform_deliveries` (Namen unverändert, CREATE-Anweisungen zeichengleich). Es registriert nichts und meldet „steht bereit“, solange der Kern den Server-Teil noch enthält, Kern < 1.3.1 ist oder fehlt. Kern 1.3.1 (`a8d885a`): −2.882 Zeilen in `src/`, neue Hilfsklasse `Platform/PlatformSite.php` (ConnectClient und Plan brauchten die Plattform-Erkennung), Migration `1.11.0-platform-tables` entfernt die Tabellen nur auf Nicht-Plattform-Installationen und verschont jede Tabelle mit Zeilen (mit Protokolleintrag), geplante Aufgabe `wopcart_platform_deliver` aus dem Kern genommen. Kern 1844 Tests grün (49 wanderten mit, 6 neu), Plattform 53 Tests grün, phpcs ohne neue Funde. Ausroll-Anleitung: [[Deployment/WopCart Platform ausrollen]] — Reihenfolge zwingend: erst Plattform-Plugin aktivieren, dann Kern aktualisieren.
- 2026-10-20: Stories 3 und 5 erledigt. **WopCart Direct 1.0.0** (`projects/plugins/wopcart-direct`, eigenes Git, `c50e6e4`): die vier Gateways, eigene Stripe-Schlüssel, fünf Zugangs-Abschnitte, Stripe-Karte samt Verbindungstest, Lizenzschlüssel und eigene Update-Auslieferung; 208 Tests grün; hängt sich ausschließlich an die Haken aus 1.3.0, ändert keine Kern-Datei. Abgelaufene Lizenz stoppt nur Updates — bewusst ohne Durchsetzungscode. **Kern 1.4.0** (`0d911f3`): −6.277 Zeilen (PayPal, Authorize.net, Mollie, 2Checkout, Plan, PlanVerdict, gate_credentials, Plan-Karte, allowed_gateways), Wächter-Test `FreeEditionHasNoPaidCodeTest`, Deinstallation entfernt keine fremden Zugangsdaten mehr und leitet ihre Listen aus dem Installer ab (vier geplante Aufgaben, Release-Beiträge und eine Mitgliedschafts-Berechtigung überlebten vorher). 1711 Tests grün. readme, README und 19 Doku-Seiten umgeschrieben; „External services“ bereinigt; Hook-Register 282 → 270.
- **Gefundene Altlasten:** Formulare boten 2Checkout nie an (Liste nannte `twocheckout`, der Anbieter meldet `2checkout`); die 2Checkout-Karte im Integrations-Bereich wurde aus demselben Grund nie gebaut; die Deinstallation hätte bezahlte Zugangsdaten gelöscht.
- **Wichtig für wopcart.com:** Ab 1.4.0 beantwortet niemand mehr die Entitlement-Frage, auch nicht für die Plattform selbst. wopcart.com braucht deshalb **WopCart Direct installiert**, bevor der Kern auf 1.4.0 geht, sonst greift der eigene Stripe-Schlüssel nicht. Reihenfolge in [[Deployment/WopCart Platform ausrollen]] ergänzt.
- Offen: Story 4 (Verkaufsweg auf wopcart.com), Push beider Repos, Ausrollen in der dokumentierten Reihenfolge, Release-Daten auf der Changelog-Seite.
- 2026-10-21: **Website-Inhaltsseiten ins Design geholt.** `/pricing/`, `/docs/`, `/integrations/`, `/why-wopcart/`, `/support/`, `/eu-vat/`, `/plan-changes-refunds/` enthielten im Rumpf keine einzige `wc-`Klasse und sind neu geschrieben, dazu inhaltlich auf die beiden Editionen umgestellt (kein Lizenzschlüssel in der kostenlosen Version, Mollie bei Direct ergänzt, „plan key“ → Lizenzschlüssel des Add-ons). Zwei Sachfehler korrigiert: `/why-wopcart/` behauptete, physische Produkte seien nicht möglich — Versand ist seit Welle 3 enthalten, offen sind nur Carrier-Anbindungen; `/integrations/` kannte Mollie nicht. Menü mit Dropdowns Docs und Help. Werkzeuge: `Deployment/scripts/push-pages.{sh,php}` (beliebige Slugs + Menü, mit Sicherung und HTTP-Prüfung), `Deployment/mu-plugins/05-design-pages.php` für die Design-Klasse. Doku: [[Website/Seiten-Redesign 2026-10-21]]. Offen: Ausrollen (Skript muss der Nutzer starten), `/direct/` fehlt noch für die Kaufknöpfe.
- 2026-10-21: **Git-Sicherung.** Kern bis `a996ca1` nach `SEO-Agentur/wopcart` gepusht. Vault als Repository angelegt (`de771c5`). Für Direct, Platform und Vault sind die Fernziele eingetragen, die drei privaten Repositories müssen auf GitHub noch angelegt werden. Zips neu gebaut: Kern 1.4.0, Direct 1.0.0, Platform 1.0.0. Siehe [[Deployment/Git-Repositories]].
- 2026-10-21: **Affiliate geklärt.** Kein eigenes System; AffiliateWP und SliceWP sind angebunden, ein eigenes Partnerprogramm für wopcart.com bleibt in Planned. Siehe [[Components/Affiliate und Partnerprogramm]].
- 2026-10-21: **Kern 1.4.1 — Anbindung an das Seooptimierung Toolkit repariert.** Das Plugin hieß bis 1.7 SEO-WP und hat Namensraum (`SeoWp` → `Seooptimierung\Toolkit`) und Filterpräfix (`seo_wp/` → `seooptimierung/`) mitgenommen; WopCart suchte die alten Namen, die Anbindung war auf jeder aktuellen Installation tot: kein Produkt- und Paywall-Schema im Graph, Beschreibungen und Open-Graph-Angaben nicht abgesichert, Systemseiten in der Sitemap, Brotkrumen doppelt. Jetzt werden beide Präfixe gehakt und beide Konstanten gelten als aktiv, `seo_wp_active()` bleibt veralteter Alias. 1712 Tests grün (5 für diesen Fall), phpcs sauber. Gepusht als `6916048`. Doku: [[Components/SEO und strukturierte Daten]].
- 2026-10-21: **Zweiter Durchgang Website.** `/faq/` und `/software-licensing/` ins Design, Produktseite 14 von „WopCart Plan“ auf **WopCart Direct** umgeschrieben (Titel per Direktive in der Datei), Roadmap-Wortlaut zu Stripe geklärt (Zahlungen sind live, in Arbeit ist die Connect-Abrechnung), Changelog um 1.4.1 ergänzt und die vier `RELEASE_DATE`-Platzhalter auf den 21.10.2026 gesetzt. `push-pages.sh` kennt jetzt Produkte, `05-design-pages.php` auch Produktseiten und Produktarchiv. Offen: `/features/` und `/paywall-memberships/` ohne Design, Produktarchiv `/products/` zeigt vollen Inhalt statt Raster, `/direct/` und `/pro/` fehlen weiter.
- 2026-10-21: **Kern 1.4.2 — zwei Kästen erklären sich jetzt selbst.** Der Bundle-Reiter zeigte auf einem Shop mit nur einem Produkt einen leeren Rahmen, der wie ein kaputtes Textfeld aussah: die Mehrfachauswahl listet nur *andere veröffentlichte* Produkte. Jetzt sagt sie, warum die Liste leer ist, bietet auch Entwürfe mit Statusangabe und erklärt, dass man auswählt statt tippt. Der Kasten „Releases & Deploy" zeigte Webhooks, Geheimnis und Signaturschlüssel an jedem Produkt; jetzt erklärt er, dass Releases für Software sind, und zeigt sonst nichts, solange die Lizenzierung am Produkt aus ist. 1712 Tests grün, gepusht als `3f3e733`.
- 2026-10-21: **Germanized abgeglichen.** Bestandsaufnahme in [[Planning/Germanized-Vergleich]]: dreizehn Punkte sind schon da (OSS, VIES, Steuer auf Versand, Grundpreise, Netto/Brutto, Widerrufszustimmung, AGB-Checkbox, Rechnungen mit Storno, DSGVO, WPML, REST, Rückerstattungsanfragen). Acht lohnen sich, in dieser Reihenfolge: Lieferzeiten, GPSR-Herstellerangaben, Widerrufsfunktion nach EU 2023/2673, Kleinunternehmerregelung § 19, Versandhinweis am Preis, Button-Lösung, Rechtstexte in E-Mails, Differenzbesteuerung mit Gebrauchtware. Fünf sind bewusst abgelehnt (Lebensmittel, Photovoltaik, verzögerter Vertragsschluss, DOI bei der Registrierung, eigene PDF-Automatik). Asana: neues Epic mit sechs Stories.
- 2026-10-22: **Stripe Connect: zwei Blocker gefunden und behoben.** (1) Die Eigentumsprüfung scheiterte, weil auf der Testseite das Seooptimierung Toolkit die REST-API auf angemeldete Benutzer beschränkt — die Plattform holt die Challenge aber unangemeldet ab. (2) **Kontoanlage war seit jeher unmöglich:** `account_controller()` verlangte einen Express-Dashboard, ließ aber Gebühren beim Händler und Verluste bei Stripe; Stripe erlaubt Express nur, wenn die Plattform beides übernimmt. Deshalb wurde „Free plan via Stripe Connect" nie fertig. Behoben in **WopCart Platform 1.0.1** (`7dca45b`): `stripe_dashboard.type = full`, Gebühren beim Händler, Verluste bei Stripe, `requirement_collection = stripe`, festgenagelt von `ConnectAccountControllerTest`. Nebenbefund: `Server.php` importierte `WopCart\Platform\PlanVerdict`, das der Kern in 1.4.0 gelöscht hat — auf Kern 1.4 hätte die Plan-Route einen Fatal Error geworfen; die zwei Protokoll-Codes stehen jetzt im Plattform-Plugin selbst. 55 Tests grün. Sofortmaßnahme ohne Rollout: `Deployment/mu-plugins/06-connect-controller.php`. Doku: [[Deployment/Stripe-Connect-Fehler 2026-10-22]].
- 2026-10-22: **Schritt 2 des Rollouts erledigt: WopCart Platform 1.0.2 läuft auf wopcart.com** und steht wie vorgesehen bereit („needs WopCart 1.3.1 or newer"), weil dort noch Kern **1.2.3** liegt. Tabellen unverändert (1 / 0 Zeilen), Seite und REST-Routen gesund. **Dabei zwei Fatals abgefangen, bevor sie live gingen:** Platform 1.0.1 und Direct 1.0.0 riefen `\WopCart\Plugin::supports()` auf, das erst Kern 1.3.0 mitbringt — auf 1.2.3 hätte das Aktivieren jede Anfrage inklusive wp-admin zerlegt. Behoben in **Platform 1.0.2** (`5051bf7`) und **Direct 1.0.1** (`28b7198`), beide mit Test auf den Wächter. Offen: Kern 1.3.1 → Direct → Kern 1.4.2.
- 2026-10-22: **Rollout vollständig. wopcart.com läuft auf Kern 1.4.2 mit Platform 1.0.2 und Direct 1.0.1.** Reihenfolge wie dokumentiert: 1.2.3 → 1.3.1 (Routen wandern ins Plattform-Plugin) → Direct installieren (eigener Stripe-Schlüssel greift) → 1.4.2. Vorher Datenbank und Plugin-Verzeichnis gesichert. Nach jedem Schritt geprüft: Plugins aktiv, Routen vorhanden, Cron eingeplant, Tabellen und Daten unverändert (9 Bestellungen, 4 Lizenzen, 1 Plattform-Seite), alle Seiten HTTP 200, keine PHP-Fehler. Danach Update-Metadaten und Käuferdatei auf 1.4.2 gezogen und die Website veröffentlicht: elf Seiten, Produktseite (jetzt „WopCart Direct") und Kopfmenü mit den Dropdowns Docs und Help. Dabei fiel auf, dass `05-design-pages.php` auf dem Server noch die Fassung vom Vortag war — FAQ, Lizenzseite und Produktseiten standen kurz ohne Design da, inzwischen behoben. Offen bleibt: SEO-Titel aus `manifest.json` werden von `push-pages.sh` nicht geschrieben.
- 2026-10-22: **Dritter Connect-Blocker: der Idempotenz-Schlüssel.** Stripe speichert unter einem Idempotenz-Schlüssel auch Ablehnungen und antwortet 24 Stunden lang damit. Weil der Schlüssel nur aus dem Site-Key gebildet wurde, bekam die Testseite nach der Reparatur weiter die alte Express-Absage serviert, statt einen neuen Versuch zu starten. **Platform 1.0.3** (`f827646`) hasht jetzt Site-Key und Parameter: gleiche Parameter geben weiter dasselbe Konto zurück, geänderte bekommen einen frischen Versuch. Drei Tests, 63 grün, auf wopcart.com ausgerollt und geprüft.
- 2026-10-24: **Kern 1.5.0 — Mindestlaufzeit gebaut** (`e250d8b`). Preisoptionen tragen eine Bindung in Abrechnungsperioden; abgerechnet wird weiter monatlich, nur die Kündigung wirkt zum Bindungsende. Kein Vorauszahlungsmodell, weil der erste Händler Pakete zu 2.500 und 5.000 im Monat verkauft. Das Gateway wird während der Bindung bewusst nicht angefasst; nach der letzten Buchung innerhalb der Bindung übernimmt die gewöhnliche Kündigung zum Periodenende, mit einem zweiten Netz im Verlängerungslauf. Entgegen dem ersten Entwurf war **kein** `cancel_at` und damit keine Öffnung der `ProxyPolicy` nötig. Sichtbar vor dem Kauf als Länge, danach als Datum (Konto, Dialog, Adminliste, Webhooks, MCP); aufgeschobene Kündigungen zählen sofort im At-Risk-Bericht. Nebenbei behoben: die Adminliste zeigte kein nächstes Zahldatum (Zeitstempel an `mysql2date`). 1722 Tests grün (10 neu), phpcs sauber. Doku: [[Components/Monetisation]], `docs/features/subscriptions.md`. Offen: Ausrollen auf wopcart.com und auf guaranteedseoservices.com, dazu die Kanten Upgrade/Erstattung/Zahlungsausfall **innerhalb** der Bindung.
