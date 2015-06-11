library adaheads.server.view.receptionContact;

import 'dart:convert';

import '../model.dart';
import 'package:openreception_framework/model.dart' as orf;

String receptionContactAsJson(ReceptionContact contact) => JSON.encode(_receptionContactAsJsonMap(contact));

String listReceptionContactAsJson(List<ReceptionContact> contacts) =>
    JSON.encode({'receptionContacts': _listReceptionContactAsJsonMap(contacts)});

List _listReceptionContactAsJsonMap(List<ReceptionContact> contacts) =>
    contacts.map(_receptionContactAsJsonMap).toList();

