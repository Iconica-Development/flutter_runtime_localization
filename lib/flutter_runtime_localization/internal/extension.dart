import "package:yaml/yaml.dart";

///
class InvalidYamlException implements Exception {}

///
extension YamlMapping on YamlNode {
  ///
  dynamic get asNative {
    var yaml = this;

    if (yaml is YamlScalar) return yaml.value;
    if (yaml is YamlList) return yaml.nodes.map((e) => e.asNative).toList();
    if (yaml is YamlMap) {
      return Map<String, dynamic>.fromEntries(
        yaml.nodes.entries.map(
          (entry) => MapEntry("${entry.key}", entry.value.asNative),
        ),
      );
    }

    throw InvalidYamlException();
  }
}
