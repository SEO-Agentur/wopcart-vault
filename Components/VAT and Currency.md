# VAT and Multi-currency

## VAT — `src/Tax/`

- `VatRates.php` — 27 EU member states, standard/reduced/ebook rates, admin-overridable,
  VAT number format patterns. **Rates are a seed, not tax advice.**
- `Vies.php` — validates against the EU REST API. Three outcomes: `valid`, `invalid`,
  **`unavailable`**. Treating unavailable as invalid would charge VAT to legitimate B2B
  buyers whenever a member state reboots a server.
- `TaxContext.php` — buyer location + VAT status; captures two-piece location evidence
  (billing country + IP country) as the digital services rules require.
- `TaxManager.php` — rate resolution, reverse-charge test, inclusive/exclusive tax maths.

**Reverse charge requires three conditions**: buyer in the EU, in a *different* member state
from the store, with a VIES-confirmed VAT number. A non-EU store cannot reverse charge.

Greece is the one country whose ISO code (`GR`) differs from its VAT prefix (`EL`) — handled
in `VatRates::split()`.

## Order of operations

**Price → discount → tax.** Taxing before discounting overcharges VAT on money the buyer
never paid. `Cart\Calculator` enforces this.

## Currency — `src/Currency/`

- `Currencies.php` — 32 sellable currencies + country→currency map
- `Rates.php` — providers: frankfurter (ECB, no key), exchangerate.host, openexchangerates,
  fixer. **A failed refresh keeps stale rates** — stale is far less damaging than resetting
  every price to parity mid-outage.
- `CurrencyManager.php` — active currency resolution (cookie → geo → base), conversion,
  psychological rounding, switcher shortcode

**Manual per-currency price overrides beat FX conversion.** A store pricing at 19 EUR wants
exactly 19 EUR, not 18.87.

**Orders store `total_base`** — converted at the sale-day rate — so revenue reports never
shift when today's rates move.
