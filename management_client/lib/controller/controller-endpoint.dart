part of management_tool.controller;

class Endpoint {
  final ORService.RESTEndpointStore _service;

  Endpoint(this._service);

  Future<Iterable<ORModel.MessageEndpoint>> list(
          int receptionId, int contactId) =>
      _service.list(receptionId, contactId);

  Future<ORModel.MessageEndpoint> create(
          int receptionId, int contactId, ORModel.MessageEndpoint ep) =>
      _service.create(receptionId, contactId, ep);

  Future remove(int endpointId) => _service.remove(endpointId);

  Future<ORModel.MessageEndpoint> update(ORModel.MessageEndpoint ep) =>
      _service.update(ep);
}
