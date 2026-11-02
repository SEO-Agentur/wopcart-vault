# Zahlungsmodus 1.15.0 — der Modus gehörte nie dem Händler

Stand: 2. November 2026. Gebaut, geprüft, in GitHub. **Noch nicht deployt.**

## Der Befund

Stripe beantwortet eine echte Karte gegen einen Test-Schlüssel mit
`Your card was declined. Your request was in test mode, but used a non test card.`
Der Käufer liest das als Problem mit seiner Karte. Der Händler sieht gleichzeitig
eine Einstellungsseite, auf der „Live" steht. Drei getrennte Wege in diesen
Zustand, keiner davon irgendwo sichtbar.

### 1. Test-Schlüssel im Live-Feld

Stripe schreibt den Modus in jeden Schlüssel, den es ausgibt (`sk_test_…`,
`sk_live_…`). **Nichts hat geprüft, ob der Schlüssel zum Feld passt.** Das Feld
nahm die Zeichenkette, der Shop buchte in der Sandbox und meldete Live.
Einzige Prüfung dieser Art im ganzen Code war Mollies — und deren
Fehlermeldung hat nie jemand gesehen (siehe 4.).

### 2. Plattform-Modus

Im Free-Plan wird mit **WopCarts** Schlüssel gegen das verbundene Konto gebucht
(`Stripe::secret_key()` → `Connect::platform_key()`). `$this->is_test()` kommt in
diesem Zweig überhaupt nicht vor. Die Checkbox „Test mode" hatte dort **nie**
eine Wirkung, sah aber aus wie eine Steuerung.

Die Plattform sendet `livemode` seit jeher
(`wopcart-platform/src/ConnectServer.php:428`, `platform_is_live()` prüft
`/\A(sk|rk)_live_/`). `ConnectClient::normalize_status()` hat es **weggeworfen**.
Das Feld lag die ganze Zeit auf der Leitung.

### 3. Konto im einen Modus verbunden, im anderen benutzt

`stripe_connect_account` lag ohne Modus daneben. Ein im Testmodus angelegtes
Stripe-Konto ist mit einem Live-Schlüssel nicht belastbar. Sobald die Plattform
umschaltet, bekommt **jeder** verbundene Shop einen Checkout, der an der Karte
scheitert.

### 4. Abgelehnte Schlüssel schwiegen

`Gateways\Mollie::save_settings()` schreibt die Ablehnung mit
`add_settings_error()`. Das Speichern leitet weiter, und diese Funktion hält ihre
Meldungen nur bis zum Request-Ende. **Keine dieser Ablehnungen hat je einen
Bildschirm erreicht.**

## Was gebaut ist

`src/Gateways/Mode.php` — die Unterscheidung als reine Funktionen:

| Methode | Entscheidung |
|---|---|
| `of_credential()` | Modus aus dem Präfix (`sk_`/`rk_`/`pk_`, Mollie `live_`/`test_`) |
| `of_setting()` | Modus aus dem Optionsnamen, beidseitig von `_` begrenzt — `stripe_live_secret` ja, `test_mode` nein |
| `refusal()` | nur bei **beidseitig bekanntem** Widerspruch |
| `effective()` | welcher Modus wirklich gilt |
| `usable()` | letztes Tor, bevor ein Schlüssel Geld bewegt |
| `settable()` | ob die Checkbox überhaupt etwas entscheidet |

**Unbekannt ist überall eine vollwertige Antwort.** PayPal- und
Authorize.Net-Secrets nennen keinen Modus; ein Feld, das nur Verstandenes
annimmt, sperrt den Händler aus seinen eigenen Einstellungen aus. Und eine
Plattform, die sich nicht geäußert hat, ist unbekannt — **niemals live**.

Weiter:

- `Settings::screen_credentials()` wirft nur den widersprüchlichen Wert weg, der
  Rest der Speicherung geht durch. Liest **alle** Felder, keine feste Liste — ein
  Add-on ist abgedeckt, sobald es der Hausbenennung folgt.
- `Settings::report_refusals()` legt Ablehnungen ins Transient
  `wopcart_admin_error_<user>` und zieht `get_settings_errors( 'wopcart' )` mit
  hinein. Mollie darf die WordPress-Funktion behalten, die Meldung überlebt jetzt
  die Weiterleitung.
- `Connect::platform_mode()` → gemeldeter Modus, sonst Präfix des gespeicherten
  `pk_…`, sonst unbekannt. Das Präfix ist **öffentlich** und liegt auf jedem
  verbundenen Shop — die Reparatur wirkt rückwirkend ohne Plattform-Deploy.
- `Connect::mode_conflict()` → `is_active()` ist falsch, die Karte verschwindet
  aus dem Checkout, der Admin sagt „neu verbinden". **Ein Ausfall, den der
  Händler sieht, schlägt einen, den nur seine Kunden sehen.**
- `ACCOUNT_MODE_OPTION` wird **einmal** geschrieben, beim ersten Status mit
  Modusangabe, und beim Verbindungsstart geleert. Ein Wert, der der Plattform
  hinterherläuft, stimmt immer mit ihr überein und fängt nie das, wofür er da ist.

## Die Checkbox bleibt absichtlich klickbar

Eine deaktivierte Checkbox sendet **nichts**, und `Settings::collect()` speichert
eine fehlende Checkbox auf ihrem eigenen Tab als `false`. Deaktivieren hätte die
Einstellung des Händlers beim nächsten Speichern dieses Tabs still abgeschaltet.
Gefehlt hat nie die Sperre, sondern die Auskunft.

## Nebenbei: Rabattcodes

`DiscountEngine::matching_products()` war „für die Admin-Vorschau" geschrieben
und **nie aufgerufen**. Ein Code, dessen Einschränkungen auf nichts passen, sah
auf dem Bearbeiten-Bildschirm genauso aus wie einer ohne Einschränkungen; das
erste, was jemand davon hörte, war ein Kunde mit „gilt für nichts in Ihrem
Warenkorb". Die Vorschau ist jetzt verdrahtet und zählt ein Produkt nicht mehr
mit, das zugleich genannt und ausgeschlossen ist.

## Geprüft

1862 Tests, 21961 Assertions · 5799 statische Referenzen, 0 ungelöst ·
phpcs auf jeder berührten Datei auf oder unter Grundlinie (`Settings.php` 75 → 74)
· .pot 4268 Strings.

## Offen

- **Deploy** (führt der Nutzer aus) und das Paket für guaranteedseoservices.com:
  `/Users/cyrusbadde/projects/plugins/wopcart-1.15.0.zip`
- **Der Modus der Plattform selbst.** Diese Freigabe macht ihn sichtbar und
  erzwingbar; sie setzt ihn nicht. Steht auf wopcart.com ein `sk_test_`-Schlüssel
  in `WOPCART_PLATFORM_STRIPE_KEY`, bucht jeder Free-Plan-Shop weiter in der
  Sandbox — jetzt eben mit einem Hinweis, der das sagt.
- Debug-Notices auf guaranteedseoservices.com: 1.14.2 behebt die
  Textdomain-Warnung, ist dort aber noch nicht installiert. Die
  `add_query_arg(null, …)`-Deprecation (`wp-includes/functions.php:1194`) braucht
  den Backtrace aus `wopcart-diagnostics.php`.
