part of management_tool.controller;

class Endpoint {
  final service.RESTEndpointStore _service;

  Endpoint(this._service);

  Future<Iterable<model.MessageEndpoint>> list(
          int receptionId, int contactId) =>
      _service.list(receptionId, contactId);

  Future<model.MessageEndpoint> create(
          int receptionId, int contactId, model.MessageEndpoint ep) =>
      _service.create(receptionId, contactId, ep);

  Future remove(int endpointId) => _service.remove(endpointId);

  Future<model.MessageEndpoint> update(model.MessageEndpoint ep) =>
      _service.update(ep);
}
