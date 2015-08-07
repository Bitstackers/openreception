library adaheads.server.view.receptionContact;

import 'dart:convert';

import '../model.dart' as model;

String receptionContactAsJson(model.ReceptionContact contact) => JSON.encode(_receptionContactAsJsonMap(contact));

String listReceptionContactAsJson(List<model.ReceptionContact> contacts) =>
    JSON.encode({'receptionContacts': _listReceptionContactAsJsonMap(contacts)});

List _listReceptionContactAsJsonMap(List<model.ReceptionContact> contacts) =>
    contacts.map(_receptionContactAsJsonMap).toList();

///FIXME: Dummy implementation to trick analyzer.
Map _receptionContactAsJsonMap (model.ReceptionContact contact) => {};