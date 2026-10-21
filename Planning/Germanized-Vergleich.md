# Was von Germanized für WopCart taugt

**Stand:** 2026-10-21 · **Verwandt:** [[Components/VAT and Currency]] · [[Planning/Roadmap-Status]] · [[Components/Editions]]

Germanized ist die Rechts- und DACH-Schicht für WooCommerce. Die Liste unten ist deren
Funktionsumfang, abgeglichen mit dem, was WopCart 1.4.2 wirklich kann. Entscheidend ist
nicht Vollständigkeit, sondern: **Was verhindert heute einen Verkauf in Deutschland?**

## Schon drin

| Germanized | In WopCart |
|---|---|
| OSS-Konformität | Umsatzsteuer je Käuferland, VIES, Reverse Charge, Bericht je Land für die OSS-Meldung |
| USt-IdNr.-Prüfung (Pro) | VIES-Prüfung im Checkout, abschaltbar |
| Steuer auf Versandkosten | `src/Shipping/ShippingTax.php`, getrennte Berechnung |
| Grundpreise | Pro Produkt, „€3,90 / kg" neben dem Preis |
| Preisanzeige netto/brutto | Automatisch brutto für EU-Besucher, Beschriftungen frei wählbar |
| Widerruf bei digitalen Inhalten | Zustimmung im Checkout, Zeitpunkt wird zur Bestellung gespeichert |
| AGB-Checkbox | `require_terms`, mit AGB-Seite in den Einstellungen |
| Rechnungen | Fortlaufende Nummern je Serie, Snapshot zum Verkaufszeitpunkt, Stornorechnung bei Erstattung, PDF |
| DSGVO Export/Löschung | An den Datenschutz-Werkzeugen von WordPress, Löschung anonymisiert und behält Steuerunterlagen |
| WPML | Plus Polylang |
| REST-API | Eigene API mit gehashten Schlüsseln |
| Rückerstattungsanfragen | Kunde beantragt, Admin genehmigt, Auto-Genehmigung möglich |

## Lohnt sich, in dieser Reihenfolge

**1. Lieferzeiten** — fehlt ganz. In Deutschland eine Pflichtangabe bei physischen Waren,
und WopCart verkauft sie seit Welle 3. Pro Produkt, Vorgabe im Shop, optional je Land,
Anzeige auf Produktseite, im Warenkorb und in der Bestellbestätigung. Klein.

**2. GPSR: Herstellerangaben und Sicherheitshinweise** — fehlt ganz. Seit dem 13.12.2024
EU-weit Pflicht für Produkte an Verbraucher: Hersteller oder verantwortliche Person in der
EU mit Anschrift, Warnhinweise, Sicherheitsunterlagen. Ohne das darf streng genommen keine
physische Ware an EU-Verbraucher verkauft werden. Felder am Produkt, Ausgabe auf der
Produktseite und in der Bestellbestätigung. Mittel.

**3. Widerrufsbutton nach EU 2023/2673** — fehlt. Für online geschlossene Verträge mit
EU-Verbrauchern verlangt die Richtlinie eine Widerrufsfunktion, die genauso leicht
erreichbar ist wie der Kauf. Die halbe Arbeit ist getan: Rückerstattungsanfragen gibt es
schon, es fehlen das Formular ohne Anmeldung, die Bestätigung in Textform und die
Verknüpfung mit der Bestellung. Mittel, hoher Pflichtwert.

**4. Kleinunternehmerregelung § 19 UStG** — fehlt. Ein Schalter: keine Umsatzsteuer
ausweisen, stattdessen der Hinweis auf § 19 auf Rechnung, im Checkout und in der
Bestätigung. Für Einzelverkäufer in Deutschland der häufigste Grund, ein Plugin nicht
nehmen zu können. Klein, großer Effekt.

**5. Hinweis „zzgl. Versand" neben dem Preis** — halb da. Die Umsatzsteuer-Beschriftung
gibt es, der Versandhinweis mit Verweis auf die Versandseite fehlt. Bei physischen Waren
in Deutschland Pflicht. Klein.

**6. Button-Lösung** — zu prüfen und festzuzurren. Der Kaufknopf muss in Deutschland
„Zahlungspflichtig bestellen" heißen. Heute kommt die Beschriftung aus der Übersetzung;
sie gehört als eigene Einstellung oder zumindest als Filter abgesichert, damit ein Theme
sie nicht überschreibt. Sehr klein.

**7. Rechtstexte in E-Mails** — fehlt. AGB und Widerrufsbelehrung als Text an die
Bestellbestätigung anhängen, aus den gewählten Seiten erzeugt. Klein bis mittel.

**8. Differenzbesteuerung § 25a und Gebrauchtwaren** — fehlt. Kennzeichnung am Produkt,
Hinweis auf Rechnung und im Checkout, dazu ein Feld für die Mängelbeschreibung bei
gebrauchter Ware. Nur für Händler mit Gebrauchtware relevant, aber für die zwingend.
Mittel.

## Später, wenn die Nachfrage kommt

- **Trusted Shops** — passt in den Integrations-Hub, kein Kernthema.
- **SEPA-Lastschrift** und **Kauf auf Rechnung** — SEPA steht schon als C3 auf der
  Roadmap (über Stripe). Kauf auf Rechnung heißt Bonitätsrisiko und Mahnwesen; das Mahnwesen
  für Abos gibt es bereits, der Rest ist eine eigene Entscheidung.
- **Produkt-CSV Import/Export** — der Importer aus EDD/Woo/Gumroad steht als B6.
- **Mehrstufiger Checkout** — reine Oberfläche, kein Recht. Erst messen, ob der einseitige
  Checkout wirklich abbricht.
- **Streichpreis-Beschriftungen** — hängt an D2 (Sale-Preis mit Zeitraum).

## Nicht nachbauen

- **Lebensmittel mit Nutri-Score, Nährwerten, Pfandflaschen** — eigener Produktbereich,
  weit weg von digitalen Gütern und Lizenzen.
- **Photovoltaik mit Nullsteuersatz** — die Steuerklasse „keine Steuer" deckt den Fall
  notdürftig ab; eine eigene Mechanik lohnt für eine Handvoll Händler nicht.
- **Verzögerter Vertragsschluss** — B2B-Sonderfall, den fast niemand einschaltet.
- **Double-Opt-in bei der Registrierung** — die Anbindungen an Brevo, Mailchimp und
  FluentCRM machen DOI bereits dort, wo es rechtlich zählt: beim Newsletter.
- **Eigene Rechnungs-PDF-Automatik im Pro-Umfang** — gibt es schon, inklusive
  InvoicesGenerator als Ausgabeweg; E-Rechnung XRechnung/ZUGFeRD steht als E3 auf der Roadmap.

## Warum das strategisch zählt

Easy Digital Downloads hat davon **nichts**, WooCommerce braucht dafür ein zweites Plugin.
Die Punkte 1 bis 6 sind zusammen vielleicht zwei Wochen Arbeit und machen WopCart zum
einzigen Warenkorb, der aus dem Karton heraus in Deutschland verkaufsfähig ist — und zwar
in der **kostenlosen** Version, was zur Erzählung für WordPress.org passt.
