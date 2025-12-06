import 'package:flutter_test/flutter_test.dart';
import 'package:doc_viewer_app/features/git/infrastructure/services/credential_storage.dart';

/// Unit tests for CredentialStorage
///
/// Note: The actual storage operations (save, load, delete) require
/// flutter_secure_storage platform implementations which are not available
/// in unit tests. These operations should be tested via integration tests
/// on real devices/simulators.
///
/// This test suite focuses on the URL normalization logic which doesn't
/// require platform-specific implementations.
void main() {
  group('CredentialStorage', () {
    late CredentialStorage storage;

    setUp(() {
      storage = CredentialStorage();
    });

    group('URL normalization', () {
      test('normalizes HTTPS URLs correctly', () {
        const url1 = 'https://github.com/user/repo.git';
        const url2 = 'https://github.com/user/repo';
        const url3 = 'HTTPS://GITHUB.COM/USER/REPO.git';

        // All should normalize to the same value
        expect(storage.normalizeUrl(url1), storage.normalizeUrl(url2));
        expect(storage.normalizeUrl(url1), storage.normalizeUrl(url3));
      });

      test('normalizes SSH URLs correctly', () {
        const url1 = 'git@github.com:user/repo.git';
        const url2 = 'git@github.com:user/repo';
        const url3 = 'ssh://git@github.com/user/repo.git';

        // SSH format should convert : to /
        final normalized1 = storage.normalizeUrl(url1);
        expect(normalized1, 'github.com/user/repo');

        final normalized2 = storage.normalizeUrl(url2);
        expect(normalized2, 'github.com/user/repo');

        // ssh:// should be removed
        final normalized3 = storage.normalizeUrl(url3);
        expect(normalized3.contains('ssh://'), false);
      });

      test('removes trailing slashes', () {
        const url = 'https://github.com/user/repo/';
        final normalized = storage.normalizeUrl(url);
        expect(normalized.endsWith('/'), false);
      });

      test('removes .git extension', () {
        const url = 'https://github.com/user/repo.git';
        final normalized = storage.normalizeUrl(url);
        expect(normalized.endsWith('.git'), false);
      });

      test('converts to lowercase', () {
        const url = 'HTTPS://GITHUB.COM/USER/REPO';
        final normalized = storage.normalizeUrl(url);
        expect(normalized, normalized.toLowerCase());
      });
    });

    // Note: Credential storage operations (save/load/delete) are tested
    // via integration tests as they require platform-specific secure storage
    // implementations (Keychain on macOS, etc.) which are not available in
    // unit tests.
    //
    // To run integration tests:
    // flutter test integration_test/git_integration_test.dart
  });
}

/*
// ========== INTEGRATION TEST TEMPLATE ==========
// These tests require running on a real device or simulator
// Move to integration_test/ directory to run

group('Credential operations (integration)', () {
      const testUrl = 'https://github.com/test/repo.git';

      tearDown(() async {
        // Clean up credentials after each test
        try {
          await storage.deleteCredentials(testUrl);
        } catch (_) {
          // Ignore errors during cleanup
        }
      });

      test('saves and loads username/password credentials', () async {
        const credentials = UsernamePasswordCredentials(
          username: 'testuser',
          password: 'testpass',
        );

        await storage.saveCredentials(
          repoUrl: testUrl,
          credentials: credentials,
        );

        final loaded = await storage.loadCredentials(testUrl);
        expect(loaded, isA<UsernamePasswordCredentials>());

        final loadedCreds = loaded as UsernamePasswordCredentials;
        expect(loadedCreds.username, 'testuser');
        expect(loadedCreds.password, 'testpass');
      });

      test('saves and loads token credentials', () async {
        const credentials = PersonalAccessTokenCredentials(
          token: 'ghp_test123456',
          username: 'git',
        );

        await storage.saveCredentials(
          repoUrl: testUrl,
          credentials: credentials,
        );

        final loaded = await storage.loadCredentials(testUrl);
        expect(loaded, isA<PersonalAccessTokenCredentials>());

        final loadedCreds = loaded as PersonalAccessTokenCredentials;
        expect(loadedCreds.token, 'ghp_test123456');
        expect(loadedCreds.username, 'git');
      });

      test('saves and loads SSH credentials', () async {
        const credentials = SshKeyCredentials(
          username: 'git',
          publicKeyPath: '/path/to/id_rsa.pub',
          privateKeyPath: '/path/to/id_rsa',
          passphrase: 'secret',
        );

        await storage.saveCredentials(
          repoUrl: testUrl,
          credentials: credentials,
        );

        final loaded = await storage.loadCredentials(testUrl);
        expect(loaded, isA<SshKeyCredentials>());

        final loadedCreds = loaded as SshKeyCredentials;
        expect(loadedCreds.username, 'git');
        expect(loadedCreds.publicKeyPath, '/path/to/id_rsa.pub');
        expect(loadedCreds.privateKeyPath, '/path/to/id_rsa');
        expect(loadedCreds.passphrase, 'secret');
      });

      test('saves SSH credentials without passphrase', () async {
        const credentials = SshKeyCredentials(
          username: 'git',
          publicKeyPath: '/path/to/id_rsa.pub',
          privateKeyPath: '/path/to/id_rsa',
        );

        await storage.saveCredentials(
          repoUrl: testUrl,
          credentials: credentials,
        );

        final loaded = await storage.loadCredentials(testUrl);
        expect(loaded, isA<SshKeyCredentials>());

        final loadedCreds = loaded as SshKeyCredentials;
        expect(loadedCreds.passphrase, isNull);
      });

      test('overwrites existing credentials', () async {
        const credentials1 = UsernamePasswordCredentials(
          username: 'user1',
          password: 'pass1',
        );

        const credentials2 = UsernamePasswordCredentials(
          username: 'user2',
          password: 'pass2',
        );

        await storage.saveCredentials(
          repoUrl: testUrl,
          credentials: credentials1,
        );

        await storage.saveCredentials(
          repoUrl: testUrl,
          credentials: credentials2,
        );

        final loaded = await storage.loadCredentials(testUrl);
        final loadedCreds = loaded as UsernamePasswordCredentials;
        expect(loadedCreds.username, 'user2');
        expect(loadedCreds.password, 'pass2');
      });

      test('deletes credentials', () async {
        const credentials = UsernamePasswordCredentials(
          username: 'testuser',
          password: 'testpass',
        );

        await storage.saveCredentials(
          repoUrl: testUrl,
          credentials: credentials,
        );

        expect(await storage.hasCredentials(testUrl), true);

        await storage.deleteCredentials(testUrl);

        expect(await storage.hasCredentials(testUrl), false);
        expect(await storage.loadCredentials(testUrl), isNull);
      });

      test('hasCredentials returns false for non-existent repo', () async {
        const nonExistentUrl = 'https://github.com/nonexistent/repo.git';
        expect(await storage.hasCredentials(nonExistentUrl), false);
      });

      test('loadCredentials returns null for non-existent repo', () async {
        const nonExistentUrl = 'https://github.com/nonexistent/repo.git';
        expect(await storage.loadCredentials(nonExistentUrl), isNull);
      });

      test('lists stored repositories', () async {
        const url1 = 'https://github.com/user1/repo1.git';
        const url2 = 'https://github.com/user2/repo2.git';

        const creds1 = UsernamePasswordCredentials(
          username: 'user1',
          password: 'pass1',
        );

        const creds2 = PersonalAccessTokenCredentials(
          token: 'token2',
        );

        await storage.saveCredentials(repoUrl: url1, credentials: creds1);
        await storage.saveCredentials(repoUrl: url2, credentials: creds2);

        final repos = await storage.listStoredRepositories();

        // Should contain normalized URLs
        expect(repos.length, greaterThanOrEqualTo(2));
        expect(repos, contains(storage.normalizeUrl(url1)));
        expect(repos, contains(storage.normalizeUrl(url2)));

        // Clean up
        await storage.deleteCredentials(url1);
        await storage.deleteCredentials(url2);
      });
    });
*/
