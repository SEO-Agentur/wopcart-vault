<?php
/**
 * Finish what the 1.7.0 fatal interrupted on order #10 (wopcart.com, 2026-11-01).
 *
 * The crash landed inside Fulfillment::maybe_create_account() right after the
 * account row was written, so everything from that line on never ran: the meta
 * that marks the account as WopCart's own, the guest-membership link, the
 * customer record, the "set your password" mail, and — the part the buyer
 * actually paid for — the `wopcart_order_complete` action, which is where the
 * licence key and the receipt come from.
 *
 * Deliberately NOT a re-run of Fulfillment::run(): the steps before the crash
 * (sales counters, subscription, stock commit) all succeeded, and the fulfilment
 * flag is set, so a re-run would either return early or double-count the sale.
 *
 * Run it once, on the server:
 *
 *   scp -i ~/.ssh/seowebsitesbuilder_vps \
 *     ~/projects/plugins/digital-cart-vault/Deployment/repair-order-10-20261101.php \
 *     root@187.77.74.66:/opt/wopcart/
 *   ssh -i ~/.ssh/seowebsitesbuilder_vps root@187.77.74.66 \
 *     'docker cp /opt/wopcart/repair-order-10-20261101.php wopcart-web:/tmp/repair.php \
 *      && docker exec -u www-data -w /var/www/html wopcart-web php /tmp/repair.php \
 *      && docker exec wopcart-web rm -f /tmp/repair.php \
 *      && rm -f /opt/wopcart/repair-order-10-20261101.php'
 *
 * Deploy 1.7.2 first — not because this script needs it (it names the class in
 * full), but because every further order crashes the same way until it is live.
 *
 * @package WopCart\Site
 */

declare(strict_types=1);

define( 'WP_USE_THEMES', false );
require '/var/www/html/wp-load.php';

$order = WopCart\Model\Order::find( 10 );

if ( null === $order ) {
	exit( "order 10 not found\n" );
}

$uid   = $order->user_id();
$email = $order->email();

if ( $uid < 1 ) {
	exit( "order 10 has no account\n" );
}

echo 'order #' . $order->id() . ', account ' . $uid . ' (' . $email . ")\n";

\WopCart\Accounts\EmailIdentity::remember( $uid, $email );
update_user_meta( $uid, \WopCart\Memberships\Service::CREATED_META, $order->id() );

try {
	\WopCart\Memberships\Service::link_guests( $uid, $email );
} catch ( \Throwable $e ) {
	echo 'link_guests: ' . $e->getMessage() . "\n";
}

if ( $order->customer_id() > 0 ) {
	\WopCart\Repository\CustomerRepository::upsert(
		array(
			'email'   => $email,
			'user_id' => $uid,
		)
	);
}

// Let the buyer set their own password, as the checkout would have.
wp_new_user_notification( $uid, null, 'user' );

/** This action is documented in src/Checkout/Fulfillment.php */
do_action( 'wopcart_account_created', $uid, $order, 'checkout' );

// The licence key, the receipt and the admin notification.
/** This action is documented in src/Checkout/Fulfillment.php */
do_action( 'wopcart_order_complete', $order );

global $wpdb;

$licences = $wpdb->get_results(
	$wpdb->prepare( "SELECT id, license_key, status, expires_at FROM {$wpdb->prefix}wopcart_licenses WHERE order_id = %d", 10 ),
	ARRAY_A
);

echo "after:\n";
echo '  created_for_order = ' . get_user_meta( $uid, \WopCart\Memberships\Service::CREATED_META, true ) . "\n";
echo '  email key         = ' . get_user_meta( $uid, 'wopcart_email_key', true ) . "\n";
echo '  licences          = ' . count( $licences ) . "\n";

foreach ( $licences as $licence ) {
	echo '    #' . $licence['id'] . ' ' . substr( (string) $licence['license_key'], 0, 8 ) . '… ' . $licence['status'] . ' until ' . $licence['expires_at'] . "\n";
}
