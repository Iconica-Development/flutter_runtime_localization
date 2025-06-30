import "dart:ui";

/// The [RuntimeLocalizationBase] base class.
/// Extend to implement your own runtime localization.
abstract class RuntimeLocalizationBase {
  /// [RuntimeLocalizationBase] constructor
  const RuntimeLocalizationBase({
    required Locale locale,
  }) : _locale = locale;

  /// Retrieve [Locale] from the [RuntimeLocalizationBase].
  Locale getLocale() => _locale;

  /// The keys used by [RuntimeLocalizationBase].
  static const keys = (locale: "locale");

  final Locale _locale;

  /// The base toMap function to override.
  Map<String, dynamic> toMap() => {
        keys.locale: "$_locale",
      };
}
