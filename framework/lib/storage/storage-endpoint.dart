part of openreception.storage;

@deprecated
abstract class Endpoint {
  Future<model.MessageEndpoint> create(
      int receptionid, int contactid, model.MessageEndpoint ep);

  Future remove(int endpointId);

  Future<Iterable<model.MessageEndpoint>> list(int receptionid, int contactid);

  Future<model.MessageEndpoint> update(model.MessageEndpoint ep);
}
