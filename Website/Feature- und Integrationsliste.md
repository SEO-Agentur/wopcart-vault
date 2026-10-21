# WopCart – Feature- und Integrationsliste (für Einzelseiten)

Stand 2026-09-14. Status: **Live** = in 1.0.0 auf wopcart.com · **1.1.0** = gebaut, kommt mit dem nächsten Update · **In Arbeit** · **Geplant**.
Slug = Vorschlag für die Seiten-URL. Der Nutzer liefert je Seite ein gestyltes Layout.

## A. Verkaufen & Checkout
| # | Feature | Status | Slug |
|---|---|---|---|
| A1 | Checkout (Gast-Checkout, optionales Konto, Widerrufs-/AGB-Zustimmung) | Live (Redesign 1.1.0) | /features/checkout/ |
| A2 | Warenkorb-Seite + Ziel nach „In den Warenkorb“ (Checkout/Warenkorb/bleiben) | 1.1.0 | /features/cart/ |
| A3 | Buy-Buttons, Produktseiten, Produkt-Grid (Block + Shortcode) | Live | /features/buy-buttons/ |
| A4 | Variable Preise / Preisoptionen (z. B. 1/10/100 Sites) | Live | /features/pricing-options/ |
| A5 | Produktvarianten mit Hauptvariante | Live | /features/variants/ |
| A6 | Bundles | Live | /features/bundles/ |
| A7 | Physische Produkte, Lager, Reservierung, Versandzonen/-klassen, Gewicht & Größe, Volumengewicht, Sendungsnummer | Live | /features/physical-products-shipping/ |
| A8 | Produktkategorien als Pfad + Permalinks (/shop/ oder Domain), 301-Weiterleitungen, Breadcrumbs | Live | /features/categories-permalinks/ |
| A9 | Zeitplanung (online ab/bis) + Limitierung (gesamt, pro Kunde) | Live | /features/scheduling-limits/ |
| A10 | Rabatte, Gutscheine, Massen-Gutscheine + CSV | Live | /features/discounts/ |
| A11 | Sale-Preise mit Zeitraum + EU-Omnibus (niedrigster Preis 30 Tage) | Live | /features/sale-prices/ |
| A12 | Netto/Brutto-Preisanzeige + Grundpreis (z. B. €/kg) | Live | /features/price-display/ |
| A13 | Mehrwährung + Währungsumschalter | Live | /features/multi-currency/ |
| A14 | Warenkorbabbrecher-Mails | Live | /features/abandoned-cart/ |
| A15 | KI-Produktempfehlungen | Live | /features/recommendations/ |
| A16 | Bewertungen | Live | /features/reviews/ |
| A17 | Zahlungsformulare (Block-Builder, 17 Vorlagen, feste/gestaffelte/freie Beträge, einmalig/wiederkehrend, Ziele, Einsendungen + CSV) | 1.1.0 | /features/payment-forms/ |
| A18 | Spenden & Fundraising-Ziele (Fortschrittsbalken, anonym, Gebühren übernehmen) | 1.1.0 | /features/donations/ |
| A19 | Order Bumps + 1-Klick-Upsells | Geplant | – |
| A20 | Zahlungslinks + QR-Codes | Geplant | – |
| A21 | KI-Formular-Builder aus Prompt | Geplant | – |

## B. Abos & Kundenbindung
| # | Feature | Status | Slug |
|---|---|---|---|
| B1 | Abonnements (Stripe-Abrechnung, Testphasen, Einrichtungsgebühr) | Live | /features/subscriptions/ |
| B2 | Upgrades/Downgrades mit anteiliger Berechnung, keine Gutschriften | Live | /features/plan-changes/ |
| B3 | Umsatzrettung (Mahn-Mails, Zahlungsmethode aktualisieren, Kartenablauf-Hinweis) | Live | /features/revenue-recovery/ |
| B4 | Kündigungsdialog (Gründe, Pausieren, günstigeres Paket, Halte-Rabatt) | Live | /features/cancellation-flow/ |
| B5 | Kundenkonto (Bestellungen, Downloads, Lizenzen, Abos, Dokumente) | Live | /features/customer-account/ |
| B6 | Mitgliedschaftsstufen (Rollen, Rechte, Ablaufregeln, Pause-Verhalten) | 1.1.0 | /features/memberships/ |
| B7 | Inhalte schützen (Paywall pro Seite, Block, Menüpunkt, Shortcodes; „nur Käufer“) | Live (Stufen 1.1.0) | /paywall-memberships/ (existiert) |
| B8 | Erinnerung vor Abo-Verlängerung | Geplant | – |
| B9 | Jahresabo → Lifetime umwandeln | Geplant | – |
| B10 | Partnerprogramm (2 Stufen) / Affiliates | Geplant | /affiliates/ (existiert) |

## C. Software-Lizenzen & digitale Auslieferung
| # | Feature | Status | Slug |
|---|---|---|---|
| C1 | Lizenzschlüssel, Domain-Aktivierungen, Staging-/lokale Sites frei | Live | /software-licensing/ (existiert) |
| C2 | Lifetime- und befristete Lizenzen pro Preisoption | Live | (in C1) |
| C3 | Signierte Lizenzantworten (Ed25519) | Live | (in C1) |
| C4 | Releases, Beta-Kanäle, automatische Updates, GitHub-Deploy | Live | /features/releases-updates/ |
| C5 | Lizenz-SDKs (PHP, JavaScript, Python) | Live | /developers/sdks/ |
| C6 | Geschützte Downloads (ablaufende Links, Limits) | Live | /features/secure-downloads/ |

## D. Steuern, Rechnungen & Recht
| # | Feature | Status | Slug |
|---|---|---|---|
| D1 | EU-MwSt (Länder-Sätze, VIES, Reverse Charge, Nachweise, OSS-Report) | Live | /eu-vat/ (existiert) |
| D2 | PDF-Rechnungen + Gutschriften (lückenlose Nummern) | Live | /features/invoices/ |
| D3 | Rechtskonforme Rechnungen (EU Art. 226, MwSt in EUR, Aufbewahrung 6 Jahre) | 1.1.0 | (in D2) |
| D4 | Manuelle Rechnungen mit Zahlungslink, erneut senden, stornieren, Verlauf, Erinnerungen | Live (erweitert 1.1.0) | /features/manual-invoices/ |
| D5 | Angebote (Quotes) → Proforma → Rechnung | Live | /features/quotes/ |
| D6 | Erstattungs-Anfragen + automatische Genehmigung (EU-Widerruf) | Live | /features/refund-requests/ |
| D7 | DSGVO: Export, Löschung, Datenschutztexte | Live | /features/privacy-gdpr/ |
| D8 | E-Rechnung (XRechnung/ZUGFeRD) | Geplant | – |

## E. Verwaltung & Auswertung
| # | Feature | Status | Slug |
|---|---|---|---|
| E1 | Dashboard (Umsatz, Bestellungen, Ø-Wert, Vergleich zur Vorperiode, Diagramm) | Live (Redesign 1.1.0) | /features/dashboard/ |
| E2 | Berichte (Umsatz, MwSt, Abo-Analyse: MRR, Churn, Erstattungen) | Live | /features/reports/ |
| E3 | Kunden-Detailseiten (Kaufverlauf, Lizenzen, Abos, offener Warenkorb) | Live | /features/customers/ |
| E4 | Bestellungen, Erstattungen, Dokumente | Live | (in E1) |
| E5 | Import/Export, WP-CLI | Live | /developers/cli/ |
| E6 | Checkout-Design (Layout, Akzentfarbe, Theme-Farben) | 1.1.0 | (in A1) |

## F. Sicherheit & Plattform
| # | Feature | Status | Slug |
|---|---|---|---|
| F1 | Anti-Spam (Honeypot, Turnstile, hCaptcha, reCAPTCHA, Rate-Limits) | Live | /features/anti-spam/ |
| F2 | Kostenloser Plan über Stripe Connect (2 %) | In Arbeit | /pricing/ (existiert) |
| F3 | Betrugsschutz für den kostenlosen Plan | Geplant | – |
| F4 | Webhooks (21+ Events, signiert, Zustellprotokoll, Secret-Rotation) | Live (+Formular/Mitgliedschaft 1.1.0) | /developers/webhooks/ |
| F5 | REST-API | Live | /developers/rest-api/ |
| F6 | KI / MCP (Abilities für KI-Assistenten) | Live | /features/ai-mcp/ |
| F7 | Integrations-Seite mit Verbindungsstatus | Live (Hub 1.1.0) | /integrations/ (existiert) |

## G. Zahlungsanbieter
| # | Anbieter | Status | Slug |
|---|---|---|---|
| G1 | Stripe (Karten, Apple Pay, Google Pay, Link, SEPA u. a.) | Live | /integrations/stripe/ |
| G2 | PayPal | Live | /integrations/paypal/ |
| G3 | Mollie | Live | /integrations/mollie/ |
| G4 | Authorize.net | Live | /integrations/authorize-net/ |
| G5 | 2Checkout | Live | /integrations/2checkout/ |
| G6 | Apple Pay | Live | (in G1) |
| G7 | Paddle | Geplant | – |

## H. Integrationen (Hub, 1.1.0 – außer markiert)
| # | Integration | Kategorie | Status | Slug |
|---|---|---|---|---|
| H1 | Mailchimp | Marketing | 1.1.0 | /integrations/mailchimp/ |
| H2 | Brevo | Marketing | 1.1.0 | /integrations/brevo/ |
| H3 | MailerLite | Marketing | 1.1.0 | /integrations/mailerlite/ |
| H4 | ActiveCampaign | Marketing/CRM | 1.1.0 | /integrations/activecampaign/ |
| H5 | FluentCRM | CRM | 1.1.0 | /integrations/fluentcrm/ |
| H6 | Zapier | Automatisierung | Live | /integrations/zapier/ |
| H7 | Make | Automatisierung | Live (Preset), Karte 1.1.0 | /integrations/make/ |
| H8 | n8n | Automatisierung | Live (Preset), Karte 1.1.0 | /integrations/n8n/ |
| H9 | Pabbly Connect | Automatisierung | Live (Preset), Karte 1.1.0 | /integrations/pabbly/ |
| H10 | Integrately | Automatisierung | 1.1.0 | /integrations/integrately/ |
| H11 | Uncanny Automator | Automatisierung | Live (+Mitgliedschaften 1.1.0) | /integrations/uncanny-automator/ |
| H12 | WPFunnels | Automatisierung | 1.1.0 | /integrations/wpfunnels/ |
| H13 | WP User Registration (Konto nach Kauf) | Automatisierung | 1.1.0 | (in B5) |
| H14 | Slack | Kommunikation | 1.1.0 | /integrations/slack/ |
| H15 | Discord | Kommunikation | 1.1.0 | /integrations/discord/ |
| H16 | Telegram | Kommunikation | 1.1.0 | /integrations/telegram/ |
| H17 | Twilio SMS | Kommunikation | 1.1.0 | /integrations/twilio/ |
| H18 | Google Sheets | Kommunikation | 1.1.0 | /integrations/google-sheets/ |
| H19 | Fluent Support | Support | 1.1.0 | /integrations/fluent-support/ |
| H20 | FluentCommunity | Community | 1.1.0 | /integrations/fluentcommunity/ |
| H21 | LearnDash | LMS | Live | /integrations/learndash/ |
| H22 | Tutor LMS | LMS | Live | /integrations/tutor-lms/ |
| H23 | LifterLMS | LMS | Live | /integrations/lifterlms/ |
| H24 | MemberPress | Membership | 1.1.0 | /integrations/memberpress/ |
| H25 | Wishlist Member | Membership | 1.1.0 | /integrations/wishlist-member/ |
| H26 | Restrict Content Pro | Membership | 1.1.0 | /integrations/restrict-content-pro/ |
| H27 | Paid Memberships Pro | Membership | 1.1.0 | /integrations/paid-memberships-pro/ |
| H28 | AffiliateWP | Affiliate | 1.1.0 | /integrations/affiliatewp/ |
| H29 | SliceWP | Affiliate | 1.1.0 | /integrations/slicewp/ |
| H30 | Google Analytics 4 (serverseitig) | Analytics | 1.1.0 | /integrations/google-analytics-4/ |
| H31 | Meta Conversions API | Analytics | 1.1.0 | /integrations/meta-conversions-api/ |
| H32 | Invoices Generator (Connector) | Rechnungen | Live | – |
| H33 | Versanddienstleister (DHL, UPS, FedEx, Post) | Versand | Geplant | – |

## I. Page Builder, Themes & Mehrsprachigkeit
| # | Kompatibilität | Status | Slug |
|---|---|---|---|
| I1 | Gutenberg / Block-Themes (Blöcke + Shortcodes) | Live | /integrations/gutenberg/ |
| I2 | Elementor (8 Widgets live, +3 in 1.1.0) | Live | /integrations/elementor/ |
| I3 | Divi (7 Module) | 1.1.0 | /integrations/divi/ |
| I4 | Bricks (7 Elemente) | 1.1.0 | /integrations/bricks/ |
| I5 | Beaver Builder, Oxygen, Breakdance (Shortcodes) | 1.1.0 (Asset-Laden) | /integrations/page-builders/ |
| I6 | WPML | 1.1.0 | /integrations/wpml/ |
| I7 | Polylang | 1.1.0 | /integrations/polylang/ |
| I8 | Übersetzbar (.pot) + RTL | Live (RTL 1.1.0) | (in I6) |
