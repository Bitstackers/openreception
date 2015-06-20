part of openreception.test;

void testResourceCDR() {
  group('Resource.CDR', () {
    test('checkpoint', ResourceCDR.checkpoint);
    test('list', ResourceCDR.list);
    test('baseUri', ResourceCDR.root);
  });
}

abstract class ResourceCDR {
  static final Uri _host = Uri.parse('http://localhost:4090');

  static void checkpoint () =>
      expect(Resource.CDR.checkpoint(_host),
        equals(Uri.parse('${_host}/checkpoint')));


  static void root () =>
      expect(Resource.CDR.root(_host),
        equals(Uri.parse('${_host}/cdr')));

  /**
   * TODO: Review this test at a later point.
   */
  static void list () {
    final String from = 'test';
    final String to = 'stuff';

    expect(Resource.CDR.list(_host, from, to),
      equals(Uri.parse('${_host}/cdr?$from&$to')));

  }
}