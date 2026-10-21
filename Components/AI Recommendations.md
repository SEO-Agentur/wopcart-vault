# AI Recommendations

`src/Ai/ClaudeClient.php` + `Recommendations.php`

## Setup

Endpoint `https://api.anthropic.com/v1/messages`, `anthropic-version: 2023-06-01` pinned.
Default model **`claude-opus-5`**, effort `low`.

Uses `wp_remote_post`, not the official PHP SDK — a distributed WordPress plugin cannot
require Composer, and bundling a vendored SDK invites fatal class collisions.

## Cost control — three layers

1. **`output_config.format` with a JSON schema** makes the response shape a guarantee, which
   removes the parse-and-retry loop this would otherwise need.
2. **The catalogue is a cached prompt prefix** (`cache_control: ephemeral` on the second
   system block) so repeat requests read cache at ~0.1× input cost. Volatile per-request
   context goes in the *user* turn, after the cached block, so it cannot invalidate it.
3. **Results cached per context** (product / cart hash / customer) for `ai_cache_hours`.
   A busy product page costs one call per cache window, not one per visitor.

Plus a hard `ai_monthly_call_cap`.

## Safety

- `stop_reason === 'refusal'` is checked **before** reading content — a refusal is HTTP 200
  with empty or partial content.
- Every suggestion is validated back against the catalogue: hallucinated IDs, unpurchasable
  products, and anything the visitor already owns are dropped rather than rendered.
- Failures cache an empty result for 10 minutes so an outage does not turn every page view
  into another failed request.

## Contexts

`for_product()`, `for_cart()`, `for_customer()`. Shortcode `[dcart_recommendations]`,
Elementor widget, and an AJAX endpoint so results can load after cached HTML.
