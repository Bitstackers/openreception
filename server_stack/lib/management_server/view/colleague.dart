library adaheads.server.view.Colleague;

import 'dart:convert';
import '../model.dart';

String listReceptionColleaguesAsJson(List<ReceptionColleague> organizations) =>
    JSON.encode({'receptions':_listReceptionColleaguesAsJsonList(organizations)});

Map _receptionColleagueAsJsonMap(ReceptionColleague reception) => reception == null ? {} :
    {'id': reception.id,
     'organization_id': reception.organizationId,
     'full_name': reception.fullName,
     'enabled': reception.enabled,
     'contacts': _listColleaguesAsJsonList(reception.Colleagues)};

List _listReceptionColleaguesAsJsonList(List<ReceptionColleague> receptions) =>
    receptions.map(_receptionColleagueAsJsonMap).toList();

Map _colleagueAsJsonMap(Colleague contact) => contact == null ? {} :
    {'id': contact.contactId,
     'full_name': contact.contactName,
     'enabled': contact.contactEnabled,
     'contact_type': contact.contactType};

List _listColleaguesAsJsonList(List<Colleague> contacts) =>
    contacts.map(_colleagueAsJsonMap).toList();
