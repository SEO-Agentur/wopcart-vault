<?php
/**
 * Make Stripe accept the connected accounts wopcart.com creates.
 *
 * The platform asked Stripe for an Express dashboard while leaving the processing
 * fees with the merchant and the losses with Stripe. Stripe refuses that
 * combination — "When `stripe_dashboard[type]=express`, your platform must collect
 * fees and be liable for negative balances or refunds and chargebacks" — so
 * creating a connected account failed every single time and no store was ever
 * connected.
 *
 * The fix lives in WopCart Platform 1.0.1, but wopcart.com still runs the older
 * core that carries its own copy of this code. Both answer the same filter, so
 * this one file repairs the live platform now and stays harmless afterwards: it
 * sets exactly what 1.0.1 sets.
 *
 * `full` gives the merchant their own Stripe Dashboard, they pay Stripe's fees out
 * of their own balance and Stripe carries the losses — which is what merchant of
 * record means, and what a 2 % application fee can afford. Onboarding still runs
 * through the platform's hosted account link, because requirement collection stays
 * with Stripe.
 *
 * Remove this file once wopcart.com runs WopCart Platform 1.0.1 or newer.
 *
 * @package WopCart\Site
 */

declare(strict_types=1);

add_filter(
	'wopcart_platform_account_controller',
	static function (): array {
		return array(
			'stripe_dashboard'       => array( 'type' => 'full' ),
			'fees'                   => array( 'payer' => 'account' ),
			'losses'                 => array( 'payments' => 'stripe' ),
			'requirement_collection' => 'stripe',
		);
	}
);
