import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/git_credentials.dart';

/// Service for securely storing and retrieving Git credentials
///
/// Uses flutter_secure_storage which leverages platform-specific secure storage:
/// - macOS: Keychain
/// - Linux: libsecret
/// - Windows: Windows Credential Manager
class CredentialStorage {
  static const _storage = FlutterSecureStorage();

  // Key prefixes
  static const _usernamePrefix = 'git_username_';
  static const _passwordPrefix = 'git_password_';
  static const _tokenPrefix = 'git_token_';
  static const _sshKeyPrefix = 'git_ssh_';

  /// Save credentials for a repository
  ///
  /// [repoUrl] - Repository URL to associate credentials with
  /// [credentials] - Credentials to save
  ///
  /// Throws [Exception] if storage fails
  Future<void> saveCredentials({
    required String repoUrl,
    required GitCredentials credentials,
  }) async {
    final normalizedUrl = normalizeUrl(repoUrl);

    try {
      if (credentials is UsernamePasswordCredentials) {
        await _saveUsernamePassword(normalizedUrl, credentials);
      } else if (credentials is PersonalAccessTokenCredentials) {
        await _saveToken(normalizedUrl, credentials);
      } else if (credentials is SshKeyCredentials) {
        await _saveSshKey(normalizedUrl, credentials);
      } else {
        throw Exception('Unsupported credential type: ${credentials.runtimeType}');
      }
    } catch (e) {
      throw Exception('Failed to save credentials: $e');
    }
  }

  /// Load credentials for a repository
  ///
  /// [repoUrl] - Repository URL to load credentials for
  ///
  /// Returns credentials if found, null otherwise
  Future<GitCredentials?> loadCredentials(String repoUrl) async {
    final normalizedUrl = normalizeUrl(repoUrl);

    try {
      // Try to load username/password first
      final credentials = await _loadUsernamePassword(normalizedUrl);
      if (credentials != null) return credentials;

      // Try to load token
      final tokenCreds = await _loadToken(normalizedUrl);
      if (tokenCreds != null) return tokenCreds;

      // Try to load SSH key
      final sshCreds = await _loadSshKey(normalizedUrl);
      if (sshCreds != null) return sshCreds;

      return null;
    } catch (e) {
      throw Exception('Failed to load credentials: $e');
    }
  }

  /// Delete credentials for a repository
  ///
  /// [repoUrl] - Repository URL to delete credentials for
  Future<void> deleteCredentials(String repoUrl) async {
    final normalizedUrl = normalizeUrl(repoUrl);

    try {
      // Delete all possible credential types
      await _storage.delete(key: '$_usernamePrefix$normalizedUrl');
      await _storage.delete(key: '$_passwordPrefix$normalizedUrl');
      await _storage.delete(key: '$_tokenPrefix$normalizedUrl');
      await _storage.delete(key: '$_sshKeyPrefix$normalizedUrl');
    } catch (e) {
      throw Exception('Failed to delete credentials: $e');
    }
  }

  /// Check if credentials exist for a repository
  ///
  /// [repoUrl] - Repository URL to check
  ///
  /// Returns true if any credentials are stored
  Future<bool> hasCredentials(String repoUrl) async {
    final normalizedUrl = normalizeUrl(repoUrl);

    try {
      final username = await _storage.read(key: '$_usernamePrefix$normalizedUrl');
      final token = await _storage.read(key: '$_tokenPrefix$normalizedUrl');
      final sshKey = await _storage.read(key: '$_sshKeyPrefix$normalizedUrl');

      return username != null || token != null || sshKey != null;
    } catch (e) {
      return false;
    }
  }

  /// List all repository URLs that have saved credentials
  ///
  /// Returns list of repository URLs
  Future<List<String>> listStoredRepositories() async {
    try {
      final allKeys = await _storage.readAll();
      final repos = <String>{};

      for (final key in allKeys.keys) {
        if (key.startsWith(_usernamePrefix)) {
          repos.add(key.substring(_usernamePrefix.length));
        } else if (key.startsWith(_tokenPrefix)) {
          repos.add(key.substring(_tokenPrefix.length));
        } else if (key.startsWith(_sshKeyPrefix)) {
          repos.add(key.substring(_sshKeyPrefix.length));
        }
      }

      return repos.toList();
    } catch (e) {
      throw Exception('Failed to list stored repositories: $e');
    }
  }

  // ========== Private Helper Methods ==========

  Future<void> _saveUsernamePassword(
    String url,
    UsernamePasswordCredentials credentials,
  ) async {
    await _storage.write(
      key: '$_usernamePrefix$url',
      value: credentials.username,
    );
    await _storage.write(
      key: '$_passwordPrefix$url',
      value: credentials.password,
    );
  }

  Future<UsernamePasswordCredentials?> _loadUsernamePassword(String url) async {
    final username = await _storage.read(key: '$_usernamePrefix$url');
    final password = await _storage.read(key: '$_passwordPrefix$url');

    if (username == null || password == null) return null;

    return UsernamePasswordCredentials(
      username: username,
      password: password,
    );
  }

  Future<void> _saveToken(
    String url,
    PersonalAccessTokenCredentials credentials,
  ) async {
    final data = {
      'token': credentials.token,
      if (credentials.username != null) 'username': credentials.username,
    };

    await _storage.write(
      key: '$_tokenPrefix$url',
      value: jsonEncode(data),
    );
  }

  Future<PersonalAccessTokenCredentials?> _loadToken(String url) async {
    final jsonData = await _storage.read(key: '$_tokenPrefix$url');
    if (jsonData == null) return null;

    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      return PersonalAccessTokenCredentials(
        token: data['token'] as String,
        username: data['username'] as String?,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveSshKey(
    String url,
    SshKeyCredentials credentials,
  ) async {
    final data = {
      'username': credentials.username,
      'publicKeyPath': credentials.publicKeyPath,
      'privateKeyPath': credentials.privateKeyPath,
      if (credentials.passphrase != null) 'passphrase': credentials.passphrase,
    };

    await _storage.write(
      key: '$_sshKeyPrefix$url',
      value: jsonEncode(data),
    );
  }

  Future<SshKeyCredentials?> _loadSshKey(String url) async {
    final jsonData = await _storage.read(key: '$_sshKeyPrefix$url');
    if (jsonData == null) return null;

    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      return SshKeyCredentials(
        username: data['username'] as String,
        publicKeyPath: data['publicKeyPath'] as String,
        privateKeyPath: data['privateKeyPath'] as String,
        passphrase: data['passphrase'] as String?,
      );
    } catch (e) {
      return null;
    }
  }

  /// Normalize URL to use as storage key
  ///
  /// Removes protocol, trailing slashes, and .git extension
  ///
  /// This method is public to allow testing of URL normalization logic
  String normalizeUrl(String url) {
    var normalized = url.toLowerCase();

    // Remove protocol
    normalized = normalized.replaceFirst(RegExp(r'^https?://'), '');
    normalized = normalized.replaceFirst(RegExp(r'^ssh://'), '');
    normalized = normalized.replaceFirst(RegExp(r'^git@'), '');

    // Remove .git extension
    normalized = normalized.replaceFirst(RegExp(r'\.git$'), '');

    // Remove trailing slashes
    normalized = normalized.replaceFirst(RegExp(r'/$'), '');

    // Replace : with / for SSH URLs (git@github.com:user/repo -> github.com/user/repo)
    normalized = normalized.replaceFirst(':', '/');

    return normalized;
  }
}
