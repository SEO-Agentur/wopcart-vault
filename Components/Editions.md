# Editionen: WopCart, WopCart Direct, WopCart Platform

**Stand:** 2026-09-23 · **Epic:** [[Planning/WordPress-org-Launch]] · **Verwandt:** [[Components/Monetisation]] · [[Components/Payments]]

## Aufteilung

**WopCart (kostenlos, WordPress.org).** Der vollständige Shop: Warenkorb, Checkout,
Abos, Lizenzen, Rechnungen, Steuern, Formulare, Mitgliedschaften, Integrationen.
Zahlungen werden über die Stripe-Connect-Plattform von wopcart.com abgerechnet, die dabei
2 % als Stripe-Application-Fee einbehält. Enthält Stripe und Apple Pay.

**WopCart Direct (bezahlt, wopcart.com).** Add-on, setzt WopCart voraus. Bringt die
eigenen Gateway-Zugänge (Stripe, PayPal, Authorize.net, Mollie, 2Checkout, Apple Pay über
das eigene Stripe-Konto), den Plan-Schlüssel und die eigene Update-Auslieferung.
Werbesatz: „Deine eigenen Zahlungskonten, 0 % Plattformgebühr.“

**WopCart Platform (nicht öffentlich).** Läuft nur auf wopcart.com: Connect-Onboarding,
Ereignis-Weiterleitung, Gebührenprüfung, die Tabellen `platform_sites` und
`platform_deliveries`.

## Warum Add-on und nicht zwei vollständige Plugins

| | Add-on (gewählt) | Zwei Plugins |
|---|---|---|
| Kauf | Add-on dazu installieren, nichts wird ersetzt | kostenlose Version deaktivieren, Bezahlversion installieren |
| Planende | Add-on deaktivieren, Shop läuft mit 2 % weiter | Rückwechsel mit demselben Risiko |
| Pflege | Shop-Code existiert einmal | jede Korrektur zweimal ausliefern |
| Updates | Hauptteil über WordPress.org, auch für Zahlende | vollständige Software selbst ausliefern |
| Risiko | zwei Plugins müssen zusammenpassen | gleichzeitige Aktivierung beider Plugins beschädigt Daten |

Der Ausschlag gab die Sicherheit: Beide Plugins teilen Tabellen und Einstellungen. Wären
zwei vollständige Kopien gleichzeitig aktiv, gäbe es doppelte Menüs, doppelte
Webhook-Verarbeitung und Namenskonflikte.

## Namensentscheidung

**WopCart Direct**, nicht „Pro“. „Pro“ verspricht mehr Funktionen, obwohl die kostenlose
Version vollständig ist, und widerspricht der Erzählung, die WordPress.org verlangt.
„Direct“ benennt den Unterschied: Zahlungen laufen direkt über die eigenen Konten.
`/pro/` leitet auf die Direct-Seite weiter, auf der Preisseite steht ein Hinweis.

## Lizenzschlüssel: einer, und nur im Add-on — DECIDED 2026-09-23

Die kostenlose Version verlangt **keinen** Schlüssel und darf keinen verlangen. Ein Plugin
im Verzeichnis muss ohne Schlüssel vollständig funktionieren; verboten sind gesperrte
Funktionen, Selbst-Aktualisierung außerhalb von WordPress.org und Kaufaufforderungen im
Admin. Erlaubt ist dagegen, einen externen Dienst anzubinden, auch einen kostenpflichtigen,
solange er offengelegt ist — deshalb ist die Abrechnung über die Plattform mit 2 % kein
Problem, das heutige Feld für den Plan-Schlüssel aber sehr wohl.

**Direct trägt genau einen Schlüssel: seine eigene Produktlizenz.** Es gibt noch keine
Bestandskunden, also wird der heutige Plan-Schlüssel nicht mitgeschleppt, sondern
**ersatzlos gestrichen**. `Platform/Plan.php` und `Platform/PlanVerdict.php` (≈750 Zeilen),
das Plan-Feld in den Einstellungen, die Plan-Karte im Integrations-Bereich und die
Plan-Endpunkte auf wopcart.com entfallen.

Der Schlüssel wird gebraucht für zwei Dinge, die ohne ihn nicht gehen: **Updates absichern**
(sonst wandert die Zip-Datei weiter) und **Produktivdomains zählen** (die Preise sind nach
1, 10 und 100 Domains gestaffelt).

Dafür ist keine neue Technik nötig: wopcart.com verkauft WopCart Direct als lizenziertes
Produkt mit WopCart selbst. `src/Licensing` kann Schlüssel, Aktivierungen, Plätze, freie
Test- und Staging-Installationen und Update-Auslieferung bereits. Direct bindet die
Updater-Vorlage ein, aktiviert den Schlüssel und holt darüber seine Updates.

**Verhalten bei abgelaufener Lizenz:** Die eigenen Gateway-Zugänge bleiben aktiv, nur
Updates hören auf. Ein zahlender Kunde soll nie wegen einer abgelaufenen Lizenz unbemerkt
wieder 2 % zahlen.

## Schnittstelle zwischen den Plugins

Bereits vorhanden: `wopcart_gateway_classes`, `wopcart_settings_sections`,
`wopcart_save_settings`, `wopcart_modules`, `wopcart_option_{key}`,
`wopcart_manage_secrets_capability`, `wopcart_script_config`,
`wopcart_invoice_gateway_reports_no_payment`, `wopcart_is_paid_plan`.

Neu zu bauen (Schritt 1): `wopcart_stripe_secret_key` und `wopcart_stripe_publishable_key`
(je `string $key, string $mode`), `wopcart_uses_own_gateway_credentials`,
`wopcart_secret_setting_keys`, `wopcart_integration_cards`,
`wopcart_system_webhook_checks`, `wopcart_privacy_third_party_content`,
`wopcart_enqueue_gateway_scripts`, ein zweites Argument `$previous` für
`wopcart_settings_saved` und `Plugin::supports( string $minimum )`.

Diese Filter gelten ab 1.3.0 als **eingefrorene Schnittstelle**: Sie dürfen nicht entfernt
oder umbenannt werden, solange ein Add-on sie nutzt.

## Gemeinsame Daten

- `wopcart_settings` (autoloaded): beide schreiben hinein, schlüsselweise gemerged.
  Enthält `plan_key`, `gateways_enabled`, die nicht geheimen Zugangsfelder.
- `wopcart_gateway_secrets` (nicht autoloaded): die Geheimnisse. Das Add-on liest sie
  unverändert über `Options::get()`; kein Datenumzug nötig.
- Tabellen: das Add-on legt keine an.
