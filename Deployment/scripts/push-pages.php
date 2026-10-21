<?php
/**
 * Push page content, the header template part and the design body class from the
 * vault copies. Runs inside the web container, as www-data.
 *
 * Every page it replaces is backed up next to the uploaded file as
 * <slug>.bak.html, so the previous content can be restored by hand.
 *
 * Reads /tmp/wc-pages/slugs.txt, one slug per line, and expects <slug>.html
 * beside it. header.html is optional and updates the header template part.
 */

define( 'WP_USE_THEMES', false );
require '/var/www/html/wp-load.php';
kses_remove_filters();

$dir   = '/tmp/wc-pages';
$slugs = array_values( array_filter( array_map( 'trim', file( $dir . '/slugs.txt' ) ) ) );

foreach ( $slugs as $slug ) {
	$page = get_page_by_path( $slug );
	$file = $dir . '/' . $slug . '.html';

	if ( ! $page || ! is_readable( $file ) ) {
		echo $slug . ": übersprungen (Seite oder Datei fehlt)\n";
		continue;
	}

	file_put_contents( $dir . '/' . $slug . '.bak.html', $page->post_content );

	$result = wp_update_post(
		array(
			'ID'           => $page->ID,
			'post_content' => file_get_contents( $file ),
		),
		true
	);

	echo $slug . ': ' . ( is_wp_error( $result ) ? 'FEHLER ' . $result->get_error_message() : 'aktualisiert #' . $page->ID ) . "\n";
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
		echo "header: kein Template-Part in der Datenbank, Theme-Datei in Benutzung\n";
	}
}

// The design styles are scoped to the wc-design body class. Report how it is set
// today, so the inner pages can be added to whatever list drives it.
$design = '/var/www/html/wp-content/mu-plugins/04-site-design.php';
if ( is_readable( $design ) ) {
	echo "\n===== Design-Klasse: Zeilen aus 04-site-design.php =====\n";
	foreach ( file( $design ) as $i => $line ) {
		if ( preg_match( '/body_class|wc-design|slug|in_array|post_name/', $line ) && false === strpos( $line, '{' ) || preg_match( '/body_class|in_array/', $line ) ) {
			echo ( $i + 1 ) . ': ' . rtrim( $line ) . "\n";
		}
	}
}
