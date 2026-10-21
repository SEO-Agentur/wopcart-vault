# Seiten-Redesign: Inhaltsseiten ins Markendesign

**Stand:** 2026-10-21 · **Verwandt:** [[Components/Editions]] · [[Deployment/wopcart.com]] · [[Planning/Roadmap-Status]]

## Ziel-Zustand

Die sieben Inhaltsseiten von wopcart.com erscheinen im selben Design wie Startseite,
Changelog und Roadmap, führen die beiden Editionen richtig und sind über ein
Dropdown-Menü erreichbar.

## Weg dahin

### Befund

`/pricing/`, `/docs/`, `/integrations/`, `/why-wopcart/`, `/support/`, `/eu-vat/` und
`/plan-changes-refunds/` lieferten HTTP 200, enthielten aber **keine einzige
`wc-`Klasse** im Inhalt — nur Kopf und Fuß der Website waren gestaltet, der Rumpf war
nackter Gutenberg-Standard. Changelog und Roadmap nutzen dagegen das vollständige
Vokabular. Dazu kam, dass die Texte vom 14.09. stammten und die Aufteilung in Editionen
noch nicht kannten.

### Design

Alle sieben Seiten sind in der Blockauszeichnung von `changelog.html` neu geschrieben,
mit `wc-page-hero`, `wc-section` / `wc-section--white`, `wc-section-head`, `wc-cards`
(`--2`, `--4`), `wc-card` (`--mint`, `--teal`, `--slate`), `wc-checklist`, `wc-ticks`,
`wc-release` als Schritt- und Themenraster, `wc-note` und `wc-final`. Geprüft gegen die
89 Klassen des Live-Stylesheets: keine erfundene Klasse, alle Blockkommentare paarig.

Nicht verwendet sind `wc-price-card`, `wc-compare-table`, `wc-feature` und `wc-quote` —
diese Regeln sind im Stylesheet auf `.home` beschränkt und wirken auf Unterseiten nicht.
Deshalb stehen Preise und Vergleiche in Karten statt in Tabellen, was auf dem Telefon
ohnehin besser liest.

### Inhaltliche Korrekturen

| Seite | Was falsch war | Jetzt |
|---|---|---|
| alle | „Free plan / paid plans", „Plan key" | **WopCart** (kostenlos, 2 %) und **WopCart Direct** (Add-on, 0 %), ein Lizenzschlüssel nur im Add-on |
| `/why-wopcart/` | „Physical product shipping: not available", „digital products only" | Physische Produkte sind enthalten; offen sind nur Carrier-Anbindungen DHL/UPS/FedEx |
| `/integrations/` | Mollie fehlte in der Gateway-Liste | Mollie unter den eigenen Zugängen von Direct |
| `/docs/` | Schritt 8 „Add your plan key" | Schritt 8 installiert das Add-on und aktiviert dessen Lizenz; Versandhinweis in Schritt 4 |
| `/pricing/` | Lizenzschlüssel auch für die kostenlose Version | kostenlose Version verlangt keinen Schlüssel |
| `/support/`, `/plan-changes-refunds/` | „plan", „plan key" | „licence", „licence key", Rückfall auf die 2-%-Abrechnung benannt |

Lifetime bleibt unverändert: einmal zahlen, keine Verlängerung, Updates solange WopCart
angeboten wird. Die am 2026-10-21 erwogene Beschränkung auf die gekaufte Version wurde
verworfen (siehe [[05 Decisions Log]]).

### Design-Klasse

Das Stylesheet hängt an `body.wc-design`, gesetzt von `mu-plugins/04-site-design.php` für
die Seiten des September-Redesigns. Statt dessen Logik zu erraten, liegt in
`Deployment/mu-plugins/05-design-pages.php` ein **zweites mu-plugin** mit einem eigenen
`body_class`-Filter für die sieben Slugs. Ein Filter fügt nur hinzu, beide laufen
nebeneinander, und das Entfernen der einen Datei nimmt die Änderung vollständig zurück.

### Menü

`Website/parts/header.html` hat jetzt zwei Dropdowns:

- **Docs**: Getting started, Software licensing, Paywall and memberships, EU VAT, Integrations, FAQ
- **Help**: Support, Why WopCart, Changes domains and refunds, Changelog, Roadmap

Dazu zwei Änderungen am Bestand: „Features" zeigt auf `/features/` statt auf den Anker
`/#features`, der Knopf „Get WopCart" auf `/pricing/` statt `/#pricing`. Der Punkt
„Checkout" (`/#checkout`) ist entfallen, weil er nur einen Abschnitt der Startseite
ansprang und die Leiste mit zwei Dropdowns sonst zu voll wird.

## Veröffentlichen

```
bash Deployment/scripts/push-pages.sh                    # sieben Seiten + Menü
bash Deployment/scripts/push-pages.sh pricing docs       # einzelne Seiten
```

Vorher einmalig `05-design-pages.php` einhängen, sonst erscheinen die Seiten weiter
ungestaltet:

```
scp -i ~/.ssh/seowebsitesbuilder_vps Deployment/mu-plugins/05-design-pages.php \
    root@187.77.74.66:/opt/wopcart/mu-plugins/
ssh -i ~/.ssh/seowebsitesbuilder_vps root@187.77.74.66 \
    'docker cp /opt/wopcart/mu-plugins/05-design-pages.php wopcart-web:/var/www/html/wp-content/mu-plugins/ && docker exec wopcart-web chown www-data:www-data /var/www/html/wp-content/mu-plugins/05-design-pages.php'
```

Die Mount-Zeile für die Datei gehört beim nächsten gewollten Recreate in
`docker-compose.yml`, wie schon bei `04-site-design.php` vermerkt. Ohne Mount überlebt
sie einen Recreate nicht.

`push-pages.sh` legt von jeder ersetzten Seite `/tmp/wc-pages/<slug>.bak.html` im
Container an und prüft am Ende jede URL. Örtliche Sicherungen: `*.html.bak-20261021`
in `Website/pages` und `Website/parts`.

## Offen

- `/direct/` existiert noch nicht; die Kaufknöpfe der Preisseite zeigen dorthin (Story 4).
- `/pro/` soll auf `/direct/` weiterleiten.
- `manifest.json` trägt für die sieben Seiten jetzt `design: true` und aktualisierte
  SEO-Texte. Der Importlauf selbst ist nicht nötig, `push-pages.sh` genügt.

## Zweiter Durchgang, 2026-10-21 nachmittags

Nach einer Durchsicht durch den Nutzer kamen dazu:

- **`/faq/` und `/software-licensing/`** im Markendesign neu geschrieben. Die FAQ ist nach
  Themen in Karten geordnet (Gebühren und Editionen, Lizenzen und Domains, Zahlungen und
  Produkte, Daten und Datenschutz), die Lizenzseite hat Schrittliste, Karten, ein
  Code-Beispiel für den Updater und drei Fragen.
  Dabei korrigiert: die FAQ behauptete noch „WopCart is built for digital products and has
  no shipping features" — derselbe Fehler wie auf `/why-wopcart/`.
- **Produktseite** (`product-wopcart.html`, Beitrag 14): verkaufte noch den „WopCart Plan"
  mit Plan-Schlüssel und dem Satz „no second plugin to install". Jetzt verkauft sie
  **WopCart Direct**, im Design, mit den drei Größen, der Domainzählung und dem Kleingedruckten.
  Der Beitragstitel wandert von „WopCart" auf „WopCart Direct"; dafür trägt die Datei in
  der ersten Zeile eine Direktive `<!-- wc:title WopCart Direct -->`, die `push-pages.php`
  ausliest.
- **Roadmap**: „Free plan via Stripe Connect" unter *In progress* las sich so, als seien
  Stripe-Zahlungen noch nicht fertig. Jetzt steht unter *Shipped* „Stripe checkout and
  Apple Pay, live and in use" samt WopCart Direct, und unter *In progress* die Abrechnung
  über Connect mit dem ausdrücklichen Hinweis, dass die Zahlungen selbst längst laufen.
  Dazu die Verzeichnis-Aufnahme bei WordPress.org.
- **Changelog**: Eintrag 1.4.1 ergänzt, und die vier Platzhalter `RELEASE_DATE` (1.2.4,
  1.3.0, 1.3.1, 1.4.0) auf den 21. Oktober 2026 gesetzt, weil alle vier mit diesem Rollout
  live gehen. Verschiebt sich der Rollout, einmal `sed -i '' 's/21 October 2026/…/'`.
- **`05-design-pages.php`** deckt jetzt auch `faq`, `software-licensing` und alle
  Produktseiten samt Produktarchiv ab.
- **`push-pages.sh`** kennt Produkte (`product:wopcart`) und Titel-Direktiven; die
  Standardliste umfasst alle elf Seiten, das Produkt und das Menü.

Nicht angefasst, weil nicht benannt: `/features/` und `/paywall-memberships/` tragen
weiterhin kein Design, obwohl das Docs-Menü auf sie zeigt.
