part of or_test_fw;

abstract class MessageQueueStore {

  static final Logger log = new Logger ('$libraryName.MessageStore');

  /**
   *
   */
  static Future list (Storage.MessageQueue messageStore) {

    log.info('Listing messages non-filtered.');

    return messageStore.list()
      .then((Iterable<Model.MessageQueueItem> entries) {
        expect(entries.every((msg) => msg is Model.MessageQueueItem), isTrue);
    });
  }
}
