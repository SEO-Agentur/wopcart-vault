# Rechtsschicht — was 1.14.0 bringt und was noch fehlt

**Stand:** 1. November 2026 · **Version:** 1.14.0, gebaut und geprüft, wartet auf Deploy

## Warum das zählt

Ein deutscher WooCommerce-Händler installiert Germanized. Easy Digital Downloads
hat davon nichts. Wenn WopCart das in der **freien** Version mitbringt, ist das
kein Pflichtprogramm, sondern das Verkaufsargument — und es passt zur Erzählung
für WordPress.org.

## Was jetzt drin ist

Alles in `src/Legal/`, alle Entscheidungen als reine Funktionen, alles
voreingestellt **aus**. Eigener Einstellungsreiter „Legal".

| Pflicht | Datei | Kernregel |
|---|---|---|
| Button-Lösung §312j(3) BGB | `PayButton` | `de`-Locale bekommt „Zahlungspflichtig bestellen", **nicht übersetzbar** |
| Versandhinweis PAngV §6 | `PriceNotice` | nur bei versandter Ware, verlinkt die Kostenseite |
| Lieferzeit | `DeliveryTime` | je Produkt, Shop-Vorgabe als Rückfall, nie bei Downloads |
| Grundpreis PAngV §4 | `UnitPriceAuto` | aus dem Gewicht abgeleitet, Handeingabe gewinnt |
| Kleinunternehmer §19 UStG | `BusinessNotes` + `Legal` | setzt den **Satz** auf 0, nicht nur die Beschriftung |
| Verpackungsregister VerpackG §9 | `BusinessNotes` | LUCID-Nummer auf Rechnung und im Shortcode |
| Streitschlichtung VSBG §36 | `BusinessNotes` | vier Haltungen, „verpflichtet" fällt ohne Stelle zurück |
| Produktsicherheit (EU) 2023/988 | `Gpsr` | Hersteller ausserhalb der EU ohne Verantwortlichen darin = abgelehnt |

## Drei Entscheidungen, die ich erklären muss

**Die Button-Beschriftung ist absichtlich nicht übersetzbar.** Sie ist eine
Rechtsformel in einer Sprache. Durch gettext geschickt könnte eine
Übersetzungsdatei genau die Worte ersetzen, die das Gesetz nennt. Vorher hing
das an einem Kommentar an den Übersetzer — und WopCart liefert keine deutsche
Übersetzung mit, ein deutscher Shop hatte also keine bindenden Verträge.

**Kleinunternehmer greift in den Steuersatz, nicht in die Anzeige.** §14c UStG
macht ausgewiesene Steuer zahlbar, auch wenn sie nicht geschuldet war. Eine
reine Anzeigeoption wäre schlimmer als gar keine.

**Ob der Hersteller ausserhalb der EU sitzt, beantwortet der Shop.** Nicht aus
der Adresse geraten: Adressen sind Freitext in jeder Sprache, und ein Rateschluss
würde entweder rechtmässige Angebote blockieren oder unrechtmässige durchwinken.

## Eine Korrektur zur Aufgabenstellung

Die **EU-ODR-Plattform wurde am 20. Juli 2025 abgeschaltet**. Die Pflicht, sie zu
verlinken, ist damit entfallen, und ein Shop, der den Link noch führt, schickt
Kunden auf eine tote Seite. Geblieben ist die Erklärung nach VSBG §36 — die ist
gebaut, der Link ist es bewusst nicht.

## Einordnung: was davon betrifft wopcart.com selbst

Fast nichts. Lieferzeit, Grundpreis, Verpackungsgesetz und GPSR gelten
**physischer Ware**. Für digitale Lizenzen zählen AGB-Checkbox und
Widerrufsverzicht — beide waren schon vorher da — und die Button-Lösung, falls
die Seite je auf Deutsch erscheint.

## Was noch fehlt

- **Widerrufsfunktion nach EU 2023/2673** (der Widerrufsbutton) — eigene Story,
  nicht in 1.14.0
- **Rechtstexte in E-Mails, Differenzbesteuerung, Gebrauchtware** — eigene Story
- **Altersprüfung** — nicht vorhanden, bisher nirgends als Aufgabe erfasst
- Der GPSR-Block steht auf der Produktseite; **in Beleg und Rechnung** wandert er
  noch nicht mit

## Geprüft

1848 Tests OK (14 neue, jeder nach dem Fehler benannt, den er verhindert) ·
5746 statische Referenzen ohne Lücke · phpcs auf allen neuen Dateien 0 Fehler,
auf den berührten auf der Grundlinie · Grundpreis-Arithmetik gegengerechnet:
3,99 € für 500 g ergibt 7,98 €/kg.
