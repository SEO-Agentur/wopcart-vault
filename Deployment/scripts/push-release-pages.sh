#!/usr/bin/env bash
# Publish the vault's changelog and roadmap pages to wopcart.com.
# Updates only those two pages; the previous content is kept on the server as
# /tmp/release-pages/<slug>.bak.html inside the web container.
set -euo pipefail

DIR=$(cd "$(dirname "$0")" && pwd)
PAGES=/Users/cyrusbadde/projects/plugins/digital-cart-vault/Website/pages
KEY=~/.ssh/seowebsitesbuilder_vps
HOST=root@187.77.74.66

grep -q 'RELEASE_DATE' "$PAGES/changelog.html" && { echo "changelog.html still contains RELEASE_DATE — set the date first"; exit 1; }

ssh -i "$KEY" "$HOST" 'rm -rf /tmp/release-pages && mkdir -p /tmp/release-pages'
scp -q -i "$KEY" "$PAGES/changelog.html" "$PAGES/roadmap.html" "$DIR/push-release-pages.php" "$HOST:/tmp/release-pages/"

ssh -i "$KEY" "$HOST" 'set -e
docker exec wopcart-web rm -rf /tmp/release-pages
docker cp /tmp/release-pages wopcart-web:/tmp/release-pages
docker exec wopcart-web chown -R www-data:www-data /tmp/release-pages
docker exec -u www-data wopcart-web php /tmp/release-pages/push-release-pages.php
for p in changelog roadmap; do echo "$p: HTTP $(curl -s -o /dev/null -w "%{http_code}" https://wopcart.com/$p/)"; done
rm -rf /tmp/release-pages'
