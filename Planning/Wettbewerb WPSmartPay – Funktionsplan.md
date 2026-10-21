# Wettbewerb WPSmartPay – Funktionsplan

**Stand:** 2026-09-14 · **Quelle:** AppSumo-Video „The Cleanest Way to Get Paid on WordPress" (WPSmartPay 3.2.2, Screenshots des Nutzers) · **Status:** Plan, noch nichts gebaut

## 1. Was WPSmartPay zeigt

| Bereich | Details aus den Screenshots |
|---|---|
| Formular-Builder | Nativer Gutenberg-Editor, 15 Vorlagen: Payment (3), Donation, Registration & Signup, Event, Survey & Feedback, Contact, Booking & Appointments (je 2) |
| Formular-Einstellungen | Titel an/aus, max. Breite, Checkout-Layout stacked/split, „Require login to checkout" |
| Spenden | Frequenz einmalig/monatlich/jährlich, Betragskacheln, anonym, Beleg-Option, Widmungstext |
| Ziele | Menge oder Betrag, Zielwert, Fortschrittsbalken im Frontend, bei Erreichen weiter/schließen, letzter Zahltag, Abschlusstext |
| Rechnungen | Anlegen mit Formular, Betrag, Fälligkeit; Draft/Sent/Paid/Void; Resend, Mark as Paid, Void; Zahlungslink; Invoice-PDF; Notizen; Aktivitätsverlauf |
| Kunden | Profil mit Zahlungszählern, Adresse, Newsletter-Status, Zahlungen mit Filtern |
| Gutscheine | Prozent/Fest, Ablaufdatum, **Bulk Generate** |
| Berichte | Zeiträume; Umsatz, Zahlungen, Ø-Wert; Tabs Overview/Forms/Subscriptions/Goals/Recovery; Abo: Active, MRR, At-Risk, Churned, New, At-Risk-Liste |
| Produkte | Liste mit Streichpreis, Tabs Details/Pricing/Checkout, Dateien, Cover, Shortcode |
| Integrationen | 27 (Free 2, Pro 22): Mailchimp, MailerLite, FluentCRM, AffiliateWP, Pabbly, Zapier, Slack, Telegram, Twilio SMS, Google Sheets, LMS (3), Membership (2), Support, Community |
| Einstellungen | General, Payment Gateways, Emails, Invoice, **Anti-Spam**, Tax, Extension, Webhooks, Licenses, **AI/MCP** |
| AI/MCP | MCP-Adapter-Plugin, 15 Abilities (Coupons anlegen/listen/bulk, Payments, Customers, Invoices anlegen/senden/listen, Subscriptions listen/kündigen, Forms anlegen/listen/holen), Anleitung für Claude Code / Claude Desktop mit Application Password |

**Beobachtung:** Der Bericht zeigt `1834.9799995422363` → Beträge als Gleitkommazahl gerechnet. WopCart rechnet in ganzen Cent.

## 2. Abgleich mit WopCart (im Code geprüft, 2026-09-14)

| Funktion | WopCart |
|---|---|
| Software-Lizenzen, Domains, Update-Server | ✅ vorne |
| EU-VAT (VIES, Reverse Charge, Nachweis, OSS-Bericht) | ✅ vorne |
| Paywall mit SEO-Schutz, Yoast/Rank Math/AIOSEO | ✅ vorne |
| Bundles, Multi-Currency, Warenkorbabbrecher, Reviews, Dateien pro Preisoption | ✅ vorne |
| Tarifwechsel ohne Erstattung, Upgrades | ✅ vorne |
| Rechnungen | ⚠️ nur zu Bestellungen, fortlaufend nummeriert + Gutschriften; **druckbare HTML-Seite, kein PDF**; keine manuelle Rechnung mit Zahlungslink |
| MRR | ⚠️ Zahl im Dashboard; **kein At-Risk, keine Churn-Rate, kein Verlauf** |
| Webhooks | ⚠️ 5 Events (order.completed/refunded, invoice.issued/credited, subscription.renewed); Zapier vorhanden |
| Formular-Builder, freie Beträge, Spenden | ❌ |
| Ziele / Fortschrittsbalken | ❌ |
| Gutscheine massenhaft erzeugen | ❌ |
| Streichpreis / Sale-Preis | ❌ |
| Anti-Spam (Honeypot, Turnstile, reCAPTCHA) | ❌ |
| Newsletter/CRM nativ (Mailchimp, MailerLite, Brevo, FluentCRM) | ❌ (nur über Zapier) |
| AffiliateWP, Slack, Telegram, Google Sheets, LMS | ❌ |
| MCP / WordPress Abilities API | ❌ |
| Checkout-Layout, Login-Pflicht pro Produkt, manuelle Bestellung im Admin | ❌ |
| Money-back-Garantie | ❌ (auch bei WPSmartPay nicht gesehen) |
| **Stripe-Connect-Onboarding für den Gratis-Plan (#131)** | ❌ **Blocker** |

## 3. Plan nach Priorität

Aufwand: S ≈ 1–2 Tage · M ≈ 3–5 Tage · L ≈ 1–2 Wochen (grobe Schätzung, Agenten-gestützt)

### P0 – Voraussetzung und AppSumo-Tauglichkeit

| # | Funktion | Warum | Aufwand |
|---|---|---|---|
| 0 | **Stripe-Connect-Onboarding** (#131) | Ohne das funktioniert der Gratis-Plan nicht – Website verspricht ihn | M |
| 1 | **Code-Einlösung (AppSumo-Codes)** – Codes importieren, einlösen → Lizenz/Paket, Codes stapelbar für mehr Domains | Ohne sie kein AppSumo-Deal abwickelbar | M |
| 2 | **Money-back-Garantie** optional pro Produkt (x Tage, Selbstbedienung oder Antrag, Bedingungen: max. Downloads/Domains/Erstattungen pro Kunde, Zugang automatisch entziehen, Erstattungsquote im Bericht) | Kaufhürde; WPSmartPay hat es nicht | M |
| 3 | **MCP über WordPress Abilities API** – Abilities für Bestellungen, Kunden, Abos, Gutscheine, Rechnungen, Berichte **und Lizenzen/Domains** (Domain abmelden, Lizenz verlängern) mit Rechteprüfung; Anleitung Claude Code/Desktop | Gleichziehen + Lizenz-Abilities hat WPSmartPay nicht | M |

### P1 – Gleichziehen bei Zahlungsformularen

| # | Funktion | Aufwand |
|---|---|---|
| 4 | **Zahlungsformulare als Gutenberg-Blöcke**: freie Felder, frei wählbarer Betrag mit Min/Vorschlägen, einmalig/wiederkehrend wählbar, Vorlagen (Zahlung, Spende, Anmeldung, Event-Ticket) | L |
| 5 | **Ziele**: Menge/Betrag, Balken, Stichtag, schließen bei Erreichen | S |
| 6 | **Manuelle Rechnungen mit Zahlungslink**: Fälligkeit, Erinnerungen, als bezahlt markieren, stornieren, Verlauf, **echtes PDF** (auch für bestehende Bestell-Rechnungen) | M |
| 7 | **Gutscheine massenhaft erzeugen** + CSV-Export | S |
| 8 | **Sale-Preis mit Zeitraum** (Streichpreis, Schema `priceValidUntil`) | S |
| 9 | **Anti-Spam**: Honeypot, Cloudflare Turnstile / hCaptcha / reCAPTCHA, Rate-Limit am Checkout | S |
| 10 | **Abo-Analyse**: MRR-Verlauf, Churn, At-Risk-Liste, Neuzugänge, Erstattungsquote, Warenkorb-Recovery | M |

### P2 – Integrationen

| # | Funktion | Aufwand |
|---|---|---|
| 11 | **Integrationsseite** mit An/Aus-Karten und Kategorien | S |
| 12 | Newsletter/CRM mit DSGVO-Opt-in am Checkout: **Brevo, Mailchimp, MailerLite, FluentCRM** | M |
| 13 | **AffiliateWP** (Provisionen, Stornierung bei Erstattung) | S |
| 14 | Benachrichtigungen: **Slack, Telegram**; **Google Sheets** | S |
| 15 | Mehr Webhook-Events (subscription.created/cancelled/failed, license.activated/deactivated, refund) → Pabbly/Make/n8n | S |
| 16 | LMS: LearnDash / LifterLMS / Tutor LMS (Kurszugang bei Kauf) | M |

### P3 – Prüfen, nicht sofort

| # | Funktion | Anmerkung |
|---|---|---|
| 17 | Checkout-Layout split, Login-Pflicht pro Produkt, manuelle Bestellung im Admin | klein, sammeln |
| 18 | Buchungen & Termine | eigenes Produktfeld, eher Integration (z. B. Amelia) |
| 19 | Umfragen | kein Kernnutzen für Zahlungen |
| 20 | Modernes Admin-UI (React) | großer Umbau; wirkt in Demos stark – Entscheidung nötig |
| 21 | Import aus EDD / WooCommerce | holt Wechsler ab |
| 22 | Twilio SMS | Kosten/Datenschutz, niedrige Priorität |

## 4. Positionierung gegenüber WPSmartPay

- Lizenzen mit Domain-Verwaltung und Update-Server
- EU-VAT-konform (für EU-Händler ein Muss)
- Beträge in ganzen Cent – keine Rundungsfehler
- Paywall, die in SEO-Snippets und REST nichts verrät
- Tarifwechsel ohne Erstattung und Domain-Regeln eingebaut
- Money-back-Garantie mit Missbrauchsschutz (nach Umsetzung)
- Alle Funktionen im freien Plugin (WPSmartPay: 22 von 27 Integrationen Pro)

## 4b. Weitere WPSmartPay-Integrationen (Screenshot 2)

WP User Registration, Fluent Support, FluentCommunity, LearnDash, Tutor LMS, LifterLMS, ActiveCampaign,
Integrately, Wishlist Member, Restrict Content Pro, Uncanny Automator, WPFunnels.

## 4c. Ideen, um wirklich vorne zu liegen (2026-09-14)

### Partnerprogramm statt „MLM" (Idee des Nutzers: 10 % der Fee über 3 Stufen)

- **Rechnung:** 2 % Fee → 10 % davon = 0,2 % des Händlerumsatzes pro Stufe. Bei 3 Stufen gehen bis zu 30 % der Fee-Einnahmen raus.
- **Rechtlich (keine Rechtsberatung, prüfen lassen):** EU-UGP-Richtlinie Anhang I Nr. 14 verbietet Schneeballsysteme, bei denen **Verbraucher** für die Chance zahlen, an der Anwerbung weiterer zu verdienen. § 16 Abs. 2 UWG (progressive Kundenwerbung) ist in DE sogar strafbar. Wenig Risiko entsteht nur, wenn niemand für die Teilnahme zahlt, die Provision **nur aus echten, bezahlten Fees** kommt und die Teilnehmer Unternehmer sind.
- **Ruf:** „MLM" schreckt die WordPress-Zielgruppe ab. Als „Partner-/Agenturprogramm" positionieren.
- **WordPress.org:** Referral-Links nur nach Opt-in und mit Offenlegung, nichts ungefragt ins Admin einfügen.
- **Empfehlung:** 2 Stufen (z. B. 10 % / 3 %), befristet (z. B. 24 Monate pro geworbenem Händler), nur auf eingezogene Fees abzüglich Erstattungen/Chargebacks, keine Selbstwerbung, Mindest-Auszahlung, Auszahlung per Stripe Connect Transfer (Connect-Konten gibt es ohnehin), Gutschrift mit korrekter USt (Self-Billing/Reverse Charge).
- **Größerer Hebel:** Agenturen – Partner-Dashboard mit allen Kundenseiten, Paketen, Domains, Provisionen.

### Differenzierer, die WPSmartPay nicht hat

| Idee | Warum stark |
|---|---|
| **Eingebautes Affiliate-System für Händler** (Links, Gutschein-Zuordnung, Provisionen, Auszahlung per Stripe Connect/PayPal, Betrugsprüfung) | WPSmartPay braucht AffiliateWP (Pro) |
| **Order Bumps + 1-Klick-Upsell** nach dem Kauf (gespeicherte Karte, Stripe off_session) | direkt mehr Umsatz; WPSmartPay braucht WPFunnels |
| **Umsatzrettung:** Smart Retries, Karten-Update-Link, Mails vor Kartenablauf, Kündigungsdialog mit Pausieren/Downgrade-Angebot | senkt Churn, passt zu „keine Erstattung" |
| **Kundenportal:** Rechnungen, Zahlungsmethode ändern, Abo pausieren, Domains verwalten | weniger Support |
| **E-Rechnung XRechnung/ZUGFeRD** (DE: Empfang Pflicht seit 2025, Ausstellung B2B ab 2027/2028) | EU-Händler brauchen es bald zwingend |
| **Lizenz-SDK für Nicht-WordPress-Software** (JS/Node, Python, Electron, PHP) + GitHub-Release → automatisches Update-Paket, Beta-Kanäle | macht WopCart zur Lizenzplattform, nicht nur WP-Plugin-Shop |
| **Datei-Schutz:** PDF-Wasserzeichen mit Käufer-E-Mail, S3/R2/Bunny mit signierten URLs, geschütztes Video-Streaming | Piraterie-Schutz für Creator |
| **Zahlungslinks & gehostete Checkout-Seiten** ohne WP-Seite, QR-Code | schnell teilen (Social, Events) |
| **Marktplatz / Multi-Vendor** mit Stripe-Connect-Split | EDD hat es, WPSmartPay nicht |
| **Importer „in 5 Minuten wechseln"** aus WPSmartPay, EDD, WooCommerce, Gumroad, Lemon Squeezy | holt Wechsler |
| **MCP mit Lizenz- und Analyse-Abilities** („Welche Abos sind gefährdet?") | über Gleichziehen hinaus |
| **Globale Steuern:** UK VAT, CH, US Sales Tax (Nexus-Hinweise), optional Paddle als Merchant of Record | internationale Händler |

### Vertrauen & Vermarktung

- Öffentlicher Changelog und Roadmap, Security-Audit, Beträge in ganzen Cent als Argument
- Vergleichsseite nur mit belegbaren, datierten Fakten
- AppSumo-Deal mit stapelbaren Codes und klaren Lifetime-Grenzen

## 5. Offene Entscheidungen

1. Integrationen im freien Plugin (passt zum Modell „alles gratis") oder als Pro-Unterscheidung?
2. AppSumo-Deal: Lifetime-Pakete? Welche Domains pro Code, wie viele Codes stapelbar? Wirkt auf die Jahres-Pakete.
3. Money-back: Standarddauer (14/30 Tage), Selbstbedienung oder Antrag, 2 %-Plattformgebühr bei Erstattung zurückgeben?
4. Buchungen/Termine und Umfragen selbst bauen oder weglassen?
5. Admin-UI modernisieren (React) oder beim wp-admin-Stil bleiben?
6. Reihenfolge: P0 komplett vor P1, oder Formulare (4) vorziehen, weil sie im Video am stärksten wirken?
