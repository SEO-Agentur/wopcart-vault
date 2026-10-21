# SEO: Produktseiten, Schema und die vier SEO-Plugins

**Stand:** 2026-10-21 · **Verwandt:** [[Components/Editions]] · [[Website/Seiten-Redesign 2026-10-21]]

## Produktseiten lassen sich mit dem Plugin bauen

`wopcart_product` ist ein **öffentlicher Beitragstyp** mit `public`, `show_in_rest`,
`has_archive` und den Fähigkeiten `title`, `editor`, `excerpt`, `thumbnail`, `author`,
`revisions`, `custom-fields`, `page-attributes`. Daraus folgt alles Weitere:

- Der Blockeditor bearbeitet Produktseiten wie Seiten, inklusive aller Blöcke.
- `src/Frontend/ProductBlockTemplate.php` liefert bei Blockthemen ein eigenes
  `single-wopcart_product`-Template. Ohne das würde ein Blockthema Produkte mit seinem
  Beitrags-Template zeigen, also mit Autorenzeile, Schlagwörtern und Kommentaren.
  Ein im Website-Editor gespeichertes Template und eine Theme-Datei
  `templates/single-wopcart_product.html` haben Vorrang.
- Kaufbox, Bundle-Inhalt und Bewertungen hängen sich per `the_content` an, erscheinen also
  automatisch unter dem Inhalt.
- Klassische Themen bleiben unberührt; Vorlagen aus `templates/` lassen sich nach
  `yourtheme/wopcart/` kopieren.

## Alle vier SEO-Plugins sind angebunden

| Plugin | Erkennung | Schema-Filter |
|---|---|---|
| Yoast SEO | `WPSEO_VERSION` | `wpseo_schema_graph` |
| Rank Math | Klasse `RankMath` | `rank_math/json_ld` |
| All in One SEO | Funktion `aioseo()` | `aioseo_schema_output` |
| Seooptimierung Toolkit | `Seooptimierung\Toolkit\VERSION`, vor 1.7 `SeoWp\VERSION` | `seooptimierung/schema/graph`, dazu `seo_wp/schema/graph` |

Was WopCart dabei tut, in allen vier Fällen gleich:

- **Produkt-, Bewertungs- und Paywall-Schema** wandern in den Graph des SEO-Plugins,
  statt einen zweiten daneben zu drucken. Ohne SEO-Plugin druckt WopCart selbst.
- **Beschreibungen werden abgesichert:** kein gesperrter Text in Meta-Beschreibungen,
  Open-Graph- oder Twitter-Angaben.
- **Systemseiten** (Warenkorb, Checkout, Bestätigung, Konto) gehen auf `noindex` und raus
  aus der Sitemap des SEO-Plugins.
- **Brotkrumen-Schema** druckt WopCart nur, wenn keines der vier aktiv ist, sonst doppelt
  es sich. Schalter: `wopcart_print_breadcrumb_schema`.

Titel, Meta-Beschreibung, Canonical und Social-Vorschau setzt man wie bei jeder Seite im
Kasten des SEO-Plugins — dafür braucht WopCart keinen eigenen Code, das erledigt der
öffentliche Beitragstyp.

## Der Fehler in 1.4.0 und früher — behoben in 1.4.1

Das Toolkit hieß bis Version 1.7 **SEO-WP** und hat sich beim Umbenennen mitgenommen:
Namensraum `SeoWp` → `Seooptimierung\Toolkit`, Filterpräfix `seo_wp/` →
`seooptimierung/`. WopCart suchte weiter die alten Namen, also war die Anbindung auf
jeder aktuellen Installation **stillschweigend tot**: kein Produkt-Schema im Graph, keine
abgesicherten Beschreibungen, Systemseiten in der Sitemap, Brotkrumen doppelt.

Behoben in 1.4.1: beide Präfixe werden gehakt, beide Konstanten gelten als aktiv (ein
Filter auf einen Haken, der nie feuert, kostet nichts), `seo_wp_active()` bleibt als
veralteter Alias von `seooptimierung_active()`. Abgedeckt von fünf Tests in
`tests/Unit/SeooptimierungToolkitIntegrationTest.php`, einer davon ausdrücklich für die
alte Konstante.

**Lehre:** Die Anbindung hing an Namen eines fremden Plugins, ohne dass irgendetwas
gemeldet hätte, dass sie nicht mehr greifen. Für die anderen drei gilt dasselbe Risiko.
Ein Prüfpunkt im Integrations-Bereich, der „erkannt / nicht erkannt" pro SEO-Plugin
anzeigt, würde so etwas sichtbar machen — steht als Vorschlag in Asana.

## Offen

- Das Produkt-**Archiv** `/products/` zeigt bei Blockthemen den vollen Inhalt jedes
  Produkts, weil es das Archiv-Template des Themes benutzt. Ein eigenes
  `archive-wopcart_product`-Template mit Produktraster fehlt (UX und doppelter Inhalt).
- Für die Frage-Antwort-Abschnitte der Website gibt es kein `FAQPage`-Markup.
