import "package:flutter/material.dart";
import "package:flutter_runtime_localization/flutter_runtime_localization/model/model.dart";
import "package:flutter_runtime_localization/flutter_runtime_localization/service/service.dart";

/// Allows access to the service from the context.
class RuntimeLocalizationScope<T extends RuntimeLocalizationBase>
    extends InheritedNotifier<RuntimeLocalizationServiceInterface<T>> {
  /// [RuntimeLocalizationScope] constructor.
  const RuntimeLocalizationScope({
    required RuntimeLocalizationServiceInterface<T> service,
    required super.child,
    super.key,
  }) : super(notifier: service);

  /// Maybe receive a [RuntimeLocalizationServiceInterface]
  static RuntimeLocalizationServiceInterface<T>?
      maybeOf<T extends RuntimeLocalizationBase>(
    BuildContext context,
  ) =>
          context
              .dependOnInheritedWidgetOfExactType<RuntimeLocalizationScope<T>>()
              ?.notifier;

  /// Receive a [RuntimeLocalizationServiceInterface] or error.
  static RuntimeLocalizationServiceInterface<T>
      of<T extends RuntimeLocalizationBase>(
    BuildContext context,
  ) =>
          maybeOf<T>(context)!;
}
