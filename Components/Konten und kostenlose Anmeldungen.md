# Konten und kostenlose Anmeldungen (Kern 1.7.0)

**Stand:** 2026-11-01 · **Live auf wopcart.com:** ja, Kern 1.7.0
**Verwandt:** [[Components/Monetisation]] · [[Components/Licensing]] · [[Planning/Roadmap-Status]] · [[05 Decisions Log]]

## Warum überhaupt

Zwei Löcher, beide im selben Bereich.

**Erstens:** Ob ein Käufer ein Konto bekam, entschied allein ein Häkchen im Checkout, das
er abwählen konnte. Wer es bei einer Mitgliedschaft abwählte, hielt etwas in der Hand,
das er nie wieder erreichen konnte — eine Mitgliedschaft ohne Login ist ein Versprechen,
das niemand einlösen kann.

**Zweitens:** Ein kostenloser Plan lief über den Checkout. Warenkorb, Adressformular,
Steuerland, AGB-Häkchen — vier Stellen, an denen man aufhört. Für ein Produkt, das
nichts kostet, sind das vier Stellen zu viel. Entscheidung des Nutzers vom 2026-11-01:
„die kostenlose Mitgliedschaft soll glaube ich nicht durch einen checkout prozess laufen
müssen. das ist ein unnotwendiger schritt mit abbruch potenzial."

## 1. Wann ein Konto Pflicht ist

Vier Gründe, unabhängig voneinander, entschieden in `AccountRequirement::decide()` —
eine Funktion, damit Checkout, REST-Route und MCP nicht auseinanderlaufen:

1. das Produkt verlangt es (`_wopcart_require_account`),
2. das Produkt vergibt eine Mitgliedschaftsstufe und der Shop hat diese Regel nicht
   abgeschaltet (`memberships_require_account`, standardmäßig an),
3. ein Plugin verlangt es (`wopcart_require_account_for( $product_id, $grund )`),
4. der Shop verlangt es für jeden Kauf (`require_account_always`).

Wo es Pflicht ist, zeigt der Checkout kein Häkchen mehr, sondern den Satz, dass ein
kostenloses Konto angelegt wird — plus den Grund, wenn ein Plugin einen mitgeliefert hat.
Zu entscheiden gibt es nichts, also wird nichts zur Entscheidung gestellt.

## 2. Einloggen direkt nach dem Kauf

`src/Accounts/AutoLogin.php` loggt den Käufer **einmal** ein, auf der Belegseite, auf die
ihn sein eigener Kauf weitergeleitet hat. Sicher ist das durch den Order-Key — dasselbe
Geheimnis, auf dem die Belegseite selbst läuft. Drei weitere Bedingungen:

- es ist niemand eingeloggt, also wird keine Sitzung ersetzt,
- das Konto wurde von **diesem** Auftrag erzeugt (`_wopcart_created_for_order`), also kann
  eine Bestellung mit fremder Adresse nie ein fremdes Konto übergeben,
- der Händler hat es nicht abgeschaltet (`auto_login_new_accounts`).

Ein Produkt kann danach woanders hin schicken als auf den Beleg
(`_wopcart_after_purchase_redirect`) — geprüft gegen die eigene Domain, beim Speichern
*und* nach dem Filter. Ein Open Redirect auf der Seite, auf der jeder Käufer landet, wäre
für jemanden viel Geld wert.

## 3. `[wopcart_account_signup]` — Anmeldung ohne Checkout

Shortcode und Block (`wopcart/account-signup`). Fragt eine E-Mail-Adresse ab, Name und
Telefonnummer optional (Telefon ist Pflichtfeld-frei, Entscheidung des Nutzers:
„Rufnummer als Feld, Eingabe nicht verpflichtend"). Gespeichert wird die Nummer so, wie
sie getippt wurde (`wopcart_phone`) — E.164 braucht ein Land, das dieses Formular nicht
erfragt.

**Der Anker-Auftrag.** Mit `product="14"` entsteht ein abgeschlossener Auftrag über 0 €
mit Order-Meta `signup`. Das ist Absicht: Mitgliedschaften, Lizenzen, Kundendatensatz und
jeder Report hängen an Aufträgen. Eine Anmeldung ohne Auftrag wäre ein Mitglied, das
nichts sieht — kein Startdatum, keine Verlängerung, keine Zeile in der Kundenliste. Die
Fulfilment-Kette läuft wie bei einem Kauf.

**Was das Produkt sein muss** — alles, was der Checkout vorher gefragt hätte, hier
gefragt, weil es keinen Warenkorb gibt, der es fragen könnte: existiert, veröffentlicht,
nicht versteckt, innerhalb des Verkaufsfensters, **tatsächlich kostenlos**, und noch eins
übrig. Das Letzte lässt „die ersten hundert Konten sind frei" funktionieren — ein
Gesamtlimit ist für das Plugin Lagerbestand, inklusive Hold und Commit.

Ein `product=`, das Geld kostet, wird **abgelehnt und geloggt**, nicht stillschweigend
verschenkt. Vertippte ID, kopierter Shortcode, später erhöhter Preis — sonst wäre das
Produkt weg, Lizenzschlüssel inklusive.

**Wer schon eingeloggt ist** sieht dasselbe Formular auf einen Knopf reduziert, solange er
das Produkt noch nicht hat. Zwei echte Fälle: der Kunde mit Konto aber ohne Freiplan, und
der Händler, der sein eigenes Formular als Administrator testet. Einmal, nicht mehr —
`purchased_quantity()` hält den zweiten Klick auf.

**Schutz:** Honeypot und Challenge des Login-Formulars (Formular-ID `account_login`) plus
eigenes Rate Limit von 5/Stunde pro Adresse, weil jede durchgelassene Anfrage einen
WordPress-Benutzer erzeugt. Ein Theme-Override ohne
`do_action( 'wopcart_form_protection', 'account_login' )` wird abgelehnt.

## 4. Ein Postfach, ein Freiplan — gegen Alias-Missbrauch

Entscheidung des Nutzers vom 2026-11-01: „ich will verhindern, dass leute mit fake email
adressen oder gmail adressen, die mit plus z.B. name+394@gmail.com sich anmelden und
dadurch gratis leistungen bekommen."

Eine Adresse hat jetzt zwei Formen. Die getippte ist, was der Shop anschreibt und was auf
der Rechnung steht — nichts wird hinter dem Rücken des Kunden umgeschrieben. Die
**kanonische** ist die Identität: kleingeschrieben, alles nach einem `+` weg, bei Google
zusätzlich die Punkte weg und `googlemail.com` zu `gmail.com`. Nur die kanonische Form
entscheidet, ob dieses Postfach das Kostenlose schon hatte. Sie wird auf jedem Konto
vermerkt, das WopCart anlegt (`wopcart_email_key`), und zwar in beide Richtungen: egal ob
zuerst der Alias oder zuerst die Klaradresse kam.

`+` wird für **alle** Domains entfernt, nicht nur für die Anbieter, die es offiziell
unterstützen. Dagegen steht, dass einzelne Hosts `+` als normales Zeichen behandeln; dafür
steht jeder Anbieter, bei dem das Plus ein kostenloser, unbegrenzter Alias-Generator ist.
Abschaltbar über `signup_collapse_aliases`.

Dazu drei weitere Hürden:

| Einstellung | Standard | Was sie tut |
|---|---|---|
| `signup_block_disposable` | an | Wegwerf-Anbieter aus eingebauter Liste (mailinator, yopmail, temp-mail …), Subdomains mit |
| `signup_blocked_domains` | leer | Eigene Liste des Händlers, eine Domain pro Zeile |
| `signup_require_mx` | an | DNS-Abfrage, ob die Domain überhaupt Mail annehmen kann; 12 h gecacht, **fail open** |
| `signup_block_freemail` | aus | Nur Geschäftsadressen; grobes Werkzeug, viele Einzelunternehmer nutzen Freemail |

Drei Dinge offen gesagt: die Wegwerf-Liste ist unvollständig und kann es nicht anders sein
(diese Domains entstehen schneller als jede Liste ausgeliefert wird —
`wopcart_disposable_domains` ist die Naht für einen gepflegten Dienst); die DNS-Prüfung
lässt durch, wenn sie selbst nicht möglich ist, weil ein Shop auf einem Host ohne
Namensauflösung nicht jeden Besucher abweisen darf; und **bezahlte Aufträge sind davon
nicht betroffen**. Wessen Postfach ein zahlender Kunde benutzt, ist seine Sache — eine
Bestellung wegen der Schreibweise abzulehnen würde den Händler Geld kosten, um nichts zu
verhindern. Ein Checkout mit 0 € Summe unterliegt den Wegwerf- und DNS-Regeln, aber nicht
der „hat schon ein Konto"-Regel: erneut von derselben Adresse kaufen ist normal.

## 5. Dateien

| Datei | Aufgabe |
|---|---|
| `src/Accounts/AccountRequirement.php` | Wann ein Konto Pflicht ist, Grund, Redirect-Ziel |
| `src/Accounts/AutoLogin.php` | Einmaliges Einloggen auf der Belegseite |
| `src/Accounts/EmailIdentity.php` | Kanonische Adresse, Wegwerf-Listen, MX, „schon vorhanden" |
| `src/Accounts/Signup.php` | Shortcode, POST-Handler, Anker-Auftrag, Freiplan-Rail |
| `src/Accounts/functions.php` | `wopcart_require_account_for()` und zwei Abfragen |
| `templates/account-signup.php` | Formular, überschreibbar |
| `tests/Unit/AccountRequirementTest.php` | 6 Tests |
| `tests/Unit/EmailIdentityTest.php` | 11 Tests |
| `tests/Unit/SignupEligibilityTest.php` | 12 Tests, inkl. Alias-Richtungen und Freiplan-Rail |

Suite insgesamt: **1757 Tests, 21156 Assertions, OK**. PHPCS auf allen neuen Dateien 0
Befunde.

## 6. Noch nicht gebaut

- **Social Sign-up** (Google, dann LinkedIn). X und Facebook hat der Nutzer gestrichen.
  Braucht vier readme-Einträge unter „External services", Logo-Lizenzen und darf keine
  Anbieter-Skripte vor dem Klick laden.
- **Magic Link** (`POST wopcart/v1/account/magic-link`, 32-Byte-Token als SHA-256, 15 min,
  einmalig, Rate Limit, konstante Antwort). Nicht nötig, um den Checkout-Schritt
  loszuwerden, also verschoben.
- **Doppelte Opt-in-Bestätigung** vor dem Freiplan — die stärkste Hürde gegen Fake-Adressen,
  hängt aber am Magic Link.
- Ende-zu-Ende-Test der echten Formularabsendung (Benutzer wird angelegt, Auftrag entsteht,
  Mitgliedschaft wird vergeben): nicht auf dem Live-Shop gemacht, weil dafür ein
  veröffentlichtes kostenloses Produkt und ein echter Benutzer auf wopcart.com entstehen
  müssten. Gehört auf `guaranteedseoservices.com/stage`.
