part of openreception.storage;

/**
 *
 */
abstract class Reception {
  /**
   *
   */
  Future<model.ReceptionReference> create(
      model.Reception reception, model.User modifier);

  /**
   *
   */
  Future<model.Reception> get(int rid);

  /**
   *
   */
  Future<model.Reception> getByExtension(String extension);

  /**
   *
   */
  Future<String> extensionOf(int rid);

  /**
   *
   */
  Future<Iterable<model.ReceptionReference>> list();

  /**
   *
   */
  Future remove(int rid, model.User modifier);

  /**
   *
   */
  Future<model.ReceptionReference> update(
      model.Reception reception, model.User modifier);

  /**
   *
   */
  Future<Iterable<model.Commit>> changes([int rid]);
}
