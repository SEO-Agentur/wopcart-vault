<?php
// Push only the changelog and roadmap page content from the vault copies.
define( 'WP_USE_THEMES', false );
require '/var/www/html/wp-load.php';
kses_remove_filters();
foreach ( array( 'changelog', 'roadmap' ) as $slug ) {
	$page = get_page_by_path( $slug );
	$file = '/tmp/release-pages/' . $slug . '.html';
	if ( ! $page || ! is_readable( $file ) ) {
		echo "$slug: skipped\n";
		continue;
	}
	file_put_contents( '/tmp/release-pages/' . $slug . '.bak.html', $page->post_content );
	$r = wp_update_post( array( 'ID' => $page->ID, 'post_content' => file_get_contents( $file ) ), true );
	echo $slug . ': ' . ( is_wp_error( $r ) ? 'ERROR ' . $r->get_error_message() : 'updated #' . $page->ID ) . "\n";
}
