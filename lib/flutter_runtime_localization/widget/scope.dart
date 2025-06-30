import "package:flutter/material.dart";
import "package:flutter_runtime_localization/flutter_runtime_localization/model/model.dart";
import "package:flutter_runtime_localization/flutter_runtime_localization/service/service.dart";

/// Allows access to the service from the context.
class RuntimeLocalizationScope<T extends RuntimeLocalizationBase>
    extends InheritedNotifier<FileRuntimeLocalizationService<T>> {
  /// [RuntimeLocalizationScope] constructor.
  const RuntimeLocalizationScope({
    required FileRuntimeLocalizationService<T> service,
    required super.child,
    super.key,
  }) : super(notifier: service);

  /// Maybe receive a [FileRuntimeLocalizationService]
  static FileRuntimeLocalizationService<T>?
      maybeOf<T extends RuntimeLocalizationBase>(
    BuildContext context,
  ) =>
          context
              .dependOnInheritedWidgetOfExactType<RuntimeLocalizationScope<T>>()
              ?.notifier;

  /// Receive a [FileRuntimeLocalizationService] or error.
  static FileRuntimeLocalizationService<T>
      of<T extends RuntimeLocalizationBase>(
    BuildContext context,
  ) =>
          maybeOf<T>(context)!;
}
