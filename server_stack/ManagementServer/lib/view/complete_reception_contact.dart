library adaheads.server.view.receptionContact;

import 'dart:convert';

import '../model.dart';

String receptionContactAsJson(ReceptionContact contact) => JSON.encode(_receptionContactAsJsonMap(contact));

String listReceptionContactAsJson(List<ReceptionContact> contacts) =>
    JSON.encode({'receptionContacts': _listReceptionContactAsJsonMap(contacts)});

Map _receptionContactAsJsonMap(ReceptionContact contact) => contact == null ? {} :
    {'reception_id': contact.receptionId,
     'contact_id': contact.contactId,
     'full_name': contact.fullName,
     'contact_type': contact.contactType,
     'contact_enabled': contact.contactEnabled,
     'wants_messages': contact.wantsMessages,
     'attributes': [contact.attributes],
     'reception_enabled': contact.receptionEnabled,
     'phonenumbers': contact.phonenumbers};

List _listReceptionContactAsJsonMap(List<ReceptionContact> contacts) =>
    contacts.map(_receptionContactAsJsonMap).toList();

