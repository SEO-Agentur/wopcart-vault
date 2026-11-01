#!/usr/bin/env bash
# Build WopCart per .distignore, ship it to wopcart.com, swap the plugin folder atomically,
# verify WordPress still loads and the site answers 200, roll back automatically otherwise.
#
# This deploys the FREE plugin only. The paid add-on has its own script,
# deploy-direct.sh, which owns product 14's download and its update metadata.
set -euo pipefail

SRC=/Users/cyrusbadde/projects/plugins/digital-cart
# Build directory. A session's scratchpad path was hardcoded here once and went
# stale the moment that session ended, so it is a fresh temp dir unless the
# caller names one.
S="${DEPLOY_TMP:-$(mktemp -d)}"
KEY=~/.ssh/seowebsitesbuilder_vps
HOST=root@187.77.74.66
VERSION=$(grep -m1 "Version:" "$SRC/wopcart.php" | awk '{print $NF}')
STAMP=$(date -u +%Y%m%d-%H%M%S)

# Release rule (owner, 2026-09-14): every deploy ships a new version and updates /changelog/ + /roadmap/.
LIVE=$(ssh -i "$KEY" "$HOST" "docker exec wopcart-web sh -c \"grep -m1 'Version:' /var/www/html/wp-content/plugins/wopcart/wopcart.php | awk '{print \\\$NF}'\"" 2>/dev/null || true)
CONST=$(grep -m1 "const VERSION" "$SRC/wopcart.php" | sed -E "s/.*'([^']+)'.*/\1/")
STABLE=$(grep -m1 "Stable tag:" "$SRC/readme.txt" | awk '{print $NF}')
[ "$VERSION" = "$CONST" ] && [ "$VERSION" = "$STABLE" ] || { echo "version mismatch: header=$VERSION const=$CONST stable=$STABLE"; exit 1; }
grep -q "^= $VERSION =" "$SRC/readme.txt" || { echo "readme.txt changelog has no entry for $VERSION"; exit 1; }
grep -q "id=\"$(echo "$VERSION" | tr . -)\"" /Users/cyrusbadde/projects/plugins/digital-cart-vault/Website/pages/changelog.html || { echo "changelog page has no entry for $VERSION"; exit 1; }
[ "${ALLOW_SAME_VERSION:-0}" = 1 ] || [ "$LIVE" != "$VERSION" ] || { echo "version $VERSION is already live — bump it first"; exit 1; }
echo "release: live=$LIVE -> new=$VERSION"

# The update metadata of product 14 is NOT written here. That product sells
# WopCart Direct, and its _wopcart_software_* meta is what Direct's updater
# compares its own version against — writing the core's version into it told
# every paying installation that the add-on had jumped to 1.7.x. It is written
# by deploy-direct.sh, together with the add-on's own download.

rm -rf "$S/dist" && mkdir -p "$S/dist/wopcart"
rsync -a --exclude-from=<(grep -v -E '^\s*(#|$)' "$SRC/.distignore" | grep -v '^!') "$SRC/" "$S/dist/wopcart/"
cp "$SRC/readme.txt" "$S/dist/wopcart/"
(cd "$S/dist" && zip -qr wopcart.zip wopcart)
SHA=$(shasum -a 256 "$S/dist/wopcart.zip" | awk '{print $1}')
echo "build: $(find "$S/dist/wopcart" -type f | wc -l | tr -d ' ') files, sha256 $SHA"

scp -q -i "$KEY" "$S/dist/wopcart.zip" "$HOST:/opt/wopcart/wopcart-plugin-$VERSION-$STAMP.zip"

ssh -i "$KEY" "$HOST" "VERSION=$VERSION STAMP=$STAMP SHA=$SHA bash -s" <<'REMOTE'
set -euo pipefail
cd /opt/wopcart
ZIP=wopcart-plugin-$VERSION-$STAMP.zip
echo "$SHA  $ZIP" | sha256sum -c --quiet
chmod 600 "$ZIP"

P=/var/www/html/wp-content/plugins
rm -rf /tmp/wopcart-new && mkdir /tmp/wopcart-new && unzip -q "$ZIP" -d /tmp/wopcart-new
docker exec wopcart-web rm -rf $P/wopcart-new
docker cp /tmp/wopcart-new/wopcart wopcart-web:$P/wopcart-new
rm -rf /tmp/wopcart-new
docker exec wopcart-web chown -R www-data:www-data $P/wopcart-new

bad=$(docker exec wopcart-web sh -c "find $P/wopcart-new -name '*.php' -exec php -l {} \; 2>&1 | grep -vc 'No syntax errors'" || true)
[ "$bad" = "0" ] || { echo "syntax errors: $bad"; exit 1; }

docker exec wopcart-web sh -c "rm -rf $P/wopcart-prev && mv $P/wopcart $P/wopcart-prev && mv $P/wopcart-new $P/wopcart"

check() {
  docker exec -u www-data -w /var/www/html wopcart-web php -r '
    define("WP_USE_THEMES", false); require "wp-load.php";
    require_once ABSPATH . "wp-admin/includes/plugin.php";
    if ( ! is_plugin_active( "wopcart/wopcart.php" ) || ! class_exists( "WopCart\\Plugin" ) ) { exit( 1 ); }
    $routes = rest_get_server()->get_routes();
    echo "rest plan/check: " . ( isset( $routes["/wopcart/v1/plan/check"] ) ? "yes" : "no" ) . PHP_EOL;
  ' && [ "$(curl -s -o /dev/null -w '%{http_code}' https://wopcart.com/)" = 200 ] \
    && [ "$(curl -s -o /dev/null -w '%{http_code}' https://wopcart.com/products/wopcart/)" = 200 ]
}

if check; then
  echo "deploy ok: $VERSION ($STAMP)"
  # Buyers download the current build.
  docker cp "$ZIP" wopcart-web:/var/www/html/wp-content/uploads/wopcart-protected/wopcart-$VERSION.zip
  docker exec wopcart-web sh -c "chown www-data:www-data /var/www/html/wp-content/uploads/wopcart-protected/wopcart-$VERSION.zip && chmod 640 /var/www/html/wp-content/uploads/wopcart-protected/wopcart-$VERSION.zip"
  # Refresh the bonus copy of the free plugin on the paid product, and nothing
  # else. Product 14 sells WopCart *Direct*; until 2026-11-01 this step pointed
  # file_0 at the core zip, so a buyer paid for the add-on and downloaded the
  # free plugin. The add-on's own file and its update metadata are written by
  # deploy-direct.sh, which is the only script allowed to touch them.
  docker exec -e VERSION="$VERSION" -u www-data -w /var/www/html wopcart-web php -r '
    define("WP_USE_THEMES", false); require "wp-load.php";
    $version = getenv("VERSION");
    $files   = (array) get_post_meta( 14, "_wopcart_files", true );
    $done    = false;

    foreach ( $files as $k => $row ) {
      if ( isset( $row["file"] ) && preg_match( "#wopcart-protected/wopcart-[0-9]#", (string) $row["file"] ) ) {
        $files[ $k ]["file"] = "wopcart-protected/wopcart-" . $version . ".zip";
        $done                = true;
      }
    }

    if ( ! $done ) {
      $files["file_" . count( $files )] = array(
        "name"      => "WopCart plugin (zip) — required, until it is on WordPress.org",
        "file"      => "wopcart-protected/wopcart-" . $version . ".zip",
        "condition" => "all",
      );
    }

    update_post_meta( 14, "_wopcart_files", $files );
    echo "bonus copy of the free plugin: wopcart-" . $version . ".zip" . PHP_EOL;
  ' 2>/dev/null
  # Keep the previous build as a rollback copy outside wp-content/plugins, where it would list as a second WopCart.
  mkdir -p rollback && chmod 700 rollback
  docker cp wopcart-web:$P/wopcart-prev rollback/wopcart-prev-$STAMP && docker exec wopcart-web rm -rf $P/wopcart-prev
  echo "rollback copy: /opt/wopcart/rollback/wopcart-prev-$STAMP"
  docker logs --since 2m wopcart-web 2>&1 | grep -i -E "php (fatal|warning|parse)" | tail -5 || true
else
  echo "CHECK FAILED — rolling back"
  docker exec wopcart-web sh -c "rm -rf $P/wopcart-failed && mv $P/wopcart $P/wopcart-failed && mv $P/wopcart-prev $P/wopcart"
  docker logs --since 2m wopcart-web 2>&1 | tail -20
  exit 1
fi
REMOTE
