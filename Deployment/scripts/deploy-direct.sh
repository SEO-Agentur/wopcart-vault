#!/usr/bin/env bash
# Build WopCart Direct per .distignore, upload it to the protected folder on
# wopcart.com, point the product's download at it and write the update metadata
# that installed copies compare against.
#
# This exists because the paid product and the free plugin are two different
# downloads that happen to be sold through one product post. Until 2026-11-01 the
# core deploy wrote both of them, so a buyer who paid for the add-on downloaded
# the free plugin and its updater was told the add-on's version was 1.7.x. The
# core deploy now only refreshes the bonus copy of the free plugin; everything
# that describes the add-on is written here.
#
#   bash deploy-direct.sh            # build, upload, point the product at it
#   META_ONLY=1 bash deploy-direct.sh  # only rewrite the update metadata
set -euo pipefail

SRC=/Users/cyrusbadde/projects/plugins/wopcart-direct
S="${DEPLOY_TMP:-$(mktemp -d)}"
KEY=~/.ssh/seowebsitesbuilder_vps
HOST=root@187.77.74.66
PRODUCT=14
STAMP=$(date -u +%Y%m%d-%H%M%S)

VERSION=$(grep -m1 "Version:" "$SRC/wopcart-direct.php" | awk '{print $NF}')
CONST=$(grep -m1 "const VERSION" "$SRC/wopcart-direct.php" | sed -E "s/.*'([^']+)'.*/\1/")
[ "$VERSION" = "$CONST" ] || { echo "version mismatch: header=$VERSION const=$CONST"; exit 1; }
echo "WopCart Direct $VERSION"

# The add-on refuses to run without the free plugin, so the product has to ship
# both until the free plugin is on WordPress.org. The core deploy keeps the
# second entry current; this script never touches it.
META_B64=$(SRC="$SRC" VERSION="$VERSION" python3 - <<'PY'
import base64, html, json, os, re
src, version = os.environ["SRC"], os.environ["VERSION"]
header = open(os.path.join(src, "wopcart-direct.php"), encoding="utf-8").read()
def field(name):
    m = re.search(r"^[ \t*]*" + re.escape(name) + r":\s*(.+)$", header, re.M)
    return m.group(1).strip() if m else ""
notes = ""
readme = os.path.join(src, "README.md")
if os.path.exists(readme):
    text = open(readme, encoding="utf-8").read()
    m = re.search(r"^### " + re.escape(version) + r"\n(.*?)(?:\n### |\Z)", text, re.M | re.S)
    items = [l.lstrip("- ").strip() for l in (m.group(1) if m else "").splitlines() if l.startswith("- ")]
    notes = "<h4>" + version + "</h4><ul>" + "".join("<li>" + html.escape(i) + "</li>" for i in items) + "</ul>"
meta = {
    "_wopcart_software_version": version,
    "_wopcart_software_requires": field("Requires at least"),
    # The add-on runs wherever the free plugin runs, so it is tested against the
    # same WordPress. Kept as a literal because the add-on has no readme.txt.
    "_wopcart_software_tested": "7.1",
    "_wopcart_software_requires_php": field("Requires PHP"),
    "_wopcart_software_author": field("Author"),
    "_wopcart_software_changelog": notes,
}
print(base64.b64encode(json.dumps(meta).encode()).decode())
PY
)

write_meta() {
  ssh -i "$KEY" "$HOST" "docker exec -e META_B64=$META_B64 -u www-data -w /var/www/html wopcart-web php -r '
    define(\"WP_USE_THEMES\", false); require \"wp-load.php\";
    foreach ( json_decode( base64_decode( getenv( \"META_B64\" ) ), true ) as \$k => \$v ) { update_post_meta( $PRODUCT, \$k, wp_slash( \$v ) ); }
    echo \"product $PRODUCT update metadata: \" . get_post_meta( $PRODUCT, \"_wopcart_software_version\", true ) . PHP_EOL;
  '"
}

if [ "${META_ONLY:-0}" = 1 ]; then
  write_meta
  exit 0
fi

rm -rf "$S/dist" && mkdir -p "$S/dist/wopcart-direct"
rsync -a --exclude-from=<(grep -v -E '^\s*(#|$)' "$SRC/.distignore") "$SRC/" "$S/dist/wopcart-direct/"
(cd "$S/dist" && zip -qr wopcart-direct.zip wopcart-direct)
SHA=$(shasum -a 256 "$S/dist/wopcart-direct.zip" | awk '{print $1}')
echo "build: $(find "$S/dist/wopcart-direct" -type f | wc -l | tr -d ' ') files, sha256 $SHA"

# A buyer must never receive the development scaffolding, and the suite is the
# one thing in there that names internal paths.
if unzip -l "$S/dist/wopcart-direct.zip" | grep -qE "phpunit|/tests/"; then
  echo "refusing to ship: the zip carries test scaffolding"
  exit 1
fi

scp -q -i "$KEY" "$S/dist/wopcart-direct.zip" "$HOST:/opt/wopcart/wopcart-direct-$VERSION-$STAMP.zip"

ssh -i "$KEY" "$HOST" "VERSION=$VERSION STAMP=$STAMP SHA=$SHA PRODUCT=$PRODUCT bash -s" <<'REMOTE'
set -euo pipefail
cd /opt/wopcart
ZIP=wopcart-direct-$VERSION-$STAMP.zip
echo "$SHA  $ZIP" | sha256sum -c --quiet
chmod 600 "$ZIP"

P=/var/www/html/wp-content/uploads/wopcart-protected
docker cp "$ZIP" wopcart-web:$P/wopcart-direct-$VERSION.zip
docker exec wopcart-web sh -c "chown www-data:www-data $P/wopcart-direct-$VERSION.zip && chmod 640 $P/wopcart-direct-$VERSION.zip"

# The add-on is the thing that was bought, so it is the first file. The free
# plugin stays beside it, because the add-on cannot be activated without it.
docker exec -e VERSION="$VERSION" -u www-data -w /var/www/html wopcart-web php -r '
  define("WP_USE_THEMES", false); require "wp-load.php";
  $version = getenv("VERSION");
  $files   = (array) get_post_meta( '"$PRODUCT"', "_wopcart_files", true );
  $core    = null;

  foreach ( $files as $row ) {
    if ( isset( $row["file"] ) && preg_match( "#wopcart-protected/wopcart-[0-9]#", (string) $row["file"] ) ) {
      $core = $row;
    }
  }

  /*
   * Every row carries its own id, and the id has to match the key. Product::files()
   * reads `$row["id"] ?? "file_" . $index` and keys the result by that, so a row
   * that kept an id from the slot it used to sit in silently takes the place of
   * the other row: moving the old core row to file_1 while it still said
   * id=file_0 left the product delivering one file instead of two.
   */
  $out = array(
    "file_0" => array(
      "id"            => "file_0",
      "name"          => "WopCart Direct (zip)",
      "file"          => "wopcart-protected/wopcart-direct-" . $version . ".zip",
      "attachment_id" => 0,
      // Empty means every price option unlocks it, which is what each size buys.
      "price_ids"     => array(),
    ),
  );

  if ( null !== $core ) {
    $core["id"]    = "file_1";
    $core["name"]  = "WopCart plugin (zip) — required, until it is on WordPress.org";
    $out["file_1"] = $core;
  }

  update_post_meta( '"$PRODUCT"', "_wopcart_files", $out );

  // Read it back the way a buyer does, not the way it was written: the model
  // re-keys the rows, and that is where this went wrong once already.
  $product = \WopCart\Model\Product::find( '"$PRODUCT"' );

  foreach ( array_keys( (array) $product->prices() ) as $option ) {
    $names = array();

    foreach ( $product->files( (string) $option ) as $file ) {
      $names[] = $file["file"];
    }

    echo "  " . $option . ": " . ( array() === $names ? "KEINE DATEI" : implode( " + ", $names ) ) . PHP_EOL;
  }
'
REMOTE

write_meta
echo "done: buyers of product $PRODUCT now download WopCart Direct $VERSION"
