library adaheads.server.view.contact;

import 'dart:convert';

import '../model.dart';

String contactAsJson(Contact contact) => JSON.encode(_contactAsJsonMap(contact));

String listContactAsJson(List<Contact> contacts) =>
    JSON.encode({'contacts':_listContactAsJsonList(contacts)});

String contactIdAsJson(int id) => JSON.encode({'id': id});

String contactTypesAsJson(List<String> types) => JSON.encode({'contacttypes': types});

Map _contactAsJsonMap(Contact contact) => contact == null ? {} :
    {'id': contact.id,
     'full_name': contact.fullName,
     'contact_type': contact.contactType,
     'enabled': contact.enabled};

List _listContactAsJsonList(List<Contact> contacts) =>
    contacts.map(_contactAsJsonMap).toList();
