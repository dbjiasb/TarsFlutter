class ObjectCreateException implements Exception {
  late String _message;

  ObjectCreateException(String message) {
    _message = message;
  }
}
