class FronteggException implements Exception {
  final String? message;

  const FronteggException({
    this.message,
  });

  @override
  String toString() {
    return 'FronteggException{message: $message}';
  }
}
