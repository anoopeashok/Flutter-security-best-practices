import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Create a storage instance
  final _storage = const FlutterSecureStorage();

  // Define the key for the sensitive data (e.g., a user's token)
  static const _tokenKey = 'user_auth_token';
  static const _usernameKey = 'saved_username';

  /// Writes the authentication token to secure storage.
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Reads the authentication token from secure storage.
  /// Returns null if the token is not found.
  Future<String?> readAuthToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token;
  }

  /// Deletes the authentication token from secure storage (e.g., on logout).
  Future<void> deleteAuthToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // --- Example for a second key (Username) ---

  /// Writes the username to secure storage.
  Future<void> saveUsername(String username) async {
    await _storage.write(key: _usernameKey, value: username);
  }

  /// Reads the username from secure storage.
  Future<String?> readUsername() async {
    return await _storage.read(key: _usernameKey);
  }
}