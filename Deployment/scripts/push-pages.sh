#!/usr/bin/env bash
# Publish page content and the header navigation from the vault to wopcart.com.
#
#   bash push-pages.sh                       # every redesigned page, the product and the header
#   bash push-pages.sh pricing docs          # only these slugs, no header
#   bash push-pages.sh product:wopcart       # only the product
#
# Each replaced page is backed up inside the web container as
# /tmp/wc-pages/<slug>.bak.html, the header as header.bak.html.
set -euo pipefail

DIR=$(cd "$(dirname "$0")" && pwd)
WEB=/Users/cyrusbadde/projects/plugins/digital-cart-vault/Website
KEY=~/.ssh/seowebsitesbuilder_vps
HOST=root@187.77.74.66

DEFAULT=(pricing docs integrations why-wopcart support eu-vat plan-changes-refunds faq software-licensing roadmap changelog product:wopcart)
if [ "$#" -gt 0 ]; then
	SLUGS=("$@")
	WITH_HEADER=0
else
	SLUGS=("${DEFAULT[@]}")
	WITH_HEADER=1
fi

STAGE=$(mktemp -d)
for slug in "${SLUGS[@]}"; do
	case "$slug" in
		product:*)
			# Product content lives beside the page folder, named product-<slug>.html.
			src="$WEB/product-${slug#product:}.html"
			;;
		*)
			src="$WEB/pages/$slug.html"
			;;
	esac
	[ -f "$src" ] || { echo "fehlt: $src"; exit 1; }
	cp "$src" "$STAGE/"
	echo "$slug" >> "$STAGE/slugs.txt"
done
[ "$WITH_HEADER" = 1 ] && cp "$WEB/parts/header.html" "$STAGE/"
cp "$DIR/push-pages.php" "$STAGE/"

ssh -i "$KEY" "$HOST" 'rm -rf /tmp/wc-pages && mkdir -p /tmp/wc-pages'
scp -q -i "$KEY" "$STAGE"/* "$HOST:/tmp/wc-pages/"
rm -rf "$STAGE"

ssh -i "$KEY" "$HOST" 'set -e
docker exec wopcart-web rm -rf /tmp/wc-pages
docker cp /tmp/wc-pages wopcart-web:/tmp/wc-pages
docker exec wopcart-web chown -R www-data:www-data /tmp/wc-pages
docker exec -u www-data wopcart-web php /tmp/wc-pages/push-pages.php
echo
for p in $(cat /tmp/wc-pages/slugs.txt); do
	case "$p" in
		product:*) url="https://wopcart.com/products/${p#product:}/" ;;
		*)         url="https://wopcart.com/$p/" ;;
	esac
	echo "$p: HTTP $(curl -s -o /dev/null -w "%{http_code}" "$url")"
done
rm -rf /tmp/wc-pages'
