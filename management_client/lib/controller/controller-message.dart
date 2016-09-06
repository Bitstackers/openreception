part of orm.controller;

class Message {
  final service.RESTMessageStore _messageStore;
  final model.User _appUser;

  Message(this._messageStore, this._appUser);

  Future<Iterable<model.Message>> list(
          DateTime day, model.MessageFilter filter) =>
      _messageStore.listDay(day, filter: filter).catchError(_handleError);

  Future<Iterable<model.Message>> listSaved(model.MessageFilter filter) =>
      _messageStore.listDrafts(filter: filter).catchError(_handleError);

  Future remove(int messageId) =>
      _messageStore.remove(messageId, _appUser).catchError(_handleError);
}
