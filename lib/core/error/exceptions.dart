/// Exception thrown when a server error occurs.
class ServerException implements Exception {}

/// Exception thrown when a cache error occurs.
class CacheException implements Exception {}

/// Exception thrown when there's no internet connection.
class NetworkException implements Exception {}

/// Exception thrown when a requested resource is not found.
class NotFoundException implements Exception {}

/// Exception thrown when input data is invalid.
class InvalidInputException implements Exception {}

/// Exception thrown when authentication fails.
class AuthException implements Exception {}
