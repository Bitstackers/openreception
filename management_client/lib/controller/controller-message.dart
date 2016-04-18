part of management_tool.controller;

class Message {
  final service.RESTMessageStore _messageStore;
  final model.User _appUser;

  Message(this._messageStore, this._appUser);

  Future<Iterable<model.Message>> list(model.MessageFilter filter) =>
      _messageStore.list(filter: filter).catchError(_handleError);

  Future remove(int messageId) =>
      _messageStore.remove(messageId, _appUser).catchError(_handleError);
}
