extension StringEx on String {
  DateTime toDateTime() => DateTime.parse(this);
}

/// Reads a bool from platform-channel payloads (iOS may send `NSNumber` as `int`).
bool readPlatformBool(Object? value, {bool defaultValue = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'true':
      case '1':
        return true;
      case 'false':
      case '0':
        return false;
    }
  }
  return defaultValue;
}
