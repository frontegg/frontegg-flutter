/// Represents an exception that occurs within the Frontegg authentication system.
class FronteggException implements Exception {
  /// The error message describing the exception, if available.
  final String? message;

  /// Creates a [FronteggException] instance with an optional message.
  const FronteggException({this.message});

  @override
  String toString() {
    return 'FronteggException{message: $message}';
  }
}
