part of openreception.storage;

/**
 * 
 */
abstract class Reception {
  Future<Model.Reception> create(Model.Reception reception);

  Future<Model.Reception> get(int receptionID);

  Future<Model.Reception> getByExtension(String extension);

  Future<String> extensionOf(int receptionId);

  Future<Iterable<Model.Reception>> list();

  Future<Model.Reception> remove(int receptionID);

  Future<Model.Reception> update(Model.Reception reception);
}
