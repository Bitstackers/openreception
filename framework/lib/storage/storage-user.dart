part of openreception.storage;

abstract class User {

  Future<Model.User> get (String identity);

/*
  Future<Model.User> get (int userID);
  Future<Model.Message> save (Model.Message message);

  Future<Model.Message> enqueue (Model.Message message);

  Future<List<Model.Message>> list ({int limit: 100, Model.MessageFilter filter});
*/
}