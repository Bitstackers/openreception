part of management_tool.controller;

class CDR {
  service.RESTCDRService _service;

  CDR(service.RESTCDRService this._service);

  Future<Iterable<model.CDREntry>> listEntries(DateTime from, DateTime to) =>
      _service.listEntries(from, to);

  Future<model.CDRCheckpoint> createCheckpoint(
          model.CDRCheckpoint checkpoint) =>
      _service.createCheckpoint(checkpoint);
  Future<Iterable<model.CDRCheckpoint>> checkpoints() => _service.checkpoints();
}
