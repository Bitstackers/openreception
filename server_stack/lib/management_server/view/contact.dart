library adaheads.server.view.contact;

import 'dart:convert';

import 'package:openreception_framework/model.dart' as ORF;

import '../model.dart';

String contactAsJson(Contact contact) => JSON.encode(_contactAsJsonMap(contact));

String listContactAsJson(List<Contact> contacts) =>
    JSON.encode({ORF.ContactJSONKey.Contact_LIST:_listContactAsJsonList(contacts)});

String contactIdAsJson(int id) => JSON.encode({ORF.ContactJSONKey.contactID: id});

String contactTypesAsJson(List<String> types) => JSON.encode({'contacttypes': types});
String addressTypesAsJson(List<String> types) => JSON.encode({'addresstypes': types});

Map _contactAsJsonMap(Contact contact) => contact == null ? {} :
    {ORF.ContactJSONKey.contactID: contact.id,
     ORF.ContactJSONKey.fullName: contact.fullName,
     ORF.ContactJSONKey.contactType: contact.contactType,
     ORF.ContactJSONKey.enabled: contact.enabled};

List _listContactAsJsonList(List<Contact> contacts) =>
    contacts.map(_contactAsJsonMap).toList();
