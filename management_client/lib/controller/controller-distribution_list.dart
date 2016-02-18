part of management_tool.controller;

class DistributionList {
  final service.RESTDistributionListStore _service;

  DistributionList(this._service);

  Future<model.DistributionList> list(int receptionId, int contactId) =>
      _service.list(receptionId, contactId);

  Future<model.DistributionListEntry> addRecipient(int receptionId,
          int contactId, model.DistributionListEntry recipient) =>
      _service.addRecipient(receptionId, contactId, recipient);

  Future removeRecipient(int entryId) => _service.removeRecipient(entryId);
}
