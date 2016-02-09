part of management_tool.controller;

class CDR {
  ORService.RESTCDRService _service;

  CDR(ORService.RESTCDRService this._service);

  Future<Iterable<ORModel.CDREntry>> listEntries(DateTime from, DateTime to) =>
      _service.listEntries(from, to);

  Future<ORModel.CDRCheckpoint> createCheckpoint(
          ORModel.CDRCheckpoint checkpoint) =>
      _service.createCheckpoint(checkpoint);
  Future<Iterable<ORModel.CDRCheckpoint>> checkpoints() =>
      _service.checkpoints();
}
