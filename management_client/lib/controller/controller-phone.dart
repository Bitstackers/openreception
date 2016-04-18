part of openreception.managementclient.controller;

class DistributionList {
  final ORService.RESTDistributionListStore _service;

  DistributionList(this._service);

  Future<ORModel.DistributionList> list(int receptionId, int contactId) =>
      _service.list(receptionId, contactId).catchError(_handleError);

  Future<ORModel.DistributionListEntry> addRecipient(int receptionId,
          int contactId, ORModel.DistributionListEntry recipient) =>
      _service
          .addRecipient(receptionId, contactId, recipient)
          .catchError(_handleError);

  Future removeRecipient(int entryId) =>
      _service.removeRecipient(entryId).catchError(_handleError);
}
