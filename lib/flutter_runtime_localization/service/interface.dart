import "dart:ui";

import "package:flutter_runtime_localization/flutter_runtime_localization/delegate.dart";
import "package:flutter_runtime_localization/flutter_runtime_localization/model/runtime_localization.dart";

/// Exception thrown when initialize has not yet been called.
class UninitializedRuntimeLocalizationException implements Exception {}

/// An abstract interface for managing runtime localizations of type [T].
class RuntimeLocalizationServiceInterface<T extends RuntimeLocalizationBase> {
  /// Function for serializing a [RuntimeLocalizationBase] object into a map.
  Map<String, dynamic> Function(T object) get serializer =>
      throw UnimplementedError();

  /// Function for deserializeing a map into a [RuntimeLocalizationBase] object.
  T Function(Map<String, dynamic> map) get deserializer =>
      throw UnimplementedError();

  /// Bool showing whether the service has been initialized.
  dynamic get initialized => throw UnimplementedError();

  /// Function to initialize the localization service.
  Future<void> initialize() async => throw UnimplementedError();

  /// Add (write) a localization.
  Future<void> addLocalization(T localization) => throw UnimplementedError();

  /// Update a [RuntimeLocalizationBase] and overwrite old value.
  Future<void> updateLocalization(T updatedLocalization) =>
      throw UnimplementedError();

  /// Load a [RuntimeLocalizationBase] from a given identifier string.
  Future<void> loadLocalization(String identifier) =>
      throw UnimplementedError();

  /// Get a [RuntimeLocalizationBase] by [Locale].
  T getLocalization(Locale locale) => throw UnimplementedError();

  /// Get a delegate for use with Flutter’s localization system.
  RuntimeLocalizationDelegate<T> getLocalizationDelegate() =>
      throw UnimplementedError();
}
