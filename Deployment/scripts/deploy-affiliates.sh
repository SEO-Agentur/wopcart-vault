#!/usr/bin/env bash
# Install or update the WopCart Affiliates add-on on wopcart.com.
#
# Builds per .distignore, uploads, swaps the plugin folder atomically, activates
# it, checks WordPress still loads, the add-on's tables exist and the site
# answers 200, and rolls back automatically otherwise.
#
# It never switches the affiliate program on: activation only creates the
# tables. Turning the program on (WopCart → Settings → Affiliates) is a separate
# decision, together with the commission rates and the terms on /affiliates/.
#
#   bash deploy-affiliates.sh
set -euo pipefail

SRC=/Users/cyrusbadde/projects/plugins/wopcart-affiliates
S="${DEPLOY_TMP:-$(mktemp -d)}"
KEY=~/.ssh/seowebsitesbuilder_vps
HOST=root@187.77.74.66
STAMP=$(date -u +%Y%m%d-%H%M%S)

VERSION=$(grep -m1 "Version:" "$SRC/wopcart-affiliates.php" | awk '{print $NF}')
CONST=$(grep -m1 "const VERSION" "$SRC/wopcart-affiliates.php" | sed -E "s/.*'([^']+)'.*/\1/")
STABLE=$(grep -m1 "Stable tag:" "$SRC/readme.txt" | awk '{print $NF}')
MINCORE=$(grep -m1 "const MIN_CORE" "$SRC/wopcart-affiliates.php" | sed -E "s/.*'([^']+)'.*/\1/")
[ "$VERSION" = "$CONST" ] && [ "$VERSION" = "$STABLE" ] || { echo "version mismatch: header=$VERSION const=$CONST stable=$STABLE"; exit 1; }
grep -q "^= $VERSION =" "$SRC/readme.txt" || { echo "readme.txt changelog has no entry for $VERSION"; exit 1; }
[ -z "$(git -C "$SRC" status --porcelain)" ] || { echo "uncommitted changes in $SRC — commit first"; exit 1; }

LIVE=$(ssh -i "$KEY" "$HOST" "docker exec wopcart-web sh -c \"grep -m1 'Version:' /var/www/html/wp-content/plugins/wopcart-affiliates/wopcart-affiliates.php 2>/dev/null | awk '{print \\\$NF}'\"" 2>/dev/null || true)
CORE=$(ssh -i "$KEY" "$HOST" "docker exec wopcart-web sh -c \"grep -m1 'Version:' /var/www/html/wp-content/plugins/wopcart/wopcart.php | awk '{print \\\$NF}'\"")
[ "${ALLOW_SAME_VERSION:-0}" = 1 ] || [ "$LIVE" != "$VERSION" ] || { echo "WopCart Affiliates $VERSION is already live — bump it first"; exit 1; }
python3 -c "import sys; v=lambda s: tuple(int(x) for x in s.split('.')); sys.exit(0 if v('$CORE') >= v('$MINCORE') else 1)" \
  || { echo "wopcart.com runs WopCart $CORE, the add-on needs $MINCORE"; exit 1; }
echo "WopCart Affiliates: live=${LIVE:-not installed} -> new=$VERSION (core $CORE, needs $MINCORE)"

rm -rf "$S/dist" && mkdir -p "$S/dist/wopcart-affiliates"
rsync -a --exclude-from=<(grep -v -E '^\s*(#|$)' "$SRC/.distignore") --exclude .DS_Store "$SRC/" "$S/dist/wopcart-affiliates/"
(cd "$S/dist" && zip -qr wopcart-affiliates.zip wopcart-affiliates)
SHA=$(shasum -a 256 "$S/dist/wopcart-affiliates.zip" | awk '{print $1}')
echo "build: $(find "$S/dist/wopcart-affiliates" -type f | wc -l | tr -d ' ') files, sha256 $SHA"

if unzip -l "$S/dist/wopcart-affiliates.zip" | grep -qE "phpunit|/tests/|phpcs"; then
  echo "refusing to ship: the zip carries development files"
  exit 1
fi

scp -q -i "$KEY" "$S/dist/wopcart-affiliates.zip" "$HOST:/opt/wopcart/wopcart-affiliates-$VERSION-$STAMP.zip"

ssh -i "$KEY" "$HOST" "VERSION=$VERSION STAMP=$STAMP SHA=$SHA bash -s" <<'REMOTE'
set -euo pipefail
cd /opt/wopcart
ZIP=wopcart-affiliates-$VERSION-$STAMP.zip
echo "$SHA  $ZIP" | sha256sum -c --quiet
chmod 600 "$ZIP"

P=/var/www/html/wp-content/plugins
rm -rf /tmp/wca-new && mkdir /tmp/wca-new && unzip -q "$ZIP" -d /tmp/wca-new
docker exec wopcart-web rm -rf $P/wopcart-affiliates-new
docker cp /tmp/wca-new/wopcart-affiliates wopcart-web:$P/wopcart-affiliates-new
rm -rf /tmp/wca-new
docker exec wopcart-web chown -R www-data:www-data $P/wopcart-affiliates-new

bad=$(docker exec wopcart-web sh -c "find $P/wopcart-affiliates-new -name '*.php' -exec php -l {} \; 2>&1 | grep -vc 'No syntax errors'" || true)
[ "$bad" = "0" ] || { echo "syntax errors: $bad"; docker exec wopcart-web rm -rf $P/wopcart-affiliates-new; exit 1; }

FIRST=0
if docker exec wopcart-web test -d $P/wopcart-affiliates; then
  docker exec wopcart-web sh -c "rm -rf $P/wopcart-affiliates-prev && mv $P/wopcart-affiliates $P/wopcart-affiliates-prev && mv $P/wopcart-affiliates-new $P/wopcart-affiliates"
else
  FIRST=1
  docker exec wopcart-web mv $P/wopcart-affiliates-new $P/wopcart-affiliates
fi

# Activate (runs the activation hook: tables + daily job). The program itself stays off.
docker exec -u www-data -w /var/www/html wopcart-web php -r '
  define("WP_USE_THEMES", false); require "wp-load.php";
  require_once ABSPATH . "wp-admin/includes/plugin.php";
  $r = activate_plugin( "wopcart-affiliates/wopcart-affiliates.php" );
  if ( is_wp_error( $r ) ) { fwrite( STDERR, $r->get_error_message() . PHP_EOL ); exit( 1 ); }
' || true

check() {
  docker exec -u www-data -w /var/www/html wopcart-web php -r '
    define("WP_USE_THEMES", false); require "wp-load.php";
    require_once ABSPATH . "wp-admin/includes/plugin.php";
    global $wpdb;
    if ( ! is_plugin_active( "wopcart-affiliates/wopcart-affiliates.php" ) || ! class_exists( "WopCartAffiliates\\Plugin" ) || ! \WopCartAffiliates\Plugin::active() ) { echo "add-on not active" . PHP_EOL; exit( 1 ); }
    $tables = (int) $wpdb->get_var( "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name LIKE \"" . $wpdb->prefix . "wopcart\\_aff\\_%\"" );
    if ( 5 !== $tables ) { echo "tables: $tables of 5" . PHP_EOL; exit( 1 ); }
    echo "add-on " . \WopCartAffiliates\VERSION . " active, 5 tables, program " . ( \WopCartAffiliates\Plugin::enabled() ? "ON" : "off" ) . PHP_EOL;
  ' && [ "$(curl -s -o /dev/null -w '%{http_code}' https://wopcart.com/)" = 200 ] \
    && [ "$(curl -s -o /dev/null -w '%{http_code}' https://wopcart.com/products/wopcart/)" = 200 ]
}

if check; then
  echo "deploy ok: WopCart Affiliates $VERSION ($STAMP)"
  if [ "$FIRST" = 0 ]; then
    mkdir -p rollback && chmod 700 rollback
    docker cp wopcart-web:$P/wopcart-affiliates-prev rollback/wopcart-affiliates-prev-$STAMP && docker exec wopcart-web rm -rf $P/wopcart-affiliates-prev
    echo "rollback copy: /opt/wopcart/rollback/wopcart-affiliates-prev-$STAMP"
  fi
  docker logs --since 2m wopcart-web 2>&1 | grep -i -E "php (fatal|warning|parse)" | tail -5 || true
else
  echo "CHECK FAILED — rolling back"
  docker exec -u www-data -w /var/www/html wopcart-web php -r 'define("WP_USE_THEMES", false); require "wp-load.php"; require_once ABSPATH . "wp-admin/includes/plugin.php"; deactivate_plugins( "wopcart-affiliates/wopcart-affiliates.php", true );' || true
  docker exec wopcart-web sh -c "rm -rf $P/wopcart-affiliates-failed && mv $P/wopcart-affiliates $P/wopcart-affiliates-failed"
  if [ "$FIRST" = 0 ]; then
    docker exec wopcart-web mv $P/wopcart-affiliates-prev $P/wopcart-affiliates
    docker exec -u www-data -w /var/www/html wopcart-web php -r 'define("WP_USE_THEMES", false); require "wp-load.php"; require_once ABSPATH . "wp-admin/includes/plugin.php"; activate_plugin( "wopcart-affiliates/wopcart-affiliates.php" );' || true
  fi
  docker logs --since 2m wopcart-web 2>&1 | tail -20
  exit 1
fi
REMOTE
