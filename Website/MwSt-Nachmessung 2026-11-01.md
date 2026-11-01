# MwSt: Anzeige und Berechnung, nachgemessen

**Datum:** 2026-11-01 · **Stand:** WopCart 1.8.5 live · **Methode:** read-only Proben im Container `wopcart-web`, plus Browser gegen https://wopcart.com

## Anlass

Der Express-Checkout zeigte `$50.00` ohne Zusatz, während Zusammenfassung und
Kaufknopf `$59.00 incl. VAT` sagten. Ursache: das Panel druckte den eingegebenen
Betrag statt ihn durch `DisplayPolicy::present()` zu schicken. Behoben in 1.8.5.

## Anzeige-Modus

Am 2026-11-01 vormittags stand `price_display_mode` auf `auto`, am Nachmittag auf
`net`. Der Eigentümer hat das im Backend umgestellt ("Preis ohne MwSt. zeigen"),
bestätigt am 2026-11-01 — kein Deploy-Nebeneffekt, `push-site.sh` schreibt nur
`express_product`.

`net` ist für diesen Shop die passende Wahl: der Verkehr ist überwiegend
außerhalb Maltas, und `net` zeigt jedem denselben Nettopreis, statt bis zur
Länderwahl 18 % maltesische MwSt. anzunehmen.

Der Fix ist modus-unabhängig, weil er die Richtlinie fragt:

| Modus | Dropdown | Zusammenfassung |
|---|---|---|
| `auto` | `$59.00 incl. VAT` | `$59.00 incl. VAT` |
| `net` | `$50.00 excl. VAT` | Subtotal `$50.00` · VAT 18 % `$9.00` · Total `$59.00` |

Nebeneffekt: der Lifetime-Zuschlag für eine Site ist in `net` wieder `+$30.00`,
in `auto` waren es `+$35.40` (MwSt. auf die Differenz).

## Was tatsächlich berechnet wird

Auf `$50.00` netto, Produkt 14, Steuerklasse `digital`:

| Käufer | Satz | Zahlt |
|---|---|---|
| Malta (Shop-Land) | 18 % | $59.00 |
| Deutschland | 19 % | $59.50 |
| Frankreich | 20 % | $60.00 |
| Ungarn | 27 % | $63.50 |
| USA / Schweiz / UK / Australien | 0 % | $50.00 |
| DE Firma, USt-ID per VIES geprüft | 0 % | $50.00 (Reverse Charge) |
| DE Firma, USt-ID ungeprüft | 19 % | $59.50 |
| MT Firma, USt-ID geprüft | 18 % | $59.00 (inländisches B2B, kein Reverse Charge) |

Also: kein EU-VAT außerhalb der EU, Landessatz innerhalb, Reverse Charge nur
innergemeinschaftlich und nur nach geprüfter USt-ID.

## Offen

- **Nur relevant, falls je auf `auto` zurückgestellt wird: `auto` kennt das Land
  erst nach der Länderwahl.** Ohne Treffer in der Kette
  (Kundenkonto → Warenkorb → `CF-IPCountry` → Shop-Land) fällt die Anzeige auf
  Malta mit 18 % zurück. wopcart.com liegt hinter Cloudflare (`cf-ray` vorhanden),
  ob der Header am Origin ankommt, ist **nicht** verifiziert — hängt an der
  Cloudflare-Einstellung für Besucher-Standort-Header. Im Modus `net` irrelevant,
  weil die Anzeige dort besucherunabhängig ist.
- Ein Fehlalarm aus der ersten Messung: Reverse Charge schien zu versagen. Der
  Aufbau war falsch — `TaxContext` nimmt an dritter Stelle die PLZ, die USt-ID
  erst an vierter. Korrekt gemessen stimmt es.
