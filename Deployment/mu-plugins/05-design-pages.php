<?php
/**
 * Two small site rules: the design class on the inner pages, and /pro/ → /direct/.
 *
 * The design CSS in 04-site-design.php is scoped to the wc-design body class,
 * which that file adds for the pages built in the September redesign. The docs,
 * pricing, support and FAQ pages, and the product pages, were rebuilt in the
 * same vocabulary on 2026-10-21 and need the same class.
 *
 * This is a separate file on purpose: a body_class filter only ever adds a
 * class, so it runs next to whatever 04-site-design.php already does, and
 * removing this one file undoes the change completely.
 *
 * @package WopCart\Site
 */

declare(strict_types=1);

add_filter(
	'body_class',
	static function ( array $classes ): array {
		$slugs = array(
			'pricing',
			'docs',
			'integrations',
			'why-wopcart',
			'support',
			'eu-vat',
			'plan-changes-refunds',
			'faq',
			'software-licensing',
			'direct',
		);

		// Product pages and the product archive carry the same content vocabulary.
		$wanted = ( is_singular( 'wopcart_product' ) || is_post_type_archive( 'wopcart_product' ) )
			|| ( is_page() && in_array( get_post_field( 'post_name', get_queried_object_id() ), $slugs, true ) );

		if ( $wanted && ! in_array( 'wc-design', $classes, true ) ) {
			$classes[] = 'wc-design';
		}

		return $classes;
	}
);

/**
 * Send /pro/ to /direct/.
 *
 * The edition was called "Pro" for a while. The name was dropped because it
 * promises more features while the free plugin is complete, and because
 * WordPress.org does not accept that story — but the address was published, so
 * it has to lead somewhere rather than to a 404.
 *
 * It lives in this file instead of its own because every mu-plugin here is bind
 * mounted into the container one file at a time; a new file means editing
 * docker-compose.yml and recreating the web container, which is a poor trade for
 * one redirect.
 *
 * 301 on purpose: the move is permanent, so search engines should forget /pro/.
 * It runs on `template_redirect`, early, and only for a request that would
 * otherwise 404 — a real page at that slug would always win.
 */
add_action(
	'template_redirect',
	static function (): void {
		$path = (string) wp_parse_url( (string) ( $_SERVER['REQUEST_URI'] ?? '' ), PHP_URL_PATH );

		if ( '/pro' !== untrailingslashit( $path ) ) {
			return;
		}

		if ( ! is_404() ) {
			return;
		}

		wp_safe_redirect( home_url( '/direct/' ), 301 );
		exit;
	},
	1
);
