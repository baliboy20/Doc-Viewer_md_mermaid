import 'package:equatable/equatable.dart';

/// Base class for Git authentication credentials
abstract class GitCredentials extends Equatable {
  const GitCredentials();

  @override
  List<Object?> get props => [];
}

/// Username and password credentials for HTTPS
class UsernamePasswordCredentials extends GitCredentials {
  final String username;
  final String password;

  const UsernamePasswordCredentials({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];

  @override
  String toString() => 'UsernamePasswordCredentials(username: $username)';
}

/// SSH key credentials
class SshKeyCredentials extends GitCredentials {
  final String username;
  final String publicKeyPath;
  final String privateKeyPath;
  final String? passphrase;

  const SshKeyCredentials({
    required this.username,
    required this.publicKeyPath,
    required this.privateKeyPath,
    this.passphrase,
  });

  @override
  List<Object?> get props => [username, publicKeyPath, privateKeyPath, passphrase];

  @override
  String toString() => 'SshKeyCredentials(username: $username, publicKey: $publicKeyPath)';
}

/// Personal Access Token credentials (for GitHub, GitLab, etc.)
class PersonalAccessTokenCredentials extends GitCredentials {
  final String token;
  final String? username; // Optional, some services require it

  const PersonalAccessTokenCredentials({
    required this.token,
    this.username,
  });

  @override
  List<Object?> get props => [token, username];

  @override
  String toString() => 'PersonalAccessTokenCredentials(username: ${username ?? "token"})';
}
