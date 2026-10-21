<?php
/**
 * Put the inner pages into the site design.
 *
 * The design CSS in 04-site-design.php is scoped to the wc-design body class,
 * which that file adds for the pages built in the September redesign. The docs,
 * pricing and support pages were rebuilt in the same vocabulary on 2026-10-21
 * and need the same class.
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
		);

		if ( ! is_page() ) {
			return $classes;
		}

		$slug = get_post_field( 'post_name', get_queried_object_id() );

		if ( in_array( $slug, $slugs, true ) && ! in_array( 'wc-design', $classes, true ) ) {
			$classes[] = 'wc-design';
		}

		return $classes;
	}
);
