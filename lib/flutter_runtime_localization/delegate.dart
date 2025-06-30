import "package:flutter/material.dart";
import "package:flutter_runtime_localization/flutter_runtime_localization/model/model.dart";

/// Exception thrown when the [RuntimeLocalizationDelegate] cannot find
/// A localization for the requested [Locale].
class LocalizationDoesNotExistForLocaleException implements Exception {
  /// [LocalizationDoesNotExistForLocaleException] constructor
  const LocalizationDoesNotExistForLocaleException(this.locale);

  /// The locale for which the localizations could not be found.
  final Locale locale;

  @override
  String toString() => "LocalizationDoesNotExistForLocaleException<$locale>";
}

/// The delegate that provides localization functionality for [MaterialApp]
class RuntimeLocalizationDelegate<T extends RuntimeLocalizationBase>
    extends LocalizationsDelegate<T> with ChangeNotifier {
  RuntimeLocalizationDelegate._({
    required Map<Locale, T> localeLocalizations,
  }) : _localeLocalizations = localeLocalizations;

  static final Map<Type, RuntimeLocalizationDelegate> _instances = {};

  /// Provides the [RuntimeLocalizationDelegate] for type [T]
  static RuntimeLocalizationDelegate<T>
      getInstance<T extends RuntimeLocalizationBase>() =>
          (_instances[T] ??= RuntimeLocalizationDelegate<T>._(
            localeLocalizations: <Locale, T>{},
          )) as RuntimeLocalizationDelegate<T>;

  final Map<Locale, T> _localeLocalizations;

  /// Get all the supported locales for this delegate.
  List<Locale> get locales => _localeLocalizations.keys.toList();

  /// Get a map of all [RuntimeLocalizationBase] instances
  Map<Locale, T> get localeLocalizations => _localeLocalizations;

  @override
  bool isSupported(Locale locale) => _localeLocalizations.containsKey(locale);

  MapEntry<Locale, T>? _maybeFullMatch(Locale locale) =>
      _localeLocalizations.entries
          .where(
            (e) =>
                e.key.languageCode == locale.languageCode &&
                e.key.countryCode == locale.countryCode,
          )
          .firstOrNull;

  MapEntry<Locale, T>? _maybePartialMatch(Locale locale) =>
      _localeLocalizations.entries
          .where((e) => e.key.languageCode == locale.languageCode)
          .firstOrNull;

  @override
  Future<T> load(Locale locale) async {
    var entry = _maybeFullMatch(locale) ?? _maybePartialMatch(locale);
    if (entry == null) throw LocalizationDoesNotExistForLocaleException(locale);
    return entry.value;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<T> old) => true;

  /// Updates a localization
  void updateLocalization(Locale locale, T localization) {
    _localeLocalizations[locale] = localization;
  }
}
