library adaheads.server.view.distributionlist;

import 'dart:convert';

import '../model.dart';

String distributionListAsJson(DistributionList distributionList) => JSON.encode(
    _contactAsJsonMap(distributionList == null ? new DistributionList() : distributionList));

Map _contactAsJsonMap(DistributionList distributionList) =>
    {'to':  _contactsToJson(distributionList.to),
     'cc':  _contactsToJson(distributionList.cc),
     'bcc': _contactsToJson(distributionList.bcc)};


List _contactsToJson(List<ReceptionContact> list) {
  return list
    .map((ReceptionContact rc) => {'reception_id': rc.receptionId, 'contact_id': rc.contactId})
    .toList();
}
