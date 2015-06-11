library adaheads.server.view.receptionContact;

import 'dart:convert';

import '../model.dart' as model;
import 'package:openreception_framework/model.dart' as orf;

String receptionContactAsJson(model.ReceptionContact contact) => JSON.encode(_receptionContactAsJsonMap(contact));

String listReceptionContactAsJson(List<model.ReceptionContact> contacts) =>
    JSON.encode({'receptionContacts': _listReceptionContactAsJsonMap(contacts)});

List _listReceptionContactAsJsonMap(List<model.ReceptionContact> contacts) =>
    contacts.map(_receptionContactAsJsonMap).toList();

