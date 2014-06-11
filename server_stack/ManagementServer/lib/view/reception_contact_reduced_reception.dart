library adaheads.server.view.reception_contact_reduced_reception;

import 'dart:convert';

import '../model.dart';
import 'phone.dart';

String receptionContact_ReducedReceptionAsJson(ReceptionContact_ReducedReception r) =>
    JSON.encode(_receptionContact_ReducedReceptionAsJsonMap(r));

String listReceptionContact_ReducedReceptionAsJson(List<ReceptionContact_ReducedReception> receptions) =>
  JSON.encode({'contacts': _listReceptionContact_ReducedReceptionAsJsonList(receptions)});

Map _receptionContact_ReducedReceptionAsJsonMap(ReceptionContact_ReducedReception r) => r == null ? {} :
    {'contact_id': r.contactId,
     'contact_wants_messages': r.wantsMessages,
     'contact_attributes': r.attributes,
     'contact_enabled': r.contactEnabled,
     'contact_phonenumbers': r.phoneNumbers,

     'reception_id': r.receptionId,
     'reception_full_name': r.receptionName,
     'reception_enabled': r.receptionEnabled,

     'organization_id': r.organizationId};

List _listReceptionContact_ReducedReceptionAsJsonList(List<ReceptionContact_ReducedReception> receptions) =>
  receptions.map(_receptionContact_ReducedReceptionAsJsonMap).toList();
