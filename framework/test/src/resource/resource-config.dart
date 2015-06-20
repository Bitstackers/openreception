part of openreception.test;

void testResourceConfig() {
  group('Resource.Config', () {
    test('get', ResourceConfig.get);
  });
}
abstract class ResourceConfig {
  static final Uri configServer = Uri.parse('http://localhost:4080');

  static void get() => expect(Resource.Config.get(configServer),
      equals(Uri.parse('${configServer}/configuration')));
}
