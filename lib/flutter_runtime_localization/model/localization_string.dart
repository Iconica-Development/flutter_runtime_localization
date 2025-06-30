/// A helper class to resolve the inline variables.
/// ```dart
/// final localizationExample = LocalizationString("this is {name}");
/// localizationExample({"name":"Ernst"})
/// ```
class LocalizationString {
  /// Constructor receiving the [String]
  const LocalizationString(this._value);

  final String _value;

  @override
  String toString() => _value;

  /// Call function which resolves inline variables.
  String call([Map<String, dynamic>? replacements]) {
    var output = toString();
    if (replacements == null) return output;
    for (var replacement in replacements.entries) {
      output = output.replaceAll(
        "{${replacement.key}}",
        "${replacement.value}",
      );
    }
    return output;
  }
}
