# WordPress.org-Launch: Aufteilung in zwei Editionen

**Typ:** Epic-Designdokument · **Stand:** 2026-09-23 · **Asana:** `[EPIC] WordPress.org-Launch`
**Verwandt:** [[Components/Editions]] · [[Components/Monetisation]] · [[Planning/Roadmap-Status]] · [[Security/2026-09-17-Code-Qualitaet]]

## Ziel

WopCart liegt im WordPress.org-Verzeichnis, wird dort ohne Nachforderung angenommen und
bleibt annehmbar. Zahlende Kunden verlieren dabei zu keinem Zeitpunkt ihre eigenen
Zahlungszugänge.

## Warum überhaupt etwas ändern

Das Verzeichnis verbietet Funktionen, die im ausgelieferten Code liegen und erst durch
Bezahlung freigeschaltet werden. Genau das ist heute der Fall: PayPal, Authorize.net,
Mollie und 2Checkout sind vollständig enthalten und werden über den Plan-Schlüssel
freigeschaltet. Dazu kommen zwei kleinere Angriffsflächen: der Server-Code von
wopcart.com liegt in jedem Kundenshop, und der mitgelieferte Updater hakte sich in die
Update-Mechanik von WordPress (bereits aus dem Paket entfernt, Version 1.2.4).

Das Geschäftsmodell selbst ist erlaubt. Abrechnung über die eigene Stripe-Connect-Plattform
mit 2 % ist ein Dienst, kein gesperrtes Feature. Es muss nur offengelegt sein, und das ist
es seit 1.2.4 im readme-Abschnitt „External services“.

## Entscheidung

Zwei Editionen, Variante A (Add-on, nicht zwei vollständige Plugins):

| | **WopCart** | **WopCart Direct** | **WopCart Platform** |
|---|---|---|---|
| Vertrieb | WordPress.org | wopcart.com | nicht öffentlich |
| Zweck | vollständiger Shop, Abrechnung über die Plattform (2 %) | eigene Gateway-Zugänge, 0 % | Server-Seite von wopcart.com |
| Voraussetzung | – | WopCart ab 1.3.0 | WopCart |

Begründung für das Add-on statt zweier Plugins: Kunden tauschen beim Kauf nichts aus,
Fehlerkorrekturen wirken für beide Gruppen sofort, und die Updates des Hauptplugins laufen
über WordPress.org. Details und Abwägung in [[Components/Editions]].

## Befund der Bestandsaufnahme (2026-09-18)

Die Aufteilung hängt an **einer** Stelle: alles Plan-Abhängige läuft über den Filter
`wopcart_is_paid_plan` (`src/Gateways/Connect.php:107`), beantwortet von
`src/Platform/Plan.php`. Es gibt keine zweite Prüfstelle und keine verstreuten
Lizenzabfragen. `src/Licensing/*` ist davon unberührt: das ist die Lizenzierung, die
Händler ihren eigenen Kunden gegenüber betreiben.

Was wandert:
- **ins Add-on:** `Gateways/PayPal.php`, `AuthorizeNet.php`, `TwoCheckout.php`,
  `Mollie.php` + `Gateways/Mollie/*` (≈5.530 Zeilen), die vier Zugangs-Abschnitte in
  `Admin/Settings.php`, die Eigenschlüssel-Karte in `Admin/Integrations.php`
- **entfällt ersatzlos:** `Platform/Plan.php`, `Platform/PlanVerdict.php` (≈750 Zeilen),
  das Plan-Feld, die Plan-Karte und die Plan-Endpunkte auf wopcart.com. Direct trägt
  stattdessen seine eigene Produktlizenz, ausgestellt von wopcart.com mit WopCart selbst
  (`src/Licensing`). Siehe [[Components/Editions]], Abschnitt „Lizenzschlüssel“.
- **ins Plattform-Plugin:** `Platform/Server.php`, `Platform/ConnectServer.php`,
  `Platform/ProxyPolicy.php`, `Connect::platform_is_live()`,
  `Connect::connect_webhook_secret()`, die Tabellen `platform_sites` und
  `platform_deliveries`
- **bleibt:** `Platform/ConnectClient.php` (Händlerseite des kostenlosen Plans),
  `Platform/SiteToken.php` (beide Seiten brauchen ihn), Stripe und Apple Pay

## Reihenfolge (nichts wird zu früh gelöscht)

1. **Erweiterungspunkte einbauen**, Verhalten unverändert → Release 1.3.0
2. **Plattform-Plugin abtrennen** (Server-Code und die zwei Tabellen)
3. **WopCart Direct bauen** gegen 1.3.0; beide Plugins enthalten die Gateways parallel
4. **Direct veröffentlichen**, bestehende Kunden umziehen, eine Release-Runde warten
5. **Bezahl-Code aus der kostenlosen Version entfernen** → Release 1.4.0
6. **Einreichen** bei WordPress.org

Schritt 5 ist der einzige, der einen zahlenden Kunden stranden lassen kann. Deshalb die
Wartezeit in Schritt 4 und der Regressionstest, der fehlschlägt, sobald der bezahlte Code
verschwindet, solange die Haken dafür fehlen.

## Risiken und Gegenmaßnahmen

- **Deinstallation löscht fremde Daten:** `uninstall.php` löscht alles mit Präfix
  `wopcart_`, also auch die Zugangsschlüssel in `wopcart_gateway_secrets`, für die Kunden
  bezahlt haben. → Add-on benutzt ein eigenes Präfix, Löschregel wird eingegrenzt.
- **Ältere Add-on-Version trifft neuere Hauptversion:** Ein entfernter Filter würde stumm
  dazu führen, dass Zahlungen wieder 2 % kosten. → Die Filter gelten als eingefrorene
  Schnittstelle; zusätzlich eine `EXTENSION_API_VERSION` und ein Hinweis statt Abschaltung.
  Grundsatz aus dem Bestandscode: **im Zweifel offen scheitern**, nie dem Zahlenden die
  eigenen Zugänge nehmen.
- **Reihenfolge der Aktivierung:** Das Add-on prüft `\WopCart\VERSION` und registriert
  seine Filter auf Dateiebene, nicht in `plugins_loaded`, sonst greift
  `wopcart_secret_setting_keys` zu spät und Secrets werden im falschen Speicher gesucht.

## Abnahmekriterien

- Plugin Check gegen das Release-Paket: keine echten Fehler (aktuell 4 erklärbare).
- Kein Vorkommen von `Platform\Plan`, `is_paid_plan`, `requires_paid_plan` oder den vier
  Gateway-Klassen im kostenlosen Paket; ein Test hält das fest.
- Paket enthält kein `client/`, kein `sdk/`, keinen Server-Code, keine ungenutzten Tabellen.
- Ein Shop mit bestehendem Plan-Schlüssel behält nach Update und Add-on-Installation seine
  Zugänge, ohne etwas neu einzugeben.
- readme ohne Preise, Tarifvergleiche und Wettbewerbernennung; „External services“ vollständig.

## Offen (Entscheidungen des Inhabers)

- Sechs Screenshots plus Icon und Banner für die Verzeichnis-Listung.
- `Contributors` muss ein echtes WordPress.org-Konto sein.
