part of openreception.test;

void testResourceAuthentication() {
  group('Resource.Authentication', () {
    test('userOf', ResourceAuthentication.userOf);
    test('validate', ResourceAuthentication.validate);
  });
}

abstract class ResourceAuthentication {
  static final Uri authServer = Uri.parse('http://localhost:4050');

  static void userOf () =>
      expect(Resource.Authentication.tokenToUser(authServer, 'testtest'),
        equals(Uri.parse('${authServer}/token/testtest')));

  static void validate () =>
      expect(Resource.Authentication.validate(authServer, 'testtest'),
        equals(Uri.parse('${authServer}/token/testtest/validate')));
}