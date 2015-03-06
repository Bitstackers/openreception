part of openreception.storage;

abstract class Message {

  Future enqueue (Model.Message message);

  Future<Model.Message> get (int messageID);

  Future<List<Model.Message>> list ({Model.MessageFilter filter});

  Future<Model.Message> save (Model.Message message);


}