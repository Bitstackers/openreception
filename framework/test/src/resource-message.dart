part of openreception.test;

void testResourceMessage() {
  group('Resource.Message', () {
    test('singleMessage', ResourceMessage.singleMessage);
    test('send', ResourceMessage.send);
    test('list', ResourceMessage.list);
  });
}

abstract class ResourceMessage {
  static Uri messageServer = Uri.parse('http://localhost:4040');

  static void singleMessage() => expect(
      Resource.Message.single(messageServer, 5),
      equals(Uri.parse('${messageServer}/message/5')));

  static void send() => expect(Resource.Message.send(messageServer, 5),
      equals(Uri.parse('${messageServer}/message/5/send')));

  static void list() => expect(Resource.Message.list(messageServer),
      equals(Uri.parse('${messageServer}/message/list')));
}
