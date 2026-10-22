# WopCart Platform ausrollen (wopcart.com)

**Stand:** 2026-10-06 · **Verwandt:** [[Components/Editions]] · [[Planning/WordPress-org-Launch]] · [[Deployment/wopcart.com]]

Der Server-Code von wopcart.com (Plan- und Lizenz-Endpunkte, Connect-Onboarding, Weiterleitung
der Stripe-Ereignisse, Gebührenprüfung) liegt ab Kern-Version 1.3.1 nicht mehr im Plugin,
sondern im eigenen Plugin **WopCart Platform 1.0.0**. Repository:
`/Users/cyrusbadde/projects/plugins/wopcart-platform` (eigenes Git, Commit `d0ba3a7`).

## Reihenfolge — nicht vertauschen

1. **Vor allem anderen prüfen**, dass in der `wp-config.php` von wopcart.com weiterhin stehen:
   `WOPCART_PLATFORM_PRODUCT_ID`, `WOPCART_PLATFORM_STRIPE_KEY` (oder die Einstellung
   `stripe_platform_secret`) und `WOPCART_CONNECT_WEBHOOK_SECRET`.
   Fehlt die Produkt-ID, hält die Migration des Kerns wopcart.com für einen gewöhnlichen Shop.
   Die Tabellen bleiben dann zwar erhalten (Zeilen werden nie gelöscht, es wird protokolliert),
   aber die Plattform-Routen wären tot, bis die Konstante zurück ist.
2. **Plattform-Plugin hochladen und aktivieren, solange der alte Kern noch läuft.**
   Es erkennt, dass der Kern den Server-Teil noch mitbringt, registriert nichts und meldet im
   Admin „steht bereit“. Die Aktivierung legt die zwei Tabellen an — ein Nulleffekt, weil sie
   bereits existieren und die Definitionen zeichengleich sind.
3. **Danach den Kern auf 1.3.1 aktualisieren** (`deploy-plugin.sh`). Ab dem nächsten Aufruf
   gibt es `WopCart\Platform\Server` nicht mehr, das Plattform-Plugin registriert die Routen:
   gleicher Namensraum `wopcart/v1`, gleiche Pfade, gleiche Tabellen, gleiche geplante Aufgabe.
   Die Übergabe ist genau einen Aufruf breit.
4. **Danach prüfen:**
   - `POST /wp-json/wopcart/v1/plan/check` antwortet
   - `wp_wopcart_platform_sites` und `wp_wopcart_platform_deliveries` existieren, Zeilenzahl unverändert
   - geplante Aufgabe `wopcart_platform_deliver` ist eingeplant
   - Option `wopcart_platform_db_version` steht auf `1.0.0`
   - Option der erledigten Migrationen enthält `1.11.0-platform-tables`

**Umgekehrt niemals:** Kern zuerst, Plugin danach. Dazwischen liegt ein echter Ausfall der
Zahlungen aller Shops im kostenlosen Plan.

## Zusätzlich ab Kern 1.4.0: WopCart Direct auf wopcart.com

Ab 1.4.0 enthält der Kern keine Plan-Logik mehr. Niemand beantwortet dann noch die Frage,
ob ein Shop mit eigenen Zugangsdaten abrechnet — auch nicht für wopcart.com selbst. Der
eigene Stripe-Schlüssel des Shops würde also nicht mehr greifen.

Deshalb gehört **WopCart Direct auch auf wopcart.com**, so wie bei jedem Händler mit eigenen
Konten. Die Plattform bekommt damit keine Sonderregel im Kern, und das kostenlose Plugin
bleibt frei von jeder Tarif-Logik.

**Reihenfolge für das Update auf 1.4.0:**
1. WopCart Platform ist installiert (siehe oben) und der Kern ist auf 1.3.1
2. **WopCart Direct hochladen und aktivieren**, solange der Kern noch 1.3.1 ist. Direct
   erkennt den älteren Kern, entfernt dessen doppelte Abschnitte und Karten und arbeitet
   normal weiter.
3. Prüfen, dass die Zahlungsarten im Checkout erscheinen und der Stripe-Verbindungstest
   im Integrations-Bereich antwortet.
4. Erst danach den Kern auf 1.4.0 aktualisieren.
5. Danach prüfen: Checkout mit eigenem Stripe-Schlüssel, ein Testkauf, die Zahlungsarten
   in einem Zahlungsformular, und dass unter Einstellungen → Zahlungen jede Überschrift
   nur einmal vorkommt.

Ein Lizenzschlüssel ist dafür nicht nötig: Direct schaltet keine Funktion frei, der
Schlüssel sichert nur Updates und zählt Domains.

## Kundenshops

Brauchen keine Reihenfolge. Sie bekommen das Kern-Update, und die Migration entfernt beim
nächsten Aufruf zwei leere Tabellen und eine überflüssige geplante Aufgabe.

## Abhängigkeiten des Plattform-Plugins

Es setzt den Kern voraus (`Requires Plugins: wopcart`, mindestens 1.3.1) und ruft daraus
`Gateways\Connect`, `Gateways\Stripe::API_VERSION`, `Emails\Mailer`, mehrere `Licensing\*`
sowie `Platform\PlanVerdict` und `Platform\SiteToken` auf.

## Tests

```bash
cd /Users/cyrusbadde/projects/plugins/wopcart-platform
../digital-cart/vendor/bin/phpunit   # 53 Tests
../digital-cart/vendor/bin/phpcs
```

## Stand 2026-10-22: Schritt 2 erledigt

**Live vorgefunden:** Kern **1.2.3**, nur `wopcart/wopcart.php` aktiv, alle drei
Konstanten gesetzt (`WOPCART_PLATFORM_PRODUCT_ID = 14`, Stripe-Schlüssel und
Connect-Webhook-Secret vorhanden), `wopcart_platform_sites` mit 1 Zeile,
`wopcart_platform_deliveries` leer, PHP 8.3.33.

**Installiert:** WopCart Platform **1.0.2**, entpackt auf dem Host und per `docker cp`
in den Container (im Container gibt es kein `unzip`), dann über `activate_plugin()`
aktiviert. Es meldet wie vorgesehen:

> WopCart Platform needs WopCart 1.3.1 or newer.

Das ist der gewollte Ruhezustand: es registriert nichts, legt nichts an, und die beiden
Tabellen stehen unverändert bei 1 und 0 Zeilen. Danach geprüft: Startseite 200,
`/pricing/` 200, REST-Namensraum 200, `plan/check` antwortet weiter 400 (fehlende
Parameter, also lebt die Route im alten Kern), keine Fatals im Containerprotokoll.

### Beinahe-Ausfall, vorher abgefangen

Die Fassung 1.0.1 hätte beim Aktivieren **die gesamte Seite weiß gemacht**.
`Plugin::problem()` rief `\WopCart\Plugin::supports()` auf — eine Methode, die erst
Kern 1.3.0 mitbringt. Auf 1.2.3 existiert die Klasse, die Methode nicht, also wäre jeder
Aufruf ein Fatal Error gewesen, auch im wp-admin, von wo aus man es hätte rückgängig
machen müssen. Behoben in **1.0.2**: die Methode wird nur aufgerufen, wenn es sie gibt,
und ihr Fehlen bedeutet schlicht „zu alt". Dieselbe Stelle steckte in **WopCart Direct**
und ist dort in **1.0.1** behoben — `Requires Plugins: wopcart` schützt nicht davor, denn
es erzwingt die Anwesenheit des Kerns, nicht dessen Version.

### Nächste Schritte, unverändert in dieser Reihenfolge

1. Kern auf **1.3.1** (`wopcart-1.3.1.zip`) — ab dem nächsten Aufruf übernimmt das
   Plattform-Plugin die Routen.
2. **WopCart Direct 1.0.1** installieren und aktivieren, Checkout und Stripe-Test prüfen.
3. Kern auf **1.4.2** (`wopcart-1.4.2.zip`).
4. `06-connect-controller.php` kann weg, sobald Platform 1.0.1+ die Routen bedient.

## Rollout abgeschlossen: 2026-10-22

Alle drei Schritte in einem Durchgang, jeweils mit Prüfung dazwischen.

**Vorher gesichert:** vollständiger Datenbank-Dump (`/opt/wopcart/backups/pre-rollout-20261022-115627.sql.gz`,
885 kB) und das gesamte Plugin-Verzeichnis (`plugins-20261022-115627.tar.gz`, 1,7 MB).

| Schritt | Ergebnis |
|---|---|
| Kern 1.2.3 → **1.3.1** | `WopCart\Platform\Server` ausgezogen, Plattform-Plugin meldet „läuft", `plan/check` weiter da, Cron `wopcart_platform_deliver` eingeplant, Tabellen 1 / 0 unverändert |
| **WopCart Direct 1.0.1** installiert | aktiv, meldet „läuft", `wopcart_uses_own_gateway_credentials` = ja, eigener Stripe-Schlüssel für live und test vorhanden |
| Kern 1.3.1 → **1.4.2** | drei Plugins aktiv, `PlanVerdict` wie erwartet weg, alle Plattform-Routen da (`plan/check`, `platform/connect/start`, `/link`, `/status`, `/disconnect`, `platform/stripe`), 9 Bestellungen und 4 Lizenzen unberührt |

Die Reihenfolge hat sich bewährt: Direct war aktiv, **bevor** 1.4.2 die Tarif-Logik entfernt
hat, weshalb der eigene Stripe-Schlüssel des Shops durchgehend gegriffen hat.

**Rollback-Kopien** liegen im Container als `wopcart-prev` (1.3.1) und `wopcart-prev-131`
(1.2.3). Beim nächsten Deploy räumt `deploy-plugin.sh` sie nach `/opt/wopcart/rollback/`.

**Nach dem Deploy erledigt:**

- Update-Metadaten für Produkt 14 geschrieben (`META_ONLY=1 bash deploy-plugin.sh`),
  `_wopcart_software_version` steht auf 1.4.2.
- Käuferdatei ausgetauscht: `wopcart-protected/wopcart-1.4.2.zip`, Produkt 14 zeigt darauf.
- Website veröffentlicht (`push-pages.sh`): elf Seiten, Produktseite und Kopfmenü. Die
  Produktseite heißt jetzt **WopCart Direct**, Changelog trägt 1.4.1 und 1.4.2, die Roadmap
  den geklärten Stripe-Wortlaut.
- `05-design-pages.php` auf die aktuelle Fassung gebracht — die vom Vortag kannte FAQ,
  Lizenzseite und Produktseiten noch nicht, die drei standen deshalb kurz ohne Design da.
  Jetzt tragen alle zehn Seiten die Klasse `wc-design`.

**Offen:** Die SEO-Titel der Seiten stammen weiterhin aus dem Import vom September;
`push-pages.sh` schreibt nur den Inhalt, nicht die Angaben aus `manifest.json`.
`06-connect-controller.php` ist seit Platform 1.0.2 überflüssig, schadet aber nicht.
