#!/usr/bin/env bash
# Everything the website needs after a plugin release, in one run:
#
#   1. the three mu-plugins that are managed from the vault
#   2. every page, the product, the header and the manifest metadata
#   3. the settings that only exist in the database
#
# Each step is skipped cleanly when it has nothing to do, so running this twice
# costs nothing. Written because the alternative was four commands in a chat
# message, which is where a step gets forgotten.
set -euo pipefail

DIR=$(cd "$(dirname "$0")" && pwd)
VAULT=/Users/cyrusbadde/projects/plugins/digital-cart-vault
KEY=~/.ssh/seowebsitesbuilder_vps
HOST=root@187.77.74.66
STAMP=$(date -u +%Y%m%d-%H%M%S)

echo "== 1. mu-plugins =="
for f in 04-site-design.php 05-design-pages.php 06-connect-controller.php; do
	src="$VAULT/Deployment/mu-plugins/$f"
	[ -f "$src" ] || { echo "   $f fehlt im Vault — übersprungen"; continue; }

	php -l "$src" > /dev/null
	ssh -i "$KEY" "$HOST" "cp /opt/wopcart/mu-plugins/$f /opt/wopcart/mu-plugins/$f.bak-$STAMP 2>/dev/null || true"
	scp -q -i "$KEY" "$src" "$HOST:/opt/wopcart/mu-plugins/$f"
	# The files are bind mounted, so the host copy is what the container reads.
	ssh -i "$KEY" "$HOST" "docker exec wopcart-web php -l /var/www/html/wp-content/mu-plugins/$f > /dev/null && echo '   $f ok'"
done

echo "== 2. Seiten, Produkt, Kopfbereich und Manifest =="
bash "$DIR/push-pages.sh"

echo "== 3. Einstellungen =="
ssh -i "$KEY" "$HOST" 'docker exec -u www-data -w /var/www/html wopcart-web php -r "
  define( \"WP_USE_THEMES\", false ); require \"wp-load.php\";

  \$settings = (array) get_option( \"wopcart_settings\", array() );
  \$before   = \$settings;

  // The checkout sells WopCart Direct by itself; without this the express panel
  // never renders and a link to the checkout lands on an empty cart.
  \$settings[\"express_product\"] = 14;

  if ( \$settings !== \$before ) {
    update_option( \"wopcart_settings\", \$settings );
  }

  echo \"   express_product = \" . ( (array) get_option( \"wopcart_settings\", array() ) )[\"express_product\"] . PHP_EOL;

  // A purchase has to produce an account, or the buyer cannot reach the licence
  // they just paid for. 1.7.0 signs them in on their own receipt once it does.
  update_post_meta( 14, \"_wopcart_require_account\", 1 );
  update_post_meta( 14, \"_wopcart_button_text\", \"Get WopCart Direct\" );

  echo \"   Produkt 14: Konto erforderlich, Knopf \\\"\" . get_post_meta( 14, \"_wopcart_button_text\", true ) . \"\\\"\" . PHP_EOL;
"'

echo "== 4. Gegenprobe =="
for p in / /checkout/ /direct/ /my-account/ /products/wopcart/; do
	printf '   %-22s %s\n' "$p" "$(curl -s -o /dev/null -w '%{http_code}' "https://wopcart.com$p")"
done
