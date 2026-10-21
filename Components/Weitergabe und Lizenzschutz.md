# Weitergabe und Lizenzschutz

**Stand:** 2026-09-24 · **Verwandt:** [[Components/Editions]] · [[Components/Licensing]] · [[Planning/WordPress-org-Launch]] · [[05 Decisions Log]]

## Ausgangslage

Ein WordPress-Plugin gilt als abgeleitetes Werk und steht unter der GPL. Die erlaubt
ausdrücklich, den Code weiterzugeben und auch zu verkaufen. Weiterverkauf lässt sich
deshalb nicht verhindern, und technische Sperren dagegen wären ein Lizenzverstoß. Jeder
größere Anbieter findet seine Dateien in GPL-Clubs wieder und lebt trotzdem gut davon.

**Verkauft wird nicht die Datei, sondern die laufende Versorgung damit.**

## Was wir tatsächlich kontrollieren

1. **Updates und Support.** Dienstleistungen, keine Software. Sie dürfen an eine gültige
   Lizenz gebunden sein. Eine weitergegebene Kopie ist ab dem nächsten Release veraltet und
   bekommt keine Sicherheitskorrekturen — bei einem Zahlungs-Plugin ein hartes Argument.
2. **Die Plattform.** Der kostenlose Plan läuft über unser Stripe-Connect-Konto und unsere
   API; eine Seite weist sich mit einem Token aus, das wir ausstellen. Eine Kopie bekommt
   dort keinen Zugang. Das ist kein Kopierschutz, sondern ein Dienst, den nur wir betreiben.
3. **Die Marke.** Marken fallen nicht unter die GPL. Wer den Code weitergibt, darf ihn nicht
   als „WopCart“ verkaufen und unser Logo nicht verwenden. Voraussetzung ist die Eintragung.
4. **Nachverfolgbarkeit.** Jeder Download trägt Kunden- und Lizenznummer, damit ein Leak
   einem Konto zuzuordnen ist. Das schreckt stärker ab als jede Schlüsselprüfung.

## Bereits eingebaut

Lizenzschlüssel mit Aktivierungen und Platzzählung, signierte Update-Antworten (Ed25519),
Download-Links mit Ablauf und Bindung an Bestellung und Seite, Auslieferung von Paketen nur
an aktivierte Domains.

## Geplant

- **Kennzeichnung je Download:** Kunden- und Lizenznummer in eine mitgelieferte Datei bzw.
  in den Kopf der Hauptdatei schreiben, beim Ausliefern erzeugt.
- **Markenanmeldung „WopCart“** (EU, EUIPO), damit Angebote unter unserem Namen angreifbar
  sind.
- **Ruhiger Hinweis im Admin**, wenn die Lizenz fehlt oder abgelaufen ist: keine Updates,
  keine Sicherheitskorrekturen. Kein Sperren, kein Drängen.

## Was wir bewusst nicht tun

- Funktionen abschalten, wenn der Schlüssel fehlt.
- Das Plugin lahmlegen, wenn unser Server nicht erreichbar ist.

Beides trifft zuverlässig zahlende Kunden mit Serverproblemen und hält niemanden auf, der
die Prüfung ohnehin entfernt. Dieselbe Haltung steht schon im Bestandscode: im Zweifel
offen scheitern, siehe [[Components/Editions]] (Risiken) und `Platform/Plan.php`-Nachfolge.
