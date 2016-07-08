part of management_tool.controller;

class Call {
  final service.CallFlowControl _service;

  Call(this._service);

  Future<Iterable<model.Call>> list() => _service.callList();
}
