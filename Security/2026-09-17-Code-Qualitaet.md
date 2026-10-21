# Code-Qualitätsprüfung WopCart (Stand 1.2.2, Commit 8914a43) — 2026-09-17

Nur lesend geprüft, jeder Fund am Code und an den Aufrufern verifiziert. Keine TODO/FIXME-Marker, aber unfertige Funktionen, Logikfehler, toter und doppelter Code.
Rund 55 schwere, 140 mittlere, 110 kleine Funde (einige Bereiche überlappen, z. B. 2Checkout-Kündigung, „hosted invoice“-Einstellung).

## Stufe 1 — Shop-Blocker, Geld, Sicherheit (vor Livegang)
- Rabattcode mit Mindestbestellwert → endlose Rekursion, Warenkorb stürzt ab (DiscountEngine.php:57 / Cart::totals). **Bestätigt.**
- Authorize.net-Kartenfelder werden von wp_kses_post entfernt → Kartenkauf unmöglich (templates/checkout.php:324). **Bestätigt.**
- 2Checkout: Kündigung nur lokal, Abrechnung läuft weiter; nächste Zahlung reaktiviert das Abo.
- PayPal/Authorize.net: erste Abo-Zahlung falsch erkannt (times_billed) → doppelte Verlängerungen bzw. keine.
- Statuswechsel ungeprüft: erneute Zahlungsmeldung setzt erstattete Bestellung wieder auf „complete“.
- Bundles und Abo-Downloads gewähren Zugriff nach Kündigung weiter.
- PayPal: zweite Teilerstattung gleichen Betrags wird übersprungen (Idempotency-Key).
- 2Checkout-Webhooks: Listenfelder vor Signaturprüfung geleert; Authorize.net-Abo: Bestellung vor Abbuchung bezahlt, Fehlschläge nicht erfasst; PayPal verwendet alten Tarif nach Intervall-/Testphasen-Änderung.
- Manuelle Rechnung/Angebot mit Produkt: MwSt. doppelt bei Bruttopreisen; parallele Anfragen → zwei Rechnungsnummern; Rechnungsjahr in UTC; Präfix „Q“ kollidiert mit Angeboten; bezahlte Proforma ohne Rechnungsnummer.
- Beleg-Mail als gesendet markiert, auch wenn Versand scheitert; Verlängerungs-/Testphasen-Mails ohne Datum.
- Länder-Header (CF-IPCountry) fälschbar für die MwSt.-Prüfung.
- Öffentlicher KI-Endpunkt ohne Nutzung kann das Claude-Budget verbrauchen.
- Bewertungsmeldung aus URL-Text (Inhaltsfälschung).
- Google Sheets meldet immer Erfolg; Brevo-Double-Opt-in fällt still auf Direktanmeldung zurück (DSGVO); Restrict Content Pro legt bei Verlängerung neue Mitgliedschaften an (unbestätigt).
- Frontend: CSS-Konflikt Formular/Produktkarte; Kaufformular für Admins und Wiederkäufer ausgeblendet; Sortierung nach Verkäufen/Bewertung blendet Produkte aus.

## Stufe 2 — Datenverlust im Admin
- Rabatt-Import und Rabatt-Bearbeitung löschen Felder (Produkte > 200, Beschreibung, Kategorien, „nie“-Modus).
- Bundles verlieren Produkte (> 300 / unveröffentlicht); Inhaltsbeschränkung verliert Produkte (> 200).
- Mehrfachauswahl (Gateways, Währungen, Umgebungen, Anti-Spam-Formulare) nicht leerbar.
- Nach dem Speichern immer Reiter „Allgemein“; Link im Systemstatus auf nicht existierenden Reiter.
- Formularfeld „Maximale Länge“ 0 → 1 Zeichen.

## Stufe 3 — Berichte, Steuern, Zeit
- Zwei verschiedene Währungsumrechnungen (Faktor 100 bei JPY); Verlängerungsbestellungen ohne Steuerland/Kurs/Positionen; „Reverse charged“ zeigt Anzahl als Geld; unterschiedliche Definitionen je Reiter; Wiederherstellungsquote immer 0 %; Zeiträume in UTC.
- „.99“-Rundung wirkt auch auf interne Umrechnungen; fehlender Wechselkurs = 1:1; Reverse Charge bei Bruttopreisen.

## Stufe 4 — Nicht verdrahtete oder irreführende Funktionen
- 8 Store-Blöcke nicht im Editor; REST-API-Schlüssel nicht anlegbar; Zapier-Schlüssel wird nie angezeigt; „Käufer zur externen Rechnung leiten“ ohne Wirkung; Lizenz-Verlängerungslink verlängert nicht; Testmodus wirkt im kostenlosen Plan nicht; Shop-Adresse (Stadt/PLZ) ohne Feld; Polylang übernimmt 10 Felder nicht; Webhooks bremsen den Checkout und können doppelt gesendet werden.
- Geplante Aufgaben bei Aktivierung/Deinstallation unvollständig; Migrationen ohne Sperre; Download-Link-Gültigkeit < 1 Tag wirkungslos; Shop-Benachrichtigungen an Absenderadresse; falscher Captcha-Schlüssel schaltet Schutz ab.

## Stufe 5 — Aufräumen
- Doppelter Code (Sperren, MwSt.-Aufschlag ×6, E-Mail-Normalisierung ~30×, Rückerstattung je Gateway, Anbieter-Boilerplate, Rechnung/Angebot), Riesendateien (ProductMeta, Admin, Settings, Webhooks, ManualInvoices, Privacy, account.php), toter Code (~25 Methoden, alte CSS), veraltete Kommentare.

Details: Berichte der Prüf-Agents in der Claude-Code-Sitzung vom 2026-09-17.
