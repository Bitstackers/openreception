part of management_tool.controller;

class PeerAccount {
  final service.PeerAccount _paService;

  PeerAccount(this._paService);

  Future<Iterable<String>> list() => _paService.list().catchError(_handleError);

  Future<model.PeerAccount> get(String accountName) =>
      _paService.get(accountName).catchError(_handleError);

  Future<Iterable<String>> deploy(model.PeerAccount account, int uid) =>
      _paService.deployAccount(account, uid).catchError(_handleError);

  Future remove(String accountName) =>
      _paService.remove(accountName).catchError(_handleError);
}
