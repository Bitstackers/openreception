part of openreception.storage;

/**
 *
 */
abstract class Reception {
  Future<model.ReceptionReference> create(
      model.Reception reception, model.User modifier);

  Future<model.Reception> get(int id);

  Future<model.Reception> getByExtension(String extension);

  Future<String> extensionOf(int id);

  Future<Iterable<model.ReceptionReference>> list();

  Future remove(int id, model.User modifier);

  Future<model.ReceptionReference> update(
      model.Reception reception, model.User modifier);
}
