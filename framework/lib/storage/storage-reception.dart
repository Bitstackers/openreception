part of openreception.storage;

abstract class Reception {

  Future<Model.Reception> get (int receptionID);

  Future<List<Model.Reception>> list (); //{int limit: 100, Model.ReceptionFilter filter}

  Future<Model.Reception> remove(int receptionID);

  Future<Model.Reception> save (Model.Reception reception);
}
