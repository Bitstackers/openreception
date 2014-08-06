library adaheads.server.view.reception_contact_reduced_reception;

import 'dart:convert';

import '../model.dart';

String listReceptionContact_ReducedReceptionAsJson(List<ReceptionContact_ReducedReception> receptions) =>
  JSON.encode({'contacts': _listReceptionContact_ReducedReceptionAsJsonList(receptions)});

Map _receptionContact_ReducedReceptionAsJsonMap(ReceptionContact_ReducedReception r) => r == null ? {} :
    {'id': r.contactId,
     'wants_messages': r.wantsMessages,
     'attributes': r.attributes,
     'enabled': r.contactEnabled,
     'phonenumbers': r.phoneNumbers,

     'reception_id': r.receptionId,
     'reception_full_name': r.receptionName,
     'reception_enabled': r.receptionEnabled,

     'organization_id': r.organizationId};

List _listReceptionContact_ReducedReceptionAsJsonList(List<ReceptionContact_ReducedReception> receptions) =>
  receptions.map(_receptionContact_ReducedReceptionAsJsonMap).toList();
