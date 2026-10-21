# Git-Sicherung aller vier Repositories

**Stand:** 2026-10-21 · **Verwandt:** [[Components/Editions]] · [[Deployment/wopcart.com]]

## Ziel-Zustand

Alle vier Teile liegen auf GitHub unter `SEO-Agentur`, der Kern öffentlich, die drei
anderen privat.

| Teil | Ort auf der Platte | Fernziel | Stand |
|---|---|---|---|
| **WopCart** (Kern, GPL) | `projects/plugins/digital-cart` | `SEO-Agentur/wopcart` | **gepusht** bis `a996ca1` (1.4.0 + Nacharbeit) |
| **WopCart Direct** | `projects/plugins/wopcart-direct` | `SEO-Agentur/wopcart-direct` | committet `c50e6e4`, Fernziel eingetragen, **Repository fehlt auf GitHub** |
| **WopCart Platform** | `projects/plugins/wopcart-platform` | `SEO-Agentur/wopcart-platform` | committet `d0ba3a7`, Fernziel eingetragen, **Repository fehlt auf GitHub** |
| **Vault** (diese Doku) | `projects/plugins/digital-cart-vault` | `SEO-Agentur/wopcart-vault` | neu als Git angelegt, erster Commit `de771c5`, **Repository fehlt auf GitHub** |

## Weg dahin

Die drei fehlenden Repositories müssen **privat** angelegt werden, ohne README, ohne
`.gitignore` — sonst kollidiert der erste Push. Danach je einmal:

```
git -C ~/projects/plugins/wopcart-direct   push -u origin main
git -C ~/projects/plugins/wopcart-platform push -u origin main
git -C ~/projects/plugins/digital-cart-vault push -u origin main
```

## Warum privat

- **Direct** ist das bezahlte Add-on. Es ist GPL, der Quelltext darf also weitergegeben
  werden, aber wir stellen ihn nicht selbst zum Herunterladen bereit — siehe
  [[Components/Weitergabe und Lizenzschutz]].
- **Platform** läuft nur auf wopcart.com und beschreibt unsere Serverseite.
- Der **Vault** enthält Betriebswissen: VPS-Adresse, Containernamen, Ausroll-Abläufe.
  Geheimnisse selbst stehen nicht darin, die liegen in `/opt/wopcart/.env` auf dem Server
  (geprüft: kein Treffer auf `sk_live`, `sk_test`, `whsec_`, `pk_`, private Schlüssel).

## Vault-Repository

`.gitignore` hält Obsidian-Arbeitsdateien heraus (`.obsidian/workspace*.json`,
`.obsidian/cache`, `.DS_Store`). Die `.bak-*`-Sicherungen der Website-Seiten bleiben drin,
sie sind Teil der Nachvollziehbarkeit.

## Zips bauen

Die ausgelieferten Zips werden nicht versioniert, sondern gebaut. Der Kern hat
`.distignore` (Tests, phpcs, SDK und der Updater-Baukasten fliegen heraus), die anderen
zwei haben keine und werden ohne `tests/`, `phpunit.xml*`, `.github` und `phpcs.xml*`
gepackt:

```
rsync -a --exclude-from=.distignore --exclude .git <repo>/ <stage>/wopcart/
cd <stage> && zip -qr wopcart-<version>.zip wopcart
```

Stand 2026-10-21 gebaut: `wopcart-1.4.0.zip` (1,9 MB), `wopcart-direct-1.0.0.zip` (111 kB),
`wopcart-platform-1.0.0.zip` (47 kB).

### Eine alte Version bauen

Für den Zwischenschritt beim Ausrollen (Kern 1.3.1, damit Direct installiert werden kann,
bevor 1.4.0 die Tarif-Logik entfernt) wird aus dem Commit gebaut, nicht aus dem
Arbeitsbaum:

```
git -C digital-cart worktree add --detach /tmp/wt a8d885a
rsync -a --exclude-from=/tmp/wt/.distignore --exclude .git /tmp/wt/ <stage>/wopcart/
cd <stage> && zip -qr wopcart-1.3.1.zip wopcart
git -C digital-cart worktree remove --force /tmp/wt
```

Gebaut am 2026-10-21: `wopcart-1.3.1.zip` (1,97 MB).
