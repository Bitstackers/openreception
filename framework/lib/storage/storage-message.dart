part of openreception.storage;

abstract class Message {

  Future<Model.Message> enqueue (Model.Message message);

  Future<Model.Message> get (int messageID);

  Future<List<Model.Message>> list ({int limit: 100, Model.MessageFilter filter});

  Future<Model.Message> save (Model.Message message);


}