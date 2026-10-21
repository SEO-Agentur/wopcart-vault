# Feature-Liste zur Freigabe

**Stand:** 2026-09-14 · Grundlage: WPSmartPay-Plugin (Video), wpsmartpay.com (Startseite, Integrationen, Preise) · Nutzer sagt pro ID zu oder ab → Asana → Bau.
Aufwand grob: S ≈ 1–2 Tage · M ≈ 3–5 Tage · L ≈ 1–2 Wochen.

## Neu von wpsmartpay.com

- Preise: Essential $99/Jahr (1 Site) · Business $149 (5 Sites) · Agency $279 (50 Sites); alle Funktionen in jedem Plan; Money-back-Garantie; AppSumo-Lifetime-Deal live
- Kostenlos auf WordPress.org („Download Free")
- 14+ Zahlungsarten: Stripe, PayPal, **Mollie** (iDEAL, Bancontact, SEPA), **Paddle (Merchant of Record)**, Authorize.Net, Razorpay, Paytm, bKash, toyyibPay
- „Build payment forms with AI" aus einem Prompt, „Use any agent: Claude / ChatGPT / Codex / Cursor / OpenClaw / Hermes"
- Custom Amounts, Recurring Donations, Customer Dashboard, PDF-Rechnung
- Integrationen gruppiert: LMS, Email/CRM, Fluent-Ökosystem, Affiliate/Users, Notifications, Automation
- Affiliate-Programm 30 % (laut Nutzer)

**Preise neu seit 2026-09-14 (A3 entschieden, USD, EU-Verbraucher zzgl. MwSt.):** WopCart 1 Site $50/Jahr oder $80 Lifetime · 10 Sites $99/Jahr oder $150 Lifetime · 100 Sites $200/Jahr oder $280 Lifetime. Die alten EUR-Pakete (Single bis Enterprise) sind entfallen. Zum Vergleich WPSmartPay: Essential $99/Jahr (1 Site), Agency $279/Jahr (50 Sites).

## Liste

| ID | Feature | Warum | Aufwand | Empfehlung |
|---|---|---|---|---|
| **A – Grundlage** |||||
| A1 | Stripe-Connect-Onboarding für den Gratis-Plan | Gratis-Plan funktioniert sonst nicht | M | Ja, zuerst |
| A2 | Veröffentlichung auf WordPress.org (Review, Richtlinien, Assets) | „Download Free" ist deren Haupt-Einstieg | M | **Nutzer 2026-09-14: erst nach Gleichziehen und Überholen.** Richtlinien-Konformität trotzdem bei jedem Feature mitprüfen |
| A3 | Preismodell überarbeiten (Domains pro Paket) | Konkurrenz: 50 Sites für $279 | – (Entscheidung) | Ja |
| **B – Verkauf & Wachstum** |||||
| B1 | Aktionscode-Einlösung (AppSumo), stapelbar | AppSumo-Deal abwickeln | M | Ja – **Nutzer 2026-09-14: AppSumo-Start wie WordPress.org erst, wenn alles fertig ist.** Muss vor dem Start stehen, nicht vorgezogen |
| B2 | Lifetime-Pakete im Plan-Server | LTD-Käufer | S | Ja |
| B3 | Money-back-Garantie pro Produkt (x Tage, Bedingungen, Zugang entziehen) | Kaufhürde; bei WPSmartPay nur für eigene Lizenzen, nicht als Funktion | M | Ja |
| B4 | Partnerprogramm für WopCart, 2 Stufen, Dashboard, Auszahlung per Stripe Connect, Gutschriften | WPSmartPay zahlt 30 % | L | Ja |
| B5 | Affiliate-System für Händler (gleiche Technik wie B4) | WPSmartPay braucht AffiliateWP | M | Ja |
| B6 | Importer aus WPSmartPay, EDD, WooCommerce, Gumroad, Lemon Squeezy | Wechsler holen | L | Später |
| **C – Zahlungen** |||||
| C1 | Mollie (iDEAL, Bancontact, SEPA, Klarna) | EU-Markt | M | Ja |
| C2 | Paddle als Merchant of Record | Steuern weltweit ausgelagert | M | Ja |
| C3 | Weitere Stripe-Zahlarten: SEPA-Lastschrift, Klarna, Google Pay, Link | mehr Methoden ohne neues Gateway | S | Ja |
| C4 | Zahlungsformulare als Gutenberg-Blöcke + Vorlagen | Kernfunktion der Konkurrenz | L | Ja |
| C5 | Freie Beträge und Spenden (einmalig/wiederkehrend, Widmung, anonym) | Donations | M | Ja |
| C6 | Ziele mit Fortschrittsbalken, Stichtag, Schließen bei Erreichen | Fundraising | S | Ja |
| C7 | KI-Formular-Builder aus Prompt (setzt C4 voraus) | deren neues Hauptargument | M | Ja |
| C8 | Zahlungslinks und gehostete Checkout-Seiten, QR-Code | teilen ohne WP-Seite | S | Ja |
| **D – Umsatz** |||||
| D1 | Order Bumps + 1-Klick-Upsell nach dem Kauf | mehr Umsatz, deren Lösung braucht WPFunnels | M | Ja |
| D2 | Sale-Preis mit Zeitraum (Streichpreis) | Standard | S | Ja |
| D3 | Gutscheine massenhaft erzeugen + CSV-Export | Standard, auch für AppSumo | S | Ja |
| D4 | Umsatzrettung: Smart Retries, Karten-Update-Link, Mails vor Kartenablauf | weniger Churn | M | Ja |
| D5 | Kündigungsdialog mit Pausieren / kleinerem Paket; Abo pausieren | weniger Churn | M | Ja |
| **E – Rechnungen & Steuern** |||||
| E1 | Manuelle Rechnungen mit Zahlungslink, Fälligkeit, Erinnerungen, als bezahlt markieren, stornieren, Verlauf | Konkurrenz hat es | M | Ja |
| E2 | Echtes PDF für alle Rechnungen | Konkurrenz hat es | S | Ja |
| E3 | E-Rechnung XRechnung / ZUGFeRD | DE-Pflicht kommt, Konkurrenz hat es nicht | M | Ja |
| E4 | Steuern UK, Schweiz, US Sales Tax | internationale Händler | M | Später |
| **F – Kunden & Berichte** |||||
| F1 | Kundenportal erweitern: Rechnungen, Zahlungsmethode ändern, pausieren, Domains | weniger Support | M | Ja |
| F2 | Login-Pflicht pro Produkt, Checkout-Layout nebeneinander | Kleinigkeiten der Konkurrenz | S | Ja |
| F3 | Abo-Analyse: Churn, gefährdete Abos, MRR-Verlauf, Erstattungsquote, Recovery | Konkurrenz hat es | M | Ja |
| **G – KI** |||||
| G1 | MCP über WordPress Abilities API inkl. Lizenz- und Domain-Funktionen, Anleitung Claude/ChatGPT/Cursor | Gleichziehen + mehr | M | Ja |
| G2 | KI-Analyse im Admin („Welche Abos sind gefährdet?") über MCP | Differenzierung | S | Später |
| **H – Integrationen** |||||
| H1 | Integrationsseite mit Karten und Kategorien | Überblick | S | Ja |
| H2 | E-Mail/CRM: Brevo, Mailchimp, MailerLite, ActiveCampaign, FluentCRM, mit DSGVO-Opt-in | Konkurrenz hat 5 | M | Ja |
| H3 | LMS: LearnDash, Tutor LMS, LifterLMS | Kurs-Verkäufer | M | Ja |
| H4 | Membership: Wishlist Member, Restrict Content Pro, Paid Memberships Pro | Mitgliedschaften | M | Später |
| H5 | Slack, Telegram, Google Sheets | Benachrichtigungen | S | Ja |
| H6 | FluentSupport, FluentCommunity | Fluent-Nutzer | S | Später |
| H7 | Uncanny Automator, Integrately, Pabbly, Make, n8n + mehr Webhook-Events | Automatisierung | S | Ja |
| H8 | AffiliateWP-Anbindung (für bestehende Nutzer) | Wechsler | S | Später |
| H9 | Twilio SMS | niedrige Nachfrage, Kosten | S | Nein |
| **I – Schutz & Lizenzen** |||||
| I1 | Anti-Spam: Honeypot, Cloudflare Turnstile, hCaptcha, reCAPTCHA | Konkurrenz hat es | S | Ja |
| I2 | Dateischutz: PDF-Wasserzeichen, S3/R2/Bunny mit signierten Links, Video-Streaming | Creator | M | Später |
| I3 | Lizenz-SDKs für Nicht-WordPress-Software (JS, Python, Electron, PHP), GitHub-Release-Deploy, Beta-Kanäle | Alleinstellung | L | Ja |
| **J – Größere Projekte** |||||
| J1 | Marktplatz / Multi-Vendor mit Stripe-Connect-Split | EDD hat es | L | Später |
| J2 | Modernes Admin-UI | Demo-Wirkung | L | Später |
| J3 | Event-Tickets mit QR-Check-in | Events | M | Später |
| J4 | Buchungen & Termine | eigenes Produktfeld | L | Nein (Integration statt Eigenbau) |
| J5 | Umfragen | kein Zahlungsbezug | M | Nein |
| **K – Website & Vermarktung** |||||
| K1 | Live-Demo-Seite, öffentlicher Changelog & Roadmap, Wissensdatenbank, Support-Chat | Vertrauen | M | Ja |
| K2 | Vergleichsseite WopCart vs. WPSmartPay (nur belegbare, datierte Fakten) | SEO + Vertrieb | S | Ja |

## Entscheidungen zu Gebühr und Partnerprogramm

- **2 % bei Erstattung:** Empfehlung *nicht zurückgeben* bei normalen Erstattungen und Money-back; *zurückgeben* bei Fehlern auf WopCart-Seite (Doppelabbuchung, technischer Fehler) und bei nachgewiesenem Betrug. In den AGB offenlegen.
- **Partnerprogramm:** Vergleichsbasis beachten – 30 % bei WPSmartPay beziehen sich (vermutlich) auf den Lizenzpreis. Vorschlag: Stufe 1 = 30 % auf Paket-Umsatz (erstes Jahr) + 20 % der 2 %-Fee für 24 Monate; Stufe 2 = 5 % auf beides. Rechtliche Prüfung.
