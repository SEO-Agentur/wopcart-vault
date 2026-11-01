<?php
/**
 * Push page content, product content, the header template part and the design
 * body class from the vault copies. Runs inside the web container, as www-data.
 *
 * Everything it replaces is backed up next to the uploaded file as
 * <name>.bak.html, so the previous content can be restored by hand.
 *
 * Reads /tmp/wc-pages/slugs.txt, one entry per line:
 *   docs                -> page with that slug, from docs.html
 *   product:wopcart     -> wopcart_product with that slug, from product-wopcart.html
 *
 * A file may carry a title directive on its first line, which renames the post:
 *   <!-- wc:title WopCart Direct -->
 *
 * header.html is optional and updates the header template part.
 */

define( 'WP_USE_THEMES', false );
require '/var/www/html/wp-load.php';
kses_remove_filters();

$dir     = '/tmp/wc-pages';
$entries = array_values( array_filter( array_map( 'trim', file( $dir . '/slugs.txt' ) ) ) );

/**
 * Split a file into its optional title directive and its content.
 *
 * @param string $file Absolute path.
 *
 * @return array{0:string,1:?string} Content and title, if any.
 */
function wc_push_read( string $file ): array {
	$raw   = (string) file_get_contents( $file );
	$title = null;

	if ( preg_match( '/^\s*<!--\s*wc:title\s+(.+?)\s*-->\s*/', $raw, $m ) ) {
		$title = $m[1];
		$raw   = (string) preg_replace( '/^\s*<!--\s*wc:title\s+.+?-->\s*/', '', $raw, 1 );
	}

	return array( $raw, $title );
}

foreach ( $entries as $entry ) {
	if ( 0 === strpos( $entry, 'product:' ) ) {
		$slug  = substr( $entry, strlen( 'product:' ) );
		$file  = $dir . '/product-' . $slug . '.html';
		$found = get_posts(
			array(
				'post_type'      => 'wopcart_product',
				'name'           => $slug,
				'posts_per_page' => 1,
				'post_status'    => 'any',
			)
		);
		$post  = $found ? $found[0] : null;
		$label = 'product-' . $slug;
	} else {
		$slug  = $entry;
		$file  = $dir . '/' . $slug . '.html';
		$post  = get_page_by_path( $slug );
		$label = $slug;
	}

	if ( ! is_readable( $file ) ) {
		echo $entry . ": übersprungen (Datei fehlt)\n";
		continue;
	}

	list( $content, $title ) = wc_push_read( $file );

	/*
	 * A page that does not exist yet is created rather than skipped. Until this
	 * existed, a new page in the vault could never reach the site: the script
	 * only ever replaced content, so /direct/ stayed a 404 no matter how often
	 * it was pushed. Products are deliberately not created here — a product
	 * carries prices, files and licence settings that do not belong in an HTML
	 * file, so it is set up in the admin and only its content comes from here.
	 */
	if ( ! $post ) {
		if ( str_starts_with( $entry, 'product:' ) ) {
			echo $entry . ": übersprungen (Produkt muss im Admin angelegt werden)\n";
			continue;
		}

		$new_id = wp_insert_post(
			array(
				'post_type'    => 'page',
				'post_name'    => $slug,
				'post_title'   => $title ?? ucwords( str_replace( '-', ' ', $slug ) ),
				'post_status'  => 'publish',
				'post_content' => $content,
				// Every redesigned page uses this template: the hero carries its own
				// heading, so a second title printed above it would duplicate it.
				'page_template' => 'page-no-title',
			),
			true
		);

		if ( is_wp_error( $new_id ) ) {
			echo $entry . ': FEHLER beim Anlegen ' . $new_id->get_error_message() . "\n";
			continue;
		}

		echo $entry . ': angelegt #' . $new_id . ' (' . get_permalink( (int) $new_id ) . ")\n";
		continue;
	}

	file_put_contents( $dir . '/' . $label . '.bak.html', $post->post_content );

	$update = array(
		'ID'           => $post->ID,
		'post_content' => $content,
	);

	if ( null !== $title && $title !== $post->post_title ) {
		$update['post_title'] = $title;
		echo $entry . ': Titel „' . $post->post_title . '“ → „' . $title . "“\n";
	}

	$result = wp_update_post( $update, true );

	echo $entry . ': ' . ( is_wp_error( $result ) ? 'FEHLER ' . $result->get_error_message() : 'aktualisiert #' . $post->ID ) . "\n";
}

// The header template part carries the primary navigation.
if ( is_readable( $dir . '/header.html' ) ) {
	$parts = get_posts(
		array(
			'post_type'      => 'wp_template_part',
			'name'           => 'header',
			'posts_per_page' => 1,
			'post_status'    => 'any',
		)
	);

	if ( $parts ) {
		file_put_contents( $dir . '/header.bak.html', $parts[0]->post_content );
		$result = wp_update_post(
			array(
				'ID'           => $parts[0]->ID,
				'post_content' => file_get_contents( $dir . '/header.html' ),
			),
			true
		);
		echo 'header: ' . ( is_wp_error( $result ) ? 'FEHLER ' . $result->get_error_message() : 'aktualisiert #' . $parts[0]->ID ) . "\n";
	} else {
		echo "header: kein Template-Part in der Datenbank, die Theme-Datei ist in Benutzung\n";
	}
}

// The design styles are scoped to the wc-design body class. Report how it is set
// today, so a missing page can be traced quickly.
$design = '/var/www/html/wp-content/mu-plugins/05-design-pages.php';
echo "\n05-design-pages.php: " . ( is_readable( $design ) ? "eingehängt\n" : "FEHLT — die Seiten erscheinen ohne Design\n" );
