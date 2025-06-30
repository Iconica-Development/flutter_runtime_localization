import "dart:ui";

/// Get a [Locale] from it's [String] representation
/// Works for `en_US` and `en-US`
Locale localeFromString(String localeString) {
  var parts = localeString.split(RegExp("[_-]"));

  if (parts.length == 1) return Locale(parts[0]);
  if (parts.length == 2) return Locale(parts[0], parts[1]);

  throw FormatException("Invalid locale format: $localeString");
}
