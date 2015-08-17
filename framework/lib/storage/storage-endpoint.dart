part of openreception.storage;

abstract class Endpoint {
  Future<Model.MessageEndpoint> create(
      int receptionid, int contactid, Model.MessageEndpoint ep);

  Future<int> remove(int endpointId);

  Future<Iterable<Model.MessageEndpoint>> list(int receptionid, int contactid);

  Future<Model.MessageEndpoint> update(Model.MessageEndpoint ep);
}
