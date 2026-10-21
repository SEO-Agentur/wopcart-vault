#!/usr/bin/env bash
# Build WopCart per .distignore, ship it to wopcart.com, swap the plugin folder atomically,
# verify WordPress still loads and the site answers 200, roll back automatically otherwise.
set -euo pipefail

SRC=/Users/cyrusbadde/projects/plugins/digital-cart
S=/private/tmp/claude-502/-Users-cyrusbadde-projects-plugins/1dabc567-ff59-4374-9daf-3dddb49691d3/scratchpad
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
[ "${ALLOW_SAME_VERSION:-0}" = 1 ] || [ "${META_ONLY:-0}" = 1 ] || [ "$LIVE" != "$VERSION" ] || { echo "version $VERSION is already live — bump it first"; exit 1; }
echo "release: live=$LIVE -> new=$VERSION"

# Update metadata for the plan product (#14): installed copies compare against
# _wopcart_software_version, so without it they never see an update.
META_B64=$(SRC="$SRC" VERSION="$VERSION" python3 - <<'PY'
import base64, html, json, os, re
src, version = os.environ["SRC"], os.environ["VERSION"]
readme = open(os.path.join(src, "readme.txt"), encoding="utf-8").read()
header = open(os.path.join(src, "wopcart.php"), encoding="utf-8").read()
def field(text, name):
    m = re.search(r"^[ \t*]*" + re.escape(name) + r":\s*(.+)$", text, re.M)
    return m.group(1).strip() if m else ""
log = readme.split("== Changelog ==", 1)[1].split("== Upgrade Notice ==", 1)[0]
m = re.search(r"^= " + re.escape(version) + r" =\n(.*?)(?:\n= |\Z)", log, re.M | re.S)
items = [l[2:].strip() for l in (m.group(1) if m else "").splitlines() if l.startswith("* ")]
meta = {
    "_wopcart_software_version": version,
    "_wopcart_software_requires": field(readme, "Requires at least"),
    "_wopcart_software_tested": field(readme, "Tested up to"),
    "_wopcart_software_requires_php": field(readme, "Requires PHP"),
    "_wopcart_software_author": field(header, "Author"),
    "_wopcart_software_changelog": "<h4>" + version + "</h4><ul>" + "".join("<li>" + html.escape(i) + "</li>" for i in items) + "</ul>",
}
print(base64.b64encode(json.dumps(meta).encode()).decode())
PY
)

write_meta() {
  ssh -i "$KEY" "$HOST" "docker exec -e META_B64=$META_B64 -u www-data -w /var/www/html wopcart-web php -r '
    define(\"WP_USE_THEMES\", false); require \"wp-load.php\";
    foreach ( json_decode( base64_decode( getenv( \"META_B64\" ) ), true ) as \$k => \$v ) { update_post_meta( 14, \$k, wp_slash( \$v ) ); }
    echo \"product 14 update metadata: \" . get_post_meta( 14, \"_wopcart_software_version\", true ) . PHP_EOL;
  '"
}

if [ "${META_ONLY:-0}" = 1 ]; then
  [ "$LIVE" = "$VERSION" ] || { echo "META_ONLY needs the live version ($LIVE) to match $VERSION"; exit 1; }
  write_meta
  exit 0
fi

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
  # Point the plan product's download at the new build so buyers get this version.
  docker exec -u www-data -w /var/www/html wopcart-web php -r '
    define("WP_USE_THEMES", false); require "wp-load.php";
    $f = get_post_meta( 14, "_wopcart_files", true );
    if ( is_array( $f ) && isset( $f["file_0"] ) ) { $f["file_0"]["file"] = "wopcart-protected/wopcart-'"$VERSION"'.zip"; update_post_meta( 14, "_wopcart_files", $f ); }
  ' 2>/dev/null
  echo "product file replaced (wopcart-$VERSION.zip)"
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

# Installed copies learn about this version from the product's update metadata.
write_meta
