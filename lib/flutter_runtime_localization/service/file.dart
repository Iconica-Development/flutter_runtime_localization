import "dart:io";

import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_runtime_localization/flutter_runtime_localization/delegate.dart";
import "package:flutter_runtime_localization/flutter_runtime_localization/functions.dart";
import "package:flutter_runtime_localization/flutter_runtime_localization/internal/extension.dart";
import "package:flutter_runtime_localization/flutter_runtime_localization/model/model.dart";
import "package:flutter_runtime_localization/flutter_runtime_localization/service/service.dart";
import "package:yaml/yaml.dart";
import "package:yaml_writer/yaml_writer.dart";

extension on Uri {
  String get asPath => toFilePath(windows: Platform.isWindows);
}

/// Exception thrown when the [FileRuntimeLocalizationService] cannot load
/// a localization from the file.
class LoadingLocalizationFromFileFailedException implements Exception {
  /// [LoadingLocalizationFromFileFailedException] constructor
  const LoadingLocalizationFromFileFailedException(this.locale);

  /// The locale for which the localizations could not be found.
  final Locale locale;

  @override
  String toString() => "LoadingLocalizationFromFileFailedException<$locale>";
}

///
class FileRuntimeLocalizationService<T extends RuntimeLocalizationBase>
    extends RuntimeLocalizationServiceInterface<T> {
  /// [FileRuntimeLocalizationService] constructor
  FileRuntimeLocalizationService({
    required Directory directory,
    required this.serializer,
    required this.deserializer,
    Future<void> Function(FileRuntimeLocalizationService<T>)? onEmpty,
  })  : _onEmpty = onEmpty,
        _directory = directory;

  final Directory _directory;

  final Future<void> Function(FileRuntimeLocalizationService<T>)? _onEmpty;

  /// Function used to deserialize [T].
  @override
  final T Function(Map<String, dynamic>) deserializer;

  /// Function used to serialize [T].
  @override
  final Map<String, dynamic> Function(T) serializer;

  /// Bool showing whether the service been initialized.
  @override
  bool initialized = false;

  /// The directory in which the localizations are stored.
  Directory get directory {
    if (!_directory.existsSync()) _directory.createSync(recursive: true);
    return _directory;
  }

  Uri get _localizationUri => _directory.uri;
  String get _localizationPath =>
      _localizationUri.toFilePath(windows: Platform.isWindows);
  Iterable<FileSystemEntity> get _localeFiles => _directory.listSync().where(
        (file) => file.path.endsWith(".yaml"),
      );

  /// Function to initialize the baseDirectory
  @override
  Future<void> initialize() async {
    if (initialized) return;
    await _loadLocalizations();
    initialized = true;
  }

  /// Function to receive the delegate for [T]
  @override
  RuntimeLocalizationDelegate<T> getLocalizationDelegate() =>
      RuntimeLocalizationDelegate.getInstance<T>();

  /// Add a localization file by opening a system file picker
  Future<void> pickLocalizationFile() async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["yaml"],
    );

    if (result == null) return;

    var file = result.files.single;
    var path = file.path;

    if (path == null) return;

    var fileContents = await File(path).readAsString();
    var decodedYaml = loadYamlNode(fileContents);

    var map = decodedYaml.asNative as Map<String, dynamic>;

    await addLocalization(deserializer(map));
  }

  /// Add a localization and write the file to the device directory.
  @override
  Future<void> addLocalization(T localization) async {
    var filename = "${localization.getLocale()}.yaml";
    await Directory(_localizationPath).create(recursive: true);
    var fileTarget = _localizationUri.resolve(filename).asPath;

    if (File(fileTarget).existsSync()) return;

    var fileContents = YamlWriter().write(serializer(localization));

    await File(fileTarget).writeAsString(fileContents);

    await loadLocalization(fileTarget);

    notifyListeners();
  }

  /// Get a [RuntimeLocalizationBase] by [Locale].
  @override
  T getLocalization(Locale locale) =>
      RuntimeLocalizationDelegate.getInstance<T>().localeLocalizations[locale]!;

  /// Load a [RuntimeLocalizationBase] from path.
  @override
  Future<void> loadLocalization(String path) async {
    var filename = Uri.parse(path).pathSegments.last.split(".").first;
    var locale = localeFromString(filename);
    var yaml = loadYamlNode(await File(path).readAsString());

    var delegateInstance = RuntimeLocalizationDelegate.getInstance<T>();

    try {
      delegateInstance.updateLocalization(
        locale,
        deserializer(yaml.asNative as Map<String, dynamic>),
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      throw LoadingLocalizationFromFileFailedException(locale);
    }
  }

  /// Update a [RuntimeLocalizationBase].
  @override
  Future<void> updateLocalization(T updatedLocalization) async {
    var locale = updatedLocalization.getLocale();
    var fileContents = YamlWriter().write(serializer(updatedLocalization));
    var fileTarget = _localizationUri.resolve("$locale.yaml").asPath;

    await File(fileTarget).writeAsString(fileContents);
    await loadLocalization(fileTarget);

    notifyListeners();
  }

  Future<void> _loadLocalizations() async {
    if (_localeFiles.isEmpty) await _onEmpty?.call(this);

    var futures = _localeFiles.map((file) => loadLocalization(file.path));

    await Future.wait(futures);
  }
}
