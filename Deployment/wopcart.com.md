# wopcart.com — Deployment

**Ziel:** eigene WordPress-Instanz für wopcart.com (Plattform-Store von DigitalCart) auf dem
geteilten Hostinger-VPS 187.77.74.66. Keine bestehende Anwendung darf berührt werden.
**Status:** ✅ **Abgenommen 2026-09-13 11:23 UTC.** wopcart.com liefert HTTP 200 über Cloudflare. E-Mail SPF/DKIM/DMARC PASS. **Welle 2 live seit 2026-09-14 06:44 UTC** (DB 1.3.0, Stripe Connect, Mollie, Rechnungen+PDF, Sale-/Brutto-Netto-Preise, MCP, LMS, Webhooks, Anti-Spam, Releases; Review-Fixes). Offen: Shop-Stripe-Keys + Connect-Webhook-Secret (Nutzer), Rechtsseiten (Anwalt), Stripe-Ende-zu-Ende-Test, Restore-Test.
**Asana:** https://app.asana.com/1/262428162084225/project/1218428532588319
**Tracking:** Asana-Projekt „wopcart.com — WordPress Deployment" · Kanban-Projekt `digital-cart`

---

## Protokoll

### 2026-09-13 — Baseline (nur lesend)

**DNS:** `wopcart.com` und `www.wopcart.com` → Cloudflare-IPs (104.21.12.144, 172.67.194.234),
Nameserver felicity/kristina.ns.cloudflare.com → Zone liegt in Cloudflare, **proxied**.

**Server:** Ubuntu, Docker 29.4.1, Compose v5.1.3, Caddy v2.11.2.
RAM 7.8 GiB, davon 4.8 GiB verfügbar · Swap 4 GiB (786 MiB belegt) · Disk /: 96 G, 28 % belegt.
Alle Container healthy, alle vier PM2-Prozesse online.

### Abweichungen vom Deployment-Brief

Der mitgelieferte Brief ist **veraltet**. Er beschreibt zwei Stacks, auf der Box laufen acht:

| Brief sagt | Tatsächlich |
|---|---|
| `:4200` für die neue App vorschlagen | **belegt** — content-king-web |
| `:5434` für Postgres vorschlagen | **belegt** — factory-postgres |
| — | `:4201` monitory-app, `:4202` content-king-wp ebenfalls belegt |
| „no swap" | 4 GiB Swap vorhanden |
| cf-origin.crt deckt „die bestehenden Domains" | deckt **nur** `seosites.app` + `*.seosites.app` |
| TLS: bestehendes Cert erweitern | Konvention der Box ist **ein Cert pro Domain** (`cf-origin-<app>.crt`) |
| Next.js | Hier: WordPress |

Weitere Stacks, die ebenfalls nicht angefasst werden: content-king, content-king-wp,
monitory-app (+4 Worker), factory (agency-app + postgres), ki-visibility, openclaw.

**Freie Ports geprüft:** 4203, 4204, 4205, 4206, 3307, 3308.

### Vorbild auf derselben Box: `/opt/content-king-wp`

Bereits erprobte WordPress-Instanz, deren Muster übernommen wird statt ein neues zu erfinden:
- `mariadb:11` + `wordpress:php8.3-apache`, je `mem_limit: 384m`, `restart: unless-stopped`
- **kein** Host-Port für die DB (nur compose-internes Netz)
- WordPress an `127.0.0.1:<port>:80`, Healthcheck auf `wp-login.php`
- `wpcli`-Service im Profil `tools` für Einmal-Befehle
- HTTPS-Erkennung hinter dem Proxy als **mu-plugin-Datei**, nicht als Inline-PHP im YAML —
  Compose interpoliert `$` in YAML-Werten und zerstört jedes `$_SERVER` stillschweigend
- `.env` mode 600, owner root
- Caddy-Block mit Kommentarkopf, eigenes `cf-origin-content-king.crt`

---

## Architektur (umgesetzt in Dateien)

```
/opt/wopcart/
├── .env                     600 root — Secrets auf dem Server erzeugt, nie ausgegeben
├── docker-compose.yml
├── mu-plugins/
│   ├── 00-proxy.php         HTTPS + echte Client-IP hinter Cloudflare/Caddy
│   ├── 01-smtp.php          wp_mail über Brevo, inaktiv solange SMTP_USER leer
│   ├── 02-platform.php      WOPCART_PLATFORM_PRODUCT_ID = 14 (seit 2026-09-14)
│   └── 03-site-seo.php      SEO-Titel/Meta-Beschreibung ohne SEO-Plugin (seit 2026-09-14)
├── rollback/                700 — vorherige Plugin-Builds
├── php/wopcart.ini          Upload 100 M, memory 256 M
├── bin/backup.sh            nächtlicher Dump + Uploads, 7 Tage
└── backups/                 700
```

| Service | Image | Port | mem_limit |
|---|---|---|---|
| `wopcart-db` | `mariadb:11.8.8` | keiner | 384m |
| `wopcart-web` | `wordpress:7.1.0-php8.3-apache` | `127.0.0.1:4203` | 512m |
| `wopcart-cron` | wie web (nur curl) | keiner | 32m |
| `wopcart-backup` | wie db (mariadb-dump) | keiner | 128m |
| **Summe** | | | **1056 MiB** |

Cron und Backup verwenden die ohnehin benötigten Images wieder — nichts Zusätzliches wird gezogen.

### Bewusste Details

- **Keine Secrets im Chat.** Datenbankpasswörter entstehen per `openssl rand` direkt auf dem Server.
  Nur alphanumerisch, damit weder die `$`-Interpolation von Compose noch `.env`-Quoting sie zerstört.
- **Kein Admin-Passwort in `.env`** — anders als content-king-wp. Das Konto legt der Nutzer im Browser an.
- **Upload-Limit 100 M, nicht mehr:** Cloudflare begrenzt Request-Bodies auf Free/Pro auf 100 MB.
  Ein höheres PHP-Limit würde den klaren PHP-Fehler nur gegen einen undurchsichtigen 413 am Edge tauschen.
- **Backups schreiben nach `.partial`** und benennen erst bei Erfolg um. Ein abgebrochener Lauf
  hinterlässt nie eine abgeschnittene Datei, die wie ein gutes Backup aussieht.
- **`MYSQL_PWD` statt `-p`**, damit das Passwort nicht in `ps` erscheint.
- **Client-IP aus `CF-Connecting-IP`**: nötig, weil der Shop die IP als EU-VAT-Standortnachweis
  speichert. Einschränkung: fälschbar, solange der Origin direkt erreichbar ist.

### Bekannte Risiken

- **Installer-Übernahme:** Sobald Caddy die Domain ausliefert, ist `/wp-admin/install.php` öffentlich,
  bis das Admin-Konto existiert. Bots übernehmen frische Installationen gezielt. → Schutz im Caddy-Block.
- **Apache prefork** kann unter Last mehr Prozesse starten, als 512m tragen. Folge wäre ein OOM-Kill
  *dieses* Containers mit Neustart — die anderen Stacks sind durch `mem_limit` abgeschirmt.
- **Container-Logs** nutzen den Standard-json-Treiber ohne Rotation (Brief: keine Log-Treiber ohne
  Plattenprüfung). 70 GB frei — bei Bedarf später begrenzen.

## Start des Stacks — 2026-09-13 10:47 UTC

`docker compose pull db && docker compose up -d`

| Prüfung | Ergebnis |
|---|---|
| `wopcart-db`, `wopcart-web` | healthy nach 5 s |
| `GET /` (Host wopcart.com) | 302 → `https://wopcart.com/wp-admin/install.php` |
| `GET /wp-admin/install.php` | 200, „WordPress › Installation" |
| Lauschende Adresse | nur `127.0.0.1:4203` |
| WordPress im Volume | 7.1 |
| PHP-Limits | upload 100M, post 100M, memory 256M — aktiv |
| mu-plugins im Container | `00-proxy.php`, `01-smtp.php` |
| Cron | erster Aufruf sofort (302, erwartet vor der Installation), dann alle 900 s |
| Backup | wartet auf 03:15 UTC |

**Verbrauch:** web 73 MiB · db 93 MiB · cron < 1 MiB · backup < 1 MiB — ≈ 167 MiB von 1056 MiB.
**Host danach:** 4.9 GiB verfügbar.

**Andere Stacks vorher/nachher:** 14 Container, 8 healthy, 4 PM2-Prozesse online. Verglichen wurden
Name und Health-Status (Uptime-Spalte herausgefiltert) — Diff leer, nichts verändert.

## Live-Schaltung — 2026-09-13

### Origin-Zertifikat (Nutzer, 11:06–11:08 UTC)

Geprüft: SAN `wopcart.com` + `*.wopcart.com`, Cloudflare Origin SSL CA, gültig bis 2041-09-09.
Schlüssel passt zum Zertifikat (identischer Public-Key-Hash).

**Korrigiert:** Beide Dateien lagen mit `644 root:root` — der private Schlüssel war für jeden Benutzer
der Box lesbar. Auf `640 root:caddy` gesetzt, wie alle anderen Zertifikate unter `/etc/caddy`.

### Caddy-Block (Nutzer) und SSL-Handshake-Fehler

Der Nutzer hat den Block selbst ans Ende der Caddyfile gehängt (Zeilen 168–192) und dann
`systemctl reload` sowie `caddy validate` ausgeführt. **Beide Befehle haben nichts bewirkt:**

| Befehl | Problem |
|---|---|
| `systemctl reload` | Dienstname fehlt → „Too few arguments" |
| `caddy validate` | ohne `--config` sucht Caddy eine Caddyfile im aktuellen Verzeichnis |

Caddy lief also unverändert seit 2026-08-10 und kannte `wopcart.com` nicht → TLS-Alert 80 am Origin →
Cloudflare **525 SSL handshake failed**.

Die in der Chatnachricht sichtbare Zeile `[www.wopcart.com](https://www.wopcart.com)` war nur
Markdown-Darstellung — in der Datei stand sie korrekt. Vor dem Reload geprüft, nicht angenommen.

**Richtig:**

```bash
caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
systemctl reload caddy
```

Backup vor dem Reload: `/etc/caddy/Caddyfile.bak-wopcart-20260913-111518`
Reload um 11:15:18 UTC. `ActiveEnterTimestamp` unverändert → echter reload, kein restart.

### Nachweise

| Prüfung | Ergebnis |
|---|---|
| Cert, das Caddy für wopcart.com liefert | Cloudflare Origin CA, `*.wopcart.com`, `wopcart.com` |
| `https://wopcart.com/` (außen) | 302 → `/wp-admin/install.php` |
| `https://www.wopcart.com/` (außen) | 301 → `https://wopcart.com/` |
| `http://wopcart.com/` (außen) | 308 → `https://wopcart.com/` |
| Installer, IP des Nutzers | 200, „WordPress › Installation" |
| Installer, fremde IP | **403** „Installation locked" |
| `setup-config.php`, fremde IP | **403** |
| Response-Header | `server: cloudflare`, `cf-ray` vorhanden |
| 6 andere Domains (Zertifikat vorher/nachher) | identisch |
| Fremde Container / PM2 | 14 / 4 online, unverändert |

```
$ dig +short A wopcart.com       → 172.67.194.234 104.21.12.144
$ dig +short A www.wopcart.com   → 172.67.194.234 104.21.12.144
$ dig +short NS wopcart.com      → kristina.ns.cloudflare.com. felicity.ns.cloudflare.com.
```

### Befund in einem fremden Stack — nicht angefasst

Nach dem Reload meldete Caddy Fehler beim Zertifikat für **`www.seowebsitesbuilder.com`**
(Let's Encrypt: NXDOMAIN). Geprüft, ob wir das verursacht haben: **nein.**

- Der Block `seowebsitesbuilder.com, www.seowebsitesbuilder.com` steht in Zeile 8, schon vor dem wopcart-Block
- 168 Fehlereinträge im Journal **vor** unserem Reload, vom 2026-09-06 14:38 (Journalbeginn) bis 08:40 UTC
- `www.seowebsitesbuilder.com` hat keinen DNS-Eintrag

Der Reload hat den seit Tagen scheiternden Versuch lediglich neu angestoßen. Behebung gehört zu
Stack A (DNS-Eintrag für www anlegen oder www aus dem Block nehmen) und wurde nur gemeldet.

## Installation und Abnahme — 2026-09-13

### Installer-Sperre entfernt (11:21 UTC)

Erst nachgewiesen, dann geändert — sonst hätte ein falsches „angelegt" den Installer wieder für
jeden geöffnet:

| Nachweis | Ergebnis |
|---|---|
| `siteurl` in der Datenbank | `https://wopcart.com` |
| Administrator-Konten | 1 (nur Anzahl geprüft — keine Namen, keine Adressen) |
| `install.php` direkt am Container | „Already Installed" |

Regel per exaktem Textabgleich entfernt (genau ein Treffer verlangt, sonst Abbruch).
Backup: `/etc/caddy/Caddyfile.bak-wopcart-20260913-112143` · validate → reload.
Sieben Domains vorher/nachher identisch. Die Sperre war von 11:15 bis 11:21 UTC aktiv.

### Abnahmebericht

**Live-URL:** https://wopcart.com — Titel „WOPCart – The Last Payment Plugin you need"

```
$ curl -I https://wopcart.com/
HTTP/2 200
content-type: text/html; charset=UTF-8
link: <https://wopcart.com/wp-json/>; rel="https://api.w.org/"
server: cloudflare
cf-ray: a3a6c5d66e282d04-MRS
```

| Route (außen) | Status |
|---|---|
| `/` | 200 |
| `/wp-login.php` | 200 |
| `/wp-admin/install.php` | 200 „Already Installed" |
| `/wp-json/` | 200 |
| `/robots.txt` | 200 — vom Origin, Cloudflare überdeckt sie nicht |
| `https://www.wopcart.com/` | 301 → `https://wopcart.com/` |
| `http://wopcart.com/` | 308 → https |

**docker compose ps**

```
NAME             IMAGE                           STATUS                    PORTS
wopcart-backup   mariadb:11.8.8                  Up 35 minutes             3306/tcp
wopcart-cron     wordpress:7.1.0-php8.3-apache   Up 35 minutes             80/tcp
wopcart-db       mariadb:11.8.8                  Up 35 minutes (healthy)   3306/tcp
wopcart-web      wordpress:7.1.0-php8.3-apache   Up 35 minutes (healthy)   127.0.0.1:4203->80/tcp
```

**docker stats --no-stream**

| Container | Speicher / Limit | % | CPU |
|---|---|---|---|
| wopcart-web | 100.9 MiB / 512 MiB | 19.7 % | 0.01 % |
| wopcart-db | 104.9 MiB / 384 MiB | 27.3 % | 0.03 % |
| wopcart-cron | 688 KiB / 32 MiB | 2.1 % | 0.00 % |
| wopcart-backup | 880 KiB / 128 MiB | 0.7 % | 0.00 % |

Host: 4.8 GiB verfügbar · Disk 30 % · fremde Container 14 (8 healthy) · PM2 4 online — unverändert.

**Cron nach der Installation:** manueller Aufruf von `wp-cron.php` → 200. (Die Aufrufe um 11:02 und
11:17 bekamen 302, weil WordPress da noch nicht installiert war.)

**Finaler Caddy-Block** (Ende von `/etc/caddy/Caddyfile`)

```caddy
# =============================================================================
# WopCart (wopcart.com) — docker compose stack, WordPress at 127.0.0.1:4203.
# Managed in /opt/wopcart; do not edit inline.
# Cloudflare origin cert for wopcart.com + *.wopcart.com.
# =============================================================================
www.wopcart.com {
    tls /etc/caddy/cf-origin-wopcart.crt /etc/caddy/cf-origin-wopcart.key
    redir https://wopcart.com{uri} permanent
}

wopcart.com {
    tls /etc/caddy/cf-origin-wopcart.crt /etc/caddy/cf-origin-wopcart.key
    encode zstd gzip

    reverse_proxy 127.0.0.1:4203
}
```

**`.env`:** `/opt/wopcart/.env`, `600 root:root`. Variablen (nur Namen):
`MARIADB_ROOT_PASSWORD` `MARIADB_DATABASE` `MARIADB_USER` `MARIADB_PASSWORD` `WORDPRESS_DB_HOST`
`WORDPRESS_DB_NAME` `WORDPRESS_DB_USER` `WORDPRESS_DB_PASSWORD` `WP_SITE_URL` `SMTP_HOST` `SMTP_PORT`
`SMTP_USER` `SMTP_PASS` `SMTP_FROM` `SMTP_FROM_NAME` — `SMTP_USER` noch leer.

**Caddyfile-Backups:** `Caddyfile.bak-wopcart-20260913-111518` (vor Live-Schaltung),
`Caddyfile.bak-wopcart-20260913-112143` (vor Entfernen der Sperre).

## E-Mail — 2026-09-13

### SMTP (Nutzer 12:28 UTC, Container neu erstellt 12:29 UTC)

Geprüft ohne Versand, keine Werte ausgegeben:

| Prüfung | Ergebnis |
|---|---|
| `SMTP_USER`, `SMTP_PASS`, `SMTP_FROM` in `.env` | gesetzt, Format ok (keine Leerzeichen, Anführungszeichen, `$`) |
| Container geladen? | ja — Container (12:29:43) neuer als `.env` (12:28:18), Werte im Container vorhanden |
| `01-smtp.php` aktiv | ja — `smtp-relay.brevo.com:587`, STARTTLS |
| Absender | `*@wopcart.com`, Name „WopCart" |
| Anmeldung bei Brevo | **erfolgreich** |

Die Anmeldung wurde mit PHPMailer `smtpConnect()` geprüft: EHLO, STARTTLS, AUTH, dann Trennen.
Es wird kein `MAIL FROM`, `RCPT TO` oder `DATA` gesendet — technisch kann dabei keine Mail entstehen.

### Domain-Authentifizierung — Stand vor dem Eintragen (12:30 UTC)

SPF nur Hostinger, `brevo-code` fehlte, DKIM `brevo1`/`brevo2` fehlten, DMARC `p=none`.
Folge: Anmeldung klappt, aber Mails wären nicht DKIM-signiert — Gmail/Yahoo verlangen seit 2024
eine authentifizierte Absenderdomain.

### Domain-Authentifizierung — nach dem Eintragen (Nutzer „bestätigt")

| Eintrag | Stand |
|---|---|
| `brevo-code` (TXT) | vorhanden |
| `brevo1._domainkey` | CNAME → `b1.wopcart-com.dkim.brevo.com` → `brevo7.dkim.brevo.com` (DNS only ✅) |
| `brevo2._domainkey` | CNAME → `b2.wopcart-com.dkim.brevo.com` → `brevo8.dkim.brevo.com` (DNS only ✅) |
| Schlüssel am Kettenende | RSA-Schlüssel, bei ns1/ns2.sendinblue.com und öffentlich abrufbar |
| DMARC | `v=DMARC1; p=none; rua=mailto:rua@dmarc.brevo.com` |
| SPF | unverändert `include:_spf.mail.hostinger.com ~all` — **kein Fehler**, siehe unten |
| MX | `mx1/mx2.hostinger.com` — Hostinger-Postfach, unberührt |

**Verlauf der Prüfung:**

1. Direkt nach dem Eintragen lieferten Brevos Nameserver uneinheitlich: `ns1` NXDOMAIN für b1 und b2,
   `ns2` nur für b2 einen Verweis. Brevo hatte die Zone noch nicht vollständig veröffentlicht.
   Die Einträge auf der Cloudflare-Seite waren schon da korrekt.
2. Später je 12 Abfragen pro Nameserver und Selektor: **48/48 mit Verweis, 0 NXDOMAIN.**
   Hinter `brevo7` und `brevo8` liegt je ein RSA-Schlüssel.
3. Öffentliche Resolver: 9.9.9.9 löst beide Selektoren bis zum Schlüssel auf, 8.8.8.8 `brevo2`.
   1.1.1.1 und 8.8.8.8 (`brevo1`) hielten noch das frühere NXDOMAIN im Negativ-Cache —
   Brevos SOA-Minimum ist 3600 s, spätestens nach einer Stunde ist das verschwunden.

**SPF — Korrektur einer früheren Aussage:** Brevo muss nicht im SPF stehen. Der Envelope-Absender
(Return-Path) ist bei Brevo eine Brevo-Domain, SPF wird also gegen Brevo geprüft und ist dort
aligned nicht mit wopcart.com. Für DMARC reicht ein bestandenes, **aligned DKIM** (`d=wopcart.com`),
und das liefern die beiden Selektoren. Ein zusätzliches `include:spf.brevo.com` schadet nicht
(SPF liegt dann bei ca. 8 von 10 DNS-Lookups), ist aber optional.

### Testmail — ✅ bestanden (2026-09-13 15:47 UTC)

`wp_mail()` im Container an die vom Nutzer genannte Adresse, Absender `info@wopcart.com` über
`smtp-relay.brevo.com`, Message-ID `<1M5YeyqXuTQB7gOaHnbQ8REsyvDFbNflwwc8l1UpJo@4bf278668704>`.
Gmail „Original anzeigen" (Screenshot des Nutzers): zugestellt nach 2 s,
**SPF PASS** (IP 77.32.148.28, Brevo) · **DKIM PASS** mit Domain `wopcart.com` · **DMARC PASS**.

**Zwei Stolperfallen beim Eintragen in Cloudflare:**

- **DKIM-CNAMEs auf „DNS only" (graue Wolke).** Ein proxied CNAME wird von Cloudflare aufgelöst
  und liefert Cloudflare-IPs statt des Schlüssels — die DKIM-Prüfung schlägt dann fehl.
- **SPF erweitern, nicht verdoppeln.** Zwei `v=spf1`-Einträge ergeben einen permerror, und dann
  scheitert SPF für Brevo *und* für das Hostinger-Postfach. Die exakte `include`-Angabe aus Brevo
  in den bestehenden Eintrag einfügen.

## Wartung

**Aktualisieren / neu starten** (Image-Tags sind gepinnt — für ein Update erst den Tag in
`docker-compose.yml` ändern):

```bash
ssh -i ~/.ssh/seowebsitesbuilder_vps root@187.77.74.66 'cd /opt/wopcart && docker compose pull && docker compose up -d --remove-orphans'
```

**Nach Änderung an `.env`** (z. B. Brevo-Zugang): `cd /opt/wopcart && docker compose up -d wordpress`

**Logs:** `cd /opt/wopcart && docker compose logs -f --tail=200`

**Caddy** — immer mit Pfad validieren, immer reload, nie restart:

```bash
caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile && systemctl reload caddy
```

**Backups:** `/opt/wopcart/backups`, täglich 03:15 UTC, 7 Tage. Wiederherstellen der Datenbank:

```bash
cd /opt/wopcart && gunzip -c backups/db-<STAMP>.sql.gz | docker compose exec -T db sh -c 'MYSQL_PWD="$MARIADB_ROOT_PASSWORD" mariadb -u root "$MARIADB_DATABASE"'
```

**Neustart des Hosts:** Alle vier Services haben `restart: unless-stopped` und kommen über den
Docker-Daemon automatisch zurück. Keine systemd-Unit nötig.

## Nach der Abnahme offen

| | Wer | Warum |
|---|---|---|
| ~~Brevo-Zugang~~ ✅ · ~~DNS~~ ✅ · ~~Testmail: SPF/DKIM/DMARC PASS~~ ✅ | — | E-Mail vollständig erledigt |
| Cloudflare auf Full (strict) prüfen | Nutzer | Mindestens „Full" ist aktiv (früherer 525), „strict" von außen nicht erkennbar |
| Restore-Test nach dem ersten Backup (ab 03:15 UTC) | Claude | Ein nie zurückgespieltes Backup ist eine Annahme |
| ~~Umbenennung DigitalCart → WopCart~~ ✅ · ~~Plugin hochladen~~ ✅ · **Plugin aktivieren** | Nutzer im Browser | Aktivierung legt die Tabellen an |
| Seitentitel „WOPCart" an Plugin-Namen „WopCart" angleichen (optional) | Nutzer | Plugin folgt der bestätigten Schreibweise `WopCart` |
| Origin auf Cloudflare beschränken (Authenticated Origin Pulls) | gemeinsam | Betrifft die ganze Box |
| `www.seowebsitesbuilder.com` ohne DNS | Stack A | Nur gemeldet, nicht angefasst |

## Ursprüngliche Reihenfolge (Archiv)

1. ~~**[Nutzer]** Origin Certificate in Cloudflare erzeugen und auf den Server legen~~ ✅
2. ~~**[Freigabe]** Caddy-Block anhängen → validate → reload~~ ✅ (Installer-Sperre aktiv)
3. **[Nutzer]** Cloudflare prüfen: Full (strict), Always Use HTTPS, Automatic HTTPS Rewrites, Managed robots.txt aus
   — Der frühere 525 zeigt, dass mindestens „Full" aktiv ist; ob „strict", ist von außen nicht erkennbar
4. **[Nutzer]** WordPress-Installation im Browser
5. Installer-Regel aus dem Caddy-Block entfernen, reload
6. **[Nutzer]** Brevo-Zugang in `.env`, dann `docker compose up -d wordpress`
7. Umbenennung DigitalCart → WopCart, danach Plugin installieren

**Warum der Installer geschützt wird, bevor die Domain live geht:** Bots überwachen neue
Zertifikate und scannen gezielt nach `/wp-admin/install.php`. Wer die Installation zuerst
abschließt, besitzt die Seite. Das Zeitfenster ist klein, aber real. Die Regel in Caddy matcht auf
`Cf-Connecting-Ip`, weil hinter Cloudflare jede Verbindung von Cloudflare-Adressen kommt.
Die IP des Nutzers wird bewusst **nicht** in diesem Protokoll gespeichert.

**Warum Full (strict) erst nach Schritt 2:** Der SSL-Modus gilt für die ganze Zone. Wird er
umgestellt, bevor der Origin ein gültiges Zertifikat ausliefert, antwortet Cloudflare mit 526.

## Entscheidungen

### Bestätigt (2026-09-13)

| Frage | Entscheidung | Folge |
|---|---|---|
| TLS | **Neues Cloudflare Origin Cert** für `wopcart.com, *.wopcart.com` | Nutzer erzeugt es im Dashboard; Ablage `/etc/caddy/cf-origin-wopcart.{crt,key}` |
| Admin-Konto | **Nutzer im Browser** über `/wp-admin/install.php` | Kein Admin-Passwort in `.env` — bewusste Abweichung von content-king-wp |
| Rolle / Name | **Komplett in WopCart umbenennen** | Eigenes Arbeitspaket, entkoppelt vom Deployment |

### Bestätigt, Runde 2 (2026-09-13)

| Frage | Entscheidung |
|---|---|
| Cron | **alle 15 Minuten** — ursprünglich täglich vorgeschlagen, nach Darlegung der Zeitpläne geändert |
| Präfix | **`wopcart_` / `WopCart\` / `wopcart-`** |
| E-Mail | **Brevo** (`smtp-relay.brevo.com:587`, STARTTLS) |
| Backups | **täglich lokal, 7 Tage** |

### Cron: Fakten aus dem Code

Der Einwand gegen „minütlich" ist berechtigt. Aber der Aufruf-Takt ist nicht der Aufgaben-Takt:
WordPress führt bei jedem Aufruf von `wp-cron.php` nur die Aufgaben aus, die gerade fällig sind.

| Hook | Zeitplan | Folge bei täglichem Aufruf |
|---|---|---|
| `dcart_check_abandoned` | 15 min | Warenkorb-Erinnerung bis zu 24 h zu spät |
| `dcart_deliver_webhooks` | 15 min | Zapier/InvoicesGenerator bis zu 24 h verzögert |
| `dcart_process_renewals` | stündlich | Verlängerungen bis zu 24 h verspätet |
| `dcart_expire_licenses` | stündlich | Lizenzen laufen bis zu 24 h zu spät ab |
| `dcart_refresh_rates` | 2× täglich | halbiert |
| `dcart_expire_downloads`, `dcart_daily_maintenance` | täglich | unkritisch |

**Vorschlag:** Aufruf alle 15 Minuten — das feinste tatsächliche Intervall. Minütlich wäre in der Tat Verschwendung.

### Gepinnte Images

| Service | Tag | Begründung |
|---|---|---|
| Datenbank | `mariadb:11.8.8` | identisch mit der laufenden content-king-wp-db; Layer liegen bereits auf dem Host |
| WordPress | `wordpress:7.1.0-php8.3-apache` | neuester Stand, PHP 8.3 wie im Schwester-Stack (dort 8.3.33) |

WordPress-Core liegt nach der Erstinstallation im Volume `wp_data`. Der Image-Tag bestimmt nur den
Erststand; spätere Core-Updates laufen über WordPress selbst.

## Umbenennung DigitalCart → WopCart: Inventar

Gemessen 2026-09-13 über src, client, templates, assets, tests, bin und Root-Dateien:

| Bezeichner | Treffer | Dateien |
|---|---|---|
| `DigitalCart\` (Namespace) | 775 | 145 |
| `DigitalCart` (gesamt) | 1018 | 162 |
| `dcart_` (Hooks, Optionen, Tabellen) | 1029 | 118 |
| `dcart-` (CSS, data-Attribute) | 1326 | 63 |
| `digital-cart` (Slug, Textdomain) | 1426 | 115 |
| davon Textdomain `'digital-cart'` | 1375 | — |
| `digital-cart/v1` (REST) | 10 | 9 |
| `digitalcart.dev` | 10 | 6 |
| `DCART_` (Konstanten) | 3 | 1 |
| `dcartConfig` / `dcartAdmin` (JS) | 3 / 2 | 3 / 2 |

Dateinamen: `digital-cart.php`, `languages/digital-cart.pot`, `client/class-digitalcart-updater.php`.
Präfix-Tabu: `wc_` (WooCommerce) und `woo` (auf WordPress.org geschützt).

**Messfehler dokumentiert:** Die erste Messung ergab überall 0 — in zsh wird eine unquotierte Variable
nicht in Wörter aufgeteilt, `grep` bekam einen einzigen nicht existenten Pfad, und die Fehlermeldung
lief nach `/dev/null`. Neu gemessen in bash mit Array und einer Plausibilitätsprüfung vorab.

## Umbenennung durchgeführt — 2026-09-13

**Sicherung vorher:** `/Users/cyrusbadde/projects/plugins/digital-cart.bak-pre-wopcart-20260913` (kein Git-Repo).

Ersetzungen, case-sensitiv und in dieser Reihenfolge (164 Dateien, `vendor/` ausgenommen):

| Alt | Neu |
|---|---|
| `digitalcart.dev` | `wopcart.com` |
| `DigitalCart` | `WopCart` (Namespace, Name) |
| `digital-cart` | `wopcart` (Textdomain, Slug, Template-Ordner, REST `wopcart/v1`) |
| `digitalcart` | `wopcart` |
| `DCART_` | `WOPCART_` |
| `X-DCart-*` (Webhook-Header) | `X-WopCart-*` |
| `dcart` ohne vorangehenden Buchstaben | `wopcart` (Hooks, Optionen, CSS, JS-Globals, WP-CLI `wp wopcart`, Menü) |

Das Lookbehind verhindert, dass `AbandonedCart` zu `AbandonewopcartCart` wird. Eine
case-insensitive Suche hätte genau das getroffen.

Dateien umbenannt: `wopcart.php`, `languages/wopcart.pot`, `client/class-wopcart-updater.php`.
Plattform-Endpunkte jetzt `https://wopcart.com/wp-json/wopcart/v1/plan/check` und `…/platform/session`.
Plugin-Beschreibung: „no platform fees" gestrichen, weil der freie Plan 2 % erhebt.

**Nachweise:**

| Prüfung | Ergebnis |
|---|---|
| Reste von `digital cart` / `dcart` (case-insensitive) | 0 außer `AbandonedCart` / `bindCart` |
| `php -l` | 154 Dateien, 0 Fehler |
| PHPUnit | 78 Tests, 385 Assertions, OK |
| POT neu erzeugt | 1088 Strings, `X-Domain: wopcart` |
| PHPCS vorher → nachher | 808 E / 524 W → 808 E / 71 W. Die Namen sind länger, dadurch verrutschte die Ausrichtung. Behoben nur mit den beiden Alignment-Sniffs, reine Leerzeichen. Die 808 Fehler sind Altbestand (v. a. `PreparedSQL`-Hinweise, Präfix-Variablen in Templates). |

**Installation auf wopcart.com (nicht aktiviert):**
- Zip nach `.distignore` gebaut: 153 Dateien, 436 KB, Ordner `wopcart/`
- Ablage `/opt/wopcart/wopcart-plugin-1.0.0.zip` (600), per `docker cp` nach
  `wp-content/plugins/wopcart`, Eigentümer `www-data`
- Im Container: alle PHP-Dateien syntaxfrei. WordPress erkennt „WopCart 1.0.0", aktiv: nein.
  wopcart.com antwortet weiter mit 200.
- Aktivierung macht der Nutzer im Browser (Entscheidung „Admin: Nutzer im Browser").

## Hartkodiertes `digitalcart.dev` im Plugin — ✅ ersetzt durch wopcart.com

Betroffen waren:
- `src/Platform/Plan.php` → `/wp-json/digital-cart/v1/plan/check`
- `src/Gateways/Connect.php` → `/wp-json/digital-cart/v1/platform/session`
- `digital-cart.php` (Plugin URI, Author URI)
- `readme.txt` (Links auf /terms und /privacy)

## Aufgaben, die nur der Nutzer erledigen kann

Claude gibt keine Zugangsdaten ein und legt keine Konten an.
- Cloudflare: Origin Certificate für `wopcart.com, *.wopcart.com` erzeugen
- Cloudflare: SSL „Full (strict)", Always Use HTTPS, Automatic HTTPS Rewrites, Managed robots.txt aus
- WordPress: Admin-Konto anlegen
- E-Mail-Dienst: Konto und API-Schlüssel

## Master-Lizenz auf wopcart.com — 2026-09-14

**Entscheidungen des Nutzers:** 5 Pakete · Website auf Englisch · Produkt und Seiten sofort live.

| Paket (price id) | Preis | Domains |
|---|---|---|
| Single (`single`) | €89 / Jahr | 1 |
| Studio (`studio`) | €179 / Jahr | 3 |
| Agency (`agency`) | €349 / Jahr | 7 |
| Pro (`pro`) | €499 / Jahr | 12 |
| Enterprise (`enterprise`) | €699 / Jahr | 20 |

- Produkt **#14 „WopCart"**, veröffentlicht unter `https://wopcart.com/products/wopcart/` (200)
- Wiederkehrend jährlich, Lizenzschlüssel an, Domain-Limit je Paket, 365 Tage
- Datei: `uploads/wopcart-protected/wopcart-1.0.0.zip` (www-data, 640). Direktaufruf liefert **403**.
- Store-Währung USD → **EUR**. Permalinks `/%year%/…` → **`/%postname%/`**, solange noch keine öffentlichen URLs existieren.
- `mu-plugins/02-platform.php` definiert `WOPCART_PLATFORM_PRODUCT_ID = 14`, per bind mount in `docker-compose.yml`. Backup der Compose-Datei: `docker-compose.yml.bak-20260914-platform`.
- **Noch offen:** Stripe-Schlüssel (Nutzer). Store-Land, Adresse und USt-ID sind nicht bekannt, daher sind Steuer und EU-VAT noch aus. Die Zip wird nach dem Sicherheits-Review durch den neuen Build ersetzt.

## Plugin-Build mit Review-Fixes und Website — 2026-09-14

### Plugin (01:52 UTC)
- Build: 162 Dateien, sha256 `5829e14d…`. Deploy-Skript tauscht den Plugin-Ordner in einem Schritt und rollt automatisch zurück, wenn der Check fehlschlägt.
- Rollback-Kopie: `/opt/wopcart/rollback/wopcart-prev-20260914-015324`, außerhalb von `wp-content/plugins`. Dort würde sie als zweites „WopCart" in der Plugin-Liste stehen.
- Rauchtest live:

| Prüfung | Ergebnis |
|---|---|
| `POST /plan/check`, unbekannter Key | `missing_license`, 200 |
| `GET /plan/check` | 404 (nur POST registriert) |
| Product JSON-LD `/products/wopcart/` | AggregateOffer EUR 89–699, 5 Offers |
| robots auf checkout / my-account / order-confirmation | `noindex, follow` |
| Core-Sitemap | ohne Shop-Systemseiten |
| PHP-Fehler seit Deploy | keine |

### Website (01:54 UTC)
- `mu-plugins/03-site-seo.php` ist per bind mount eingebunden. Es gibt SEO-Titel und Meta-Beschreibung aus und tritt zurück, sobald Yoast, Rank Math oder AIOSEO aktiv ist. Compose-Backup: `docker-compose.yml.bak-20260914-siteseo`.
- Import-Skript: gleiche Slugs werden beim erneuten Import aktualisiert, nicht dupliziert. Es setzt Startseite (#15), Hauptmenü, Footer-Template-Part, Produktbeschreibung #14 und die Einstellungen `page_terms`/`page_privacy`.
- Live mit 200: `/`, features, pricing, software-licensing, paywall-memberships, eu-vat, integrations, docs, faq, why-wopcart, plan-changes-refunds.
- Entwürfe: imprint #26, privacy-policy #3, terms #28. Die Platzhalter `[COMPANY NAME]` usw. brauchen die Firmendaten.
- Hello World und Sample Page: auf Entwurf gesetzt, nicht gelöscht.
- `/pricing/`: echte Kauf-Buttons „Choose Single … Enterprise" per Shortcode, weil der Warenkorb nur POST mit Nonce annimmt.
- **Ehrlichkeits-Korrekturen vor dem Livegang:**
  - „Download free" heißt jetzt „Get started".
  - Der Download-Platzhalter in den Docs ist durch einen Hinweis auf die Zip im Plan ersetzt; WordPress.org ist in Vorbereitung.
  - Home und Pricing sagen offen, dass der Gratis-Plan erst mit dem Stripe-Connect-Onboarding (#131) startet. Der Code hat dafür noch keinen Connect-Flow.
  - In der readme sind die unbelegten EDD-Preise (3 %, €199.50, €299.50) entfernt. Die EDD-Preisseite zeigt am 14.09.2026 Aktionspreise, Personal €79.60.

## Stripe-Plattform-Schlüssel — 2026-09-14

- Die Schlüssel hat der Nutzer selbst in `/opt/wopcart/.env` eingetragen (600 root:root): `STRIPE_PLATFORM_SECRET` (sk_test_…), `STRIPE_PLATFORM_PUBLISHABLE` (pk_test_…). Die Werte stehen nicht im Protokoll.
- `mu-plugins/02-platform.php` liest sie per `getenv` in die Konstanten `WOPCART_PLATFORM_STRIPE_KEY`, `WOPCART_PLATFORM_STRIPE_PUBLISHABLE` und `WOPCART_CONNECT_WEBHOOK_SECRET`. Die Datei wurde mit `cat >` überschrieben, damit der Bind-Mount die Datei behält. Backup: `02-platform.php.bak-20260914-env`.
- Container neu erstellt, danach healthy, Seite liefert 200.
- Prüfung per Lesezugriff auf die Stripe-API:
  - `GET /v1/account` → 200, Konto `acct_1UFPnILTW7dodt6I`, Land **MT**, Währung eur, `charges_enabled false`
  - `GET /v1/accounts` → 200. Connect-API ist nutzbar, 0 verbundene Konten.
- Offen:
  - `STRIPE_CONNECT_WEBHOOK_SECRET` (nach A1, wenn der Webhook angelegt ist)
  - Shop-Schlüssel unter WopCart → Settings → Payments (Nutzer)
  - Stripe-Kontodaten vervollständigen (`charges_enabled false`)
  - Store-Land klären: WopCart steht auf US, Stripe-Konto auf MT

## Betreiberdaten und Store-Einstellungen — 2026-09-14

- **Vom Nutzer:** WopCart.com · Cyrus Badde · 50 Triq il-Marfa, Bay Blue 2 · MLH 9065 Mellieha · Malta · USt-ID MT24104415
- **VIES** (EU-REST-API, 02:54 UTC): `isValid: true`, eingetragener Name „CYRUS PETER BADDE", Adresse „Bay Blue, Apt No 2, Triq Il-Marfa, MLH9065 Mellieha". Die Hausnummer 50 steht in VIES nicht.
- **WopCart-Einstellungen:** Store-Name `WopCart.com`, Land US → **MT**, Stadt, PLZ, Adresse, USt-ID gesetzt. Steuer und EU-VAT bleiben **aus**, bis der Nutzer über OSS bzw. die Schwelle entscheidet.
- **Rechtstexte** (Imprint, Privacy, Terms; weiter Entwurf): Betreiber, Adresse und USt-ID eingetragen. Offen sind Rechtsform, Kontakt-E-Mail, Telefon, Registereintrag, Aufsichtsbehörde, Hosting-Angaben, Cookie-Liste, Aufbewahrungsfristen, Rechtswahl und alle „COUNSEL"-Punkte. Backups: `*.html.bak-20260914` im Vault.

### Entscheidungen des Nutzers (2026-09-14, später am Tag)
- Name im Außenauftritt: **„C. Badde"**, **Einzelunternehmer**. Adresse **ohne Hausnummer**: Triq il-Marfa, Bay Blue 2, MLH9065 Mellieha, Malta.
- **EU-VAT eingeschaltet:** `tax_enabled`, `eu_vat_enabled` = true; VIES, Reverse Charge und Standortnachweis an; MT-Satz 18 %. `prices_include_tax` bleibt false (Nettopreise).
- **wopcart.com bleibt online**, keine Coming-soon-Seite.
- Rechtstext-Entwürfe angepasst: „operated by C. Badde, sole trader", Adresse ohne Hausnummer, Hinweis „EU VAT enabled" bestätigt.
- **Offen:** Kontakt-E-Mail; Registerabschnitt im Impressum entfernen (Einzelunternehmer); Brutto-Preisangabe gegenüber Verbrauchern.

## Deploy Welle 2 (alle Features + Review-Fixes) — 2026-09-14 06:44 UTC

**Vorher:** DB-Backup `backups/db-predeploy-20260914-064417.sql.gz` (600, 30 Tabellen), DB-Version 1.2.0.
**Build:** 277 Dateien, sha256 `caf18763…`. Tauschen des Plugin-Ordners in einem Schritt, Check bestanden. Rollback-Kopie `/opt/wopcart/rollback/wopcart-prev-20260914-064418`, lokale Release-Kopie `digital-cart.bak-release-20260914-wave2`.
**Lokal vor Deploy:** `php -l` 362 Dateien / 0 Fehler · PHPUnit 753 Tests grün · JS-Syntax ok · POT 2101 Strings.

**Rauchtest live:**
| Prüfung | Ergebnis |
|---|---|
| DB-Version | 1.3.0 |
| Tabellen `wopcart_platform_sites`, `wopcart_platform_deliveries` | vorhanden |
| Discounts `batch`/`batch_run`, Abo-Indizes `date_created`/`date_cancelled` | vorhanden |
| REST: plan/check, platform/connect/start, platform/stripe, platform/connect/webhook, license/public-key, releases/github | registriert |
| REST `connect/events` | nicht registriert, korrekt für die Plattform-Seite |
| Abilities API (WP 7.1) | 18 WopCart-Abilities |
| Preis-Anzeigemodus | `auto`; Produktseite zeigt über Cloudflare (EU) „incl. VAT" |
| JSON-LD | `valueAddedTaxIncluded:false` |
| HTTP `/`, pricing, product, checkout, my-account, features, docs | 200 |
| PHP-Fehler seit Deploy | keine |
| Regression Settings-Speichern (Tab general) | Checkboxen anderer Tabs bleiben erhalten (`tax_enabled`, `eu_vat_enabled` = true) ✅ |

**Befunde beim Rauchtest:**
- Beim Speichern des Tabs „General" wurde `page_terms` (Entwurfsseite #28) auf leer gesetzt, weil das Auswahlfeld nur veröffentlichte Seiten kennt. Die Seiten-IDs wurden als String gespeichert. **Direkt korrigiert:** `page_terms=28`, IDs wieder als int. Folgeaufgabe: Seiten-Auswahl soll Entwürfe erhalten und IDs als int speichern.
- **Keine Gateways verfügbar auf wopcart.com:** Die Plattform zählt als Bezahlplan, es fehlen die Shop-Stripe-Schlüssel in den WopCart-Einstellungen (Nutzer).
- Produktseite zeigt TT5-Byline „Written by" (Single-Post-Template). Folgeaufgabe: eigenes Template für `wopcart_product`.

## Release-Regel (Nutzer, 2026-09-14)
Jedes Plugin-Update auf wopcart.com bekommt eine **neue Versionsnummer** und aktualisiert im selben Schritt **/changelog/** und **/roadmap/**.

Checkliste pro Release:
1. Nächste Version wählen (SemVer: neue Funktionen → Minor, nur Fixes → Patch). Nie eine live Version wiederverwenden.
2. `wopcart.php` Header `Version:` + `const VERSION`, `readme.txt` `Stable tag:` + `== Changelog ==`-Eintrag.
3. Vault `Website/pages/changelog.html`: neuer `<article id="X-Y-Z">` mit Datum, Added/Changed/Fixed (nur was wirklich im Build ist); „Unreleased“ anpassen. Entwurf liegt unter `Website/release-notes/<version>.md`.
4. Vault `Website/pages/roadmap.html`: Punkte von In progress/Planned nach Shipped verschieben.
5. Deploy mit `Deployment/scripts/deploy-plugin.sh` – bricht ab, wenn Header/Const/Stable tag nicht übereinstimmen, der readme- oder Seiten-Changelog fehlt oder die Version schon live ist (Notfall: `ALLOW_SAME_VERSION=1`).
6. Seiten `/changelog/` und `/roadmap/` pushen (nur diese zwei Seiten, nicht `import.php`), live prüfen.
7. Obsidian (Roadmap-Status) + Asana aktualisieren.

Stand: live = **1.0.0** (enthält alle Deploys vom 2026-09-14 bis Welle 3). Nächste Version: **1.1.0** (Formulare, Integrations-Hub, Rechnungen, Memberships, Warenkorb-Seite, Redesign, WPML/Polylang, Divi/Bricks).
