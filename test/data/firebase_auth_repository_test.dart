import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:naira_spend/data/models/app_user.dart';
import 'package:naira_spend/data/repositories/auth_repository.dart';
import 'package:naira_spend/data/repositories/firebase_auth_repository.dart';

void main() {
  test('signed out emits null', () async {
    final repo = FirebaseAuthRepository(MockFirebaseAuth());
    expect(await repo.watchUser().first, isNull);
    expect(repo.currentUser, isNull);
  });

  test('a guest is an anonymous Firebase user', () async {
    final repo = FirebaseAuthRepository(MockFirebaseAuth());
    await repo.signInAsGuest();
    expect(repo.currentUser!.isGuest, isTrue);
  });

  test('a signed-in Google user maps to AppUser', () {
    final repo = FirebaseAuthRepository(
      MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'u1', displayName: 'Jane Ade'),
      ),
    );
    expect(
      repo.currentUser,
      const AppUser(uid: 'u1', isGuest: false, displayName: 'Jane Ade'),
    );
  });

  test('a linked guest takes its name from the Google provider', () {
    // After linkWithProvider the top-level displayName stays empty.
    final user = MockUser(
      uid: 'guest-1',
      providerData: [
        UserInfo.fromJson({
          'providerId': 'google.com',
          'uid': 'g-123',
          'displayName': 'Ada Test',
          'isAnonymous': false,
          'isEmailVerified': true,
        }),
      ],
    );
    final repo = FirebaseAuthRepository(
      MockFirebaseAuth(signedIn: true, mockUser: user),
    );
    expect(repo.currentUser!.uid, 'guest-1');
    expect(repo.currentUser!.displayName, 'Ada Test');
  });

  test('sign out', () async {
    final repo = FirebaseAuthRepository(
      MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'u1')),
    );
    await repo.signOut();
    expect(repo.currentUser, isNull);
  });

  group('sign-in errors become words', () {
    Future<String> messageFor(String code) async {
      final auth = MockFirebaseAuth();
      whenCalling(
        Invocation.method(#signInAnonymously, null),
      ).on(auth).thenThrow(FirebaseAuthException(code: code));
      try {
        await FirebaseAuthRepository(auth).signInAsGuest();
        fail('expected an AuthFailure');
      } on AuthFailure catch (e) {
        return e.message;
      }
    }

    test('expired session', () async {
      expect(
        await messageFor('user-token-expired'),
        'Your session has expired. Sign out and sign in again.',
      );
    });

    test('no connection', () async {
      expect(
        await messageFor('network-request-failed'),
        'No connection. Try again when you are online.',
      );
    });

    test('anything else', () async {
      expect(
        await messageFor('internal-error'),
        'Could not sign in. Please try again.',
      );
    });
  });
}
