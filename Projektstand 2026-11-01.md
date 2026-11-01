# WopCart — Stand am 1. November 2026

Geschrieben am Ende eines langen Arbeitstages. Alles hier ist gemessen, nicht
erinnert; wo etwas ungeprüft ist, steht es dabei.

## Ausgeliefert heute: 1.8.5 bis 1.12.4

| Version | Was | Live |
|---|---|---|
| 1.8.5 | Express-Checkout zeigte Preise ohne MwSt., Zusammenfassung mit | ja |
| 1.8.6 | **Checkout bot nur 41 Länder und verlangte eines davon** | ja |
| 1.9.0 | Bewertungen nach dem Kauf, Logout-Link für Menüs | ja |
| 1.10.0 | Conversion-Tracking: Klick-IDs und neun Plattformen | ja |
| 1.11.0 | Upgrades und Tarifwechsel abgeschafft | ja |
| 1.12.0 | Anmeldung mit Google und LinkedIn | ja |
| 1.12.1 | Anmelde-Einstellungen von Marketing nach General | ja |
| 1.12.2 | Versandtabelle eingefasst — **wirkte nicht** | ja |
| 1.12.3 | Versandtabelle wirklich eingefasst, gemessen | **offen** |
| 1.12.4 | Anmeldung bekommt eigenen Reiter | **offen** |

Ausrollen: `deploy-plugin.sh`, danach `push-site.sh`.

## Was heute schiefging und was daraus folgt

**1.12.2 behauptete einen Fix, den ich nicht gemessen hatte.** Der Rahmen um die
Versandtabelle war da, `overflow-x: auto` stand drin, und die Seite lief
trotzdem über: `max-width: 100%` rechnete gegen eine Tabellenzelle, die selbst
schon auf Inhaltsbreite gewachsen war. Zwei Vorfahren mussten erst erfahren,
dass sie schmaler sein dürfen als ihr Inhalt — ein `fieldset` trägt
`min-width: min-content` aus dem Browser-Stylesheet, und eine Tabelle ohne
`table-layout: fixed` bemisst ihre Spalten am Inhalt. Gemessen bei 514 px
Fensterbreite: Seite 1144 px vorher, 514 px nachher.

Lehre, die über diesen Fall hinausgeht: eine Behauptung ohne Messung ist bei
Layout genauso wertlos wie bei Preisen.

**Handgepflegte Listen driften.** Zwei Fälle am selben Tag:
- Die Länderliste im Checkout (41 statt 249 — Pflichtfeld, also konnten rund
  200 Länder nicht kaufen).
- `push-pages.sh` hatte eine Seitenliste im Skript; `paywall-memberships`,
  `features`, `home`, `about`, `affiliates`, `imprint`, `privacy` und `terms`
  standen nicht darin und wurden nie geschrieben. Darum blieb die
  Shortcode-Entschärfung auf `/paywall-memberships/` liegen, während sie die
  beiden anderen Seiten erreichte. Beide Listen kommen jetzt aus einer Quelle.

## Offen, nach Wirkung sortiert

1. **1.12.3 und 1.12.4 ausrollen**, dann `push-site.sh` — der zweite Lauf trägt
   die entschärften Shortcodes auf `/paywall-memberships/`, jetzt wo die Seite
   in der Liste steht.
2. **Google- und LinkedIn-App anlegen**, Schlüssel unter WopCart → Sign-in
   eintragen. Redirect-URIs: `https://wopcart.com/?wopcart_oauth=google` und
   `…=linkedin`. Ohne sie ist der Rundlauf ungetestet.
3. **Tracking-Kennungen eintragen** (Reiter Marketing). Ohne Kennung lädt
   nichts, es ist also folgenlos, aber auch wirkungslos.
4. **Bewertungen einschalten**: „Ask for a review on the site" und die
   E-Mail-Strecke stehen auf Off; „Only verified buyers may review" steht auf
   false und widerspricht der Absicht.
5. **Direct auf wopcart.com läuft 1.0.1**, Käufer laden 1.0.2.
6. **UX-Befunde** aus dem Audit: Markengrün 2.91:1 statt 4.5 (elf Verstöße je
   Seite aus einem Farbwert), elf Seiten ohne SEO-Titel obwohl im Manifest
   vorhanden, Knopfbeschriftung am Produkt, „ein Ziel, vier Namen".
7. **Rechnungsdaten und Support-Tickets im Konto** — beides fehlt noch.
8. **Versandmethoden-Tabelle**: neun Spalten in einer Einstellungszeile sind
   das eigentliche Problem; der Scrollrahmen ist Eindämmung, keine Heilung.

## Nicht reproduzierbar

Das Auswahlfeld „Challenge provider" (Reiter Advanced) klappt beim Eigentümer
nicht auf. Im Backend gemessen: aktiv, fünf Optionen, `pointer-events: auto`,
kein Element darüber, kein Skript bricht Klick, Maus-ab oder Zeiger-ab ab. Die
Darstellung (`appearance: none` plus SVG-Pfeil) kommt aus WordPress' eigenem
`forms.css`, nicht aus WopCart — das Feld ist gebaut wie jedes andere
Auswahlfeld im Backend. Nächster Schritt: im privaten Fenster ohne
Erweiterungen prüfen; auf den Screenshots sind Passwortmanager-Symbole in
benachbarten Feldern zu sehen.
