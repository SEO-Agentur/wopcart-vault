# Warum Stripe Connect nie funktioniert hat

**Stand:** 2026-10-22 · **Verwandt:** [[Deployment/WopCart Platform ausrollen]] · [[Components/Payments]] · [[Planning/Roadmap-Status]]

## Befund

Beim Versuch, `guaranteedseoservices.com` als Händler zu verbinden, kamen nacheinander
zwei Fehler. Der erste lag an der Seite, der zweite an uns.

### 1. Eigentumsprüfung scheiterte — Ursache: Seooptimierung Toolkit

> Stripe could not be connected: The platform could not confirm that this request came
> from the site itself.

Bevor die Plattform ein Konto anlegt, muss sie beweisen, dass der Antrag von der
genannten Domain kommt. Der Shop legt ein Geheimnis in einen Transient (10 Minuten) und
schickt nur dessen SHA-256 plus die Abhol-URL. Die Plattform holt die URL **ohne
Anmeldung und ohne Weiterleitungen** ab (`wp_safe_remote_get`, `redirection => 0`) und
vergleicht den Abdruck.

Gemessen am 2026-10-22:

```
GET https://guaranteedseoservices.com/wp-json/wopcart/v1/connect/challenge/<id>
→ 401 {"code":"seo_wp_rest_not_logged_in",
       "message":"The REST API is restricted to logged-in users on this site."}
```

Das ist die Einstellung **„Restrict the REST API to logged-in users"** im
Seooptimierung Toolkit (Reiter Performance), bewusst pauschal ohne Ausnahmen gebaut.
Auf einem Shop muss sie aus sein: sie blockiert sonst auch die weitergeleiteten
Stripe-Webhooks, die Lizenzprüfungen fremder Kundenseiten und die Apple-Pay-Domainprüfung.

### 2. Stripe lehnte die Kontoanlage ab — Ursache: unser Code

> When `stripe_dashboard[type]=express`, your platform must collect fees and be liable
> for negative balances or refunds and chargebacks.

`ConnectServer::account_controller()` verlangte einen **Express**-Dashboard, ließ aber
die Bearbeitungsgebühren beim Händler (`fees.payer = account`) und die Verluste bei
Stripe (`losses.payments = stripe`). Stripe erlaubt Express nur, wenn die Plattform
**beides** übernimmt. Die Kombination war also seit jeher unmöglich — jeder
Verbindungsversuch scheiterte, weshalb „Free plan via Stripe Connect" nie fertig wurde.

Der Kommentar im Code beschrieb die richtige Absicht („type=express is avoided"), das
Literal darunter tat das Gegenteil. Ein Fall, in dem die Dokumentation den Fehler
überdeckt hat.

**Behoben in WopCart Platform 1.0.1:** `stripe_dashboard.type = full`, Gebühren beim
Händler, Verluste bei Stripe, `requirement_collection = stripe`. Der Händler bekommt
sein eigenes Stripe-Dashboard, zahlt die Bearbeitungsgebühren aus eigener Tasche und
Stripe trägt die Verluste — genau das, was „merchant of record" bedeutet und was 2 %
Plattformgebühr tragen können. `type = none` hätte Stripe auch akzeptiert, verpflichtet
uns aber, Dashboard und Support selbst zu stellen.

Festgenagelt von `ConnectAccountControllerTest`, der die Regel mitschreibt: Express nur,
wenn Gebühren **und** Verluste bei der Plattform liegen.

### Nebenbefund: Plattform-Plugin hätte auf Kern 1.4 abgestürzt

`Server.php` importierte `WopCart\Platform\PlanVerdict` — eine Klasse, die der Kern in
1.4.0 gelöscht hat. Sobald wopcart.com auf 1.4 läuft, hätte die Plan-Route für jede
Seite, die noch 1.3.x spricht, einen Fatal Error geworfen. Die zwei verwendeten Codes
(`site_inactive`, `busy`) sind Teil des Protokolls und stehen jetzt ausgeschrieben im
Plattform-Plugin. Zwei Tests, die an der gelöschten Klasse hingen, prüfen jetzt das
Verhalten dieses Servers selbst.

## Sofortmaßnahme für wopcart.com

Die Plattform läuft dort noch im alten Kern, der denselben Fehler trägt — aber denselben
Filter anbietet. `Deployment/mu-plugins/06-connect-controller.php` setzt die richtigen
Werte und wirkt sofort, ohne dass etwas ausgerollt werden muss:

```
scp -i ~/.ssh/seowebsitesbuilder_vps Deployment/mu-plugins/06-connect-controller.php \
    root@187.77.74.66:/opt/wopcart/mu-plugins/
ssh -i ~/.ssh/seowebsitesbuilder_vps root@187.77.74.66 \
    'docker cp /opt/wopcart/mu-plugins/06-connect-controller.php wopcart-web:/var/www/html/wp-content/mu-plugins/ && docker exec wopcart-web chown www-data:www-data /var/www/html/wp-content/mu-plugins/06-connect-controller.php'
```

Nach dem Ausrollen von Platform 1.0.1 ist die Datei überflüssig und kann weg; sie setzt
bis dahin genau dieselben Werte, schadet also auch nicht.

## Was noch zu tun ist

- Eine Prüfung unter **WopCart → Status**, die die eigene REST-Wurzel von außen abruft
  und meldet, wenn ein anderes Plugin sie sperrt. Ein Sicherheitsplugin mit dieser
  Voreinstellung macht sonst jeden Shop still kaputt.
- Im **Seooptimierung Toolkit** eine Freigabeliste für Namensräume, damit `wopcart/v1`
  und `slim-hreflang/v1` erreichbar bleiben, ohne die Sperre ganz aufzugeben.
- Der erste echte Verbindungsversuch bleibt der Beweis: erst wenn ein Konto entsteht und
  der Onboarding-Link öffnet, ist Connect wirklich fertig.
