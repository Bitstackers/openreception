part of openreception.storage;

abstract class Message {

  Future enqueue (Model.Message message);

  Future<Model.Message> get (int messageID);

  Future<Iterable<Model.Message>> list ({Model.MessageFilter filter});

  Future<Model.Message> create (Model.Message message);

  Future<Model.Message> update (Model.Message message);

  Future<Model.Message> save (Model.Message message);

}