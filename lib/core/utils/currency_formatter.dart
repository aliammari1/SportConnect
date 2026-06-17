/// Context-free currency string formatting.
///
/// This is the single source of truth for the app's fixed-symbol currency
/// formatting (e.g. `€12.50`) used in places that cannot reach a
/// `BuildContext` — such as models, view-models and share/receipt text.
///
/// For widget code that has a `BuildContext` and needs locale-aware currency
/// formatting (grouping separators, locale-specific symbol placement), prefer
/// `AppLocaleFormatters.formatCurrencyFromCents`. This helper intentionally
/// produces a stable, locale-independent `<symbol><amount>` string so that the
/// previously hard-coded interpolations keep identical output.
abstract final class CurrencyFormatter {
  /// Formats a minor-unit [cents] amount as a fixed-symbol currency string.
  ///
  /// Mirrors the legacy `'€${(cents / 100).toStringAsFixed(decimals)}'`
  /// interpolation: divides by 100 and renders with [decimals] fraction digits.
  /// [cents] is typed as [num] so callers can pass either an `int` cents value
  /// or an already-computed `num` (e.g. `pricePerSeatInCents * seats`).
  ///
  /// Example: `CurrencyFormatter.fromCents(1250)` -> `'€12.50'`.
  static String fromCents(
    num cents, {
    int decimals = 2,
    String symbol = '€',
  }) => '$symbol${(cents / 100).toStringAsFixed(decimals)}';

  /// Formats an already-divided [amount] (in major units, e.g. euros) as a
  /// fixed-symbol currency string.
  ///
  /// Mirrors the legacy `'€${amount.toStringAsFixed(decimals)}'` interpolation.
  ///
  /// Example: `CurrencyFormatter.fromAmount(12.5)` -> `'€12.50'`.
  static String fromAmount(
    num amount, {
    int decimals = 2,
    String symbol = '€',
  }) => '$symbol${amount.toStringAsFixed(decimals)}';

  /// Formats a per-seat (or per-unit) price from [cents], appending a [suffix].
  ///
  /// Mirrors the legacy `'€${(cents / 100).toStringAsFixed(2)}/seat'` pattern.
  ///
  /// Example: `CurrencyFormatter.perUnitFromCents(1250)` -> `'€12.50/seat'`.
  static String perUnitFromCents(
    num cents, {
    int decimals = 2,
    String symbol = '€',
    String suffix = '/seat',
  }) => '${fromCents(cents, decimals: decimals, symbol: symbol)}$suffix';
}
