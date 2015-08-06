library adaheads.server.view.contact;

import 'dart:convert';

import 'package:openreception_framework/keys.dart'  as Key;

import '../model.dart';

String contactAsJson(Contact contact) => JSON.encode(_contactAsJsonMap(contact));

String listContactAsJson(List<Contact> contacts) =>
    JSON.encode(_listContactAsJsonList(contacts));

String contactIdAsJson(int id) => JSON.encode({Key.contactID: id});

String contactTypesAsJson(List<String> types) => JSON.encode({'contacttypes': types});
String addressTypesAsJson(List<String> types) => JSON.encode({'addresstypes': types});

Map _contactAsJsonMap(Contact contact) => contact == null ? {} :
    {Key.contactID: contact.id,
     Key.fullName: contact.fullName,
     Key.contactType: contact.contactType,
     Key.enabled: contact.enabled};

List _listContactAsJsonList(List<Contact> contacts) =>
    contacts.map(_contactAsJsonMap).toList();
