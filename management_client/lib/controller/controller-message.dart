part of management_tool.controller;

class Message {
  final service.RESTMessageStore _messageStore;

  Message(this._messageStore);

  Future<Iterable<model.Message>> list(model.MessageFilter filter) =>
      _messageStore.list(filter: filter);

  Future remove(int messageId) => _messageStore.remove(messageId);
}
