library adaheads.server.view.organization;

import 'dart:convert';

import '../model.dart';

String organizationAsJson(Organization organization) =>
    JSON.encode(_organizationAsJsonMap(organization));

String listOrganizatonAsJson(List<Organization> organizations) =>
    JSON.encode({'organizations':_listOrganizatonAsJsonList(organizations)});

String organizationIdAsJson(int id) => JSON.encode({'id': id});

Map _organizationAsJsonMap(Organization organization) => organization == null ? {} :
    {'id': organization.id,
     'full_name': organization.fullName,
     'bill_type': organization.billType,
     'flag'     : organization.flag};

List _listOrganizatonAsJsonList(List<Organization> organizations) =>
    organizations.map(_organizationAsJsonMap).toList();
