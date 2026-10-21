# Security-Audit WopCart 1.2.0 (2026-09-15)

Statische Code-Prüfung (nur lesend), Commit `e6ed2b6`. Server nicht geprüft. Vollbericht: `2026-09-15-security-audit-1.2.0.html`.

**Zählung:** 1 kritisch · 2 hoch · 7 mittel · 12 niedrig · 5 Hinweise. Noch nichts behoben.

## Vor Stripe-Livegang beheben
- **K1** Stripe-Rückkehrlink akzeptiert fremde bezahlte Session → Bestellung freigeschaltet (`Stripe.php:596-660`). Von Hand bestätigt.
- **H2** Apple-Pay-PaymentIntent wiederverwendbar (`ApplePay.php:120-165`).
- **M1** Abschluss/Freischaltung nicht atomar → doppelte Lizenzen/Abos.
- **M2** Stripe/PayPal-Webhooks nicht an Site/Order-Key/Betrag gebunden.

## Kundendaten
- **H1** Konto-Übernahme eines Gastkäufers über Checkout-E-Mail (`CustomerRepository::upsert/current`). Von Hand bestätigt.
- **M7** Verifizierte Bewertungen im Namen anderer + Kauf-Abfrage per E-Mail.

## Secrets / Missbrauch
- **M6** Gateway-Secrets im Settings-HTML, Shop-Manager sieht sie, autoloaded.
- **M5** REST-Cart ohne Rabattcode-Rate-Limit; Meldungen verraten Codes.
- **M4** Lizenz-API Rate-Limit nicht atomar/nur IP; `/license/version` unbegrenzt.
- **M3** Update-Downloads ohne Aktivierung/Seat-Limit.

## Niedrig / Hinweise
N1 Refund-Webhooks doppelt · N2 Zapier-Key in URL + Ziel-URL ohne UrlGuard · N3 Pfadprüfung ohne Slash · N4 REST-Read breiter als MCP · N5 GitHub-Webhook-Replay · N6 Lizenzantwort-Replay · N7 Bundle-Seats doppelt (unbestätigt) · N8 Staging-Seats selbst gemeldet · N9 Webhook-Payloads unbegrenzt/Eraser-Lücken · N10 ipapi.co trotz Land · N11 Protected-Ordner nur .htaccess · N12 Kleinkram. I1–I5: API-Key-Scopes, Elementor-Shortcodes, Dateinamen, Signaturschlüssel im Klartext, CSV-Restlücke.
