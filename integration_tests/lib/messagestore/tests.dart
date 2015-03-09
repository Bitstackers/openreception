part of or_test_fw;

abstract class RESTMessageStore {
  static const int invalidMessageID = -1;

  static void messageNotExists(Storage.Message store) =>
    expect(store.get(invalidMessageID),
        throwsA(new isInstanceOf<Storage.NotFound>()));

  static Future messageList(Storage.Message store) =>
      store.list().then((List<Model.Message> messages) =>
          expect(messages.length, greaterThan(0)));

  static Future messageExists(Storage.Message store, int id) =>
      store.get(id).then((message) =>
          expect(message.ID, equals(new Model.Message.stub(1).ID)));

  /**
   * We inherit the timestamp from the fetched message in order to avoid
   * false negatives arising from datebase timestamps being different than our
   * test data. (Message timestamp is generated along with the database).
   */
  static Future messageMapEquality
    (Storage.Message store, int id, Model.Message expectedMessage) =>
        store.get(id).then((message) =>
            expect(JSON.encode(message.asMap),
                equals(JSON.encode((expectedMessage).asMap))));


  static Future messageSave(Storage.Message store, Model.Message message) =>
      store.save(message).then((Model.Message echoedMessage) =>
          expect(echoedMessage.asMap, equals(message.asMap)));

}