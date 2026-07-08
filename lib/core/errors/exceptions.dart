class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class AppAuthException implements Exception {
  final String message;
  AppAuthException(this.message);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}
