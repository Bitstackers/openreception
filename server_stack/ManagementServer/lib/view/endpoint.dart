library adaheads.server.view.dialplan;

import 'dart:convert';

import '../model.dart';

String endpointListAsJson(List<Endpoint> endpoints) =>
    JSON.encode({'endpoints':_endpointListAsJsonList(endpoints)});

String endpointAsJson(Endpoint endpoint) => JSON.encode(_endpointAsJsonMap(endpoint));

Map _endpointAsJsonMap(Endpoint endpoint) => endpoint == null ? {} :
    {'reception_id': endpoint.receptionId,
     'contact_id'  : endpoint.contactId,
     'address'     : endpoint.address,
     'address_type': endpoint.addressType,
     'confidential': endpoint.confidential,
     'enabled'     : endpoint.enabled,
     'priority'    : endpoint.priority};

List _endpointListAsJsonList(List<Endpoint> endpoints) =>
    endpoints.map(_endpointAsJsonMap).toList();
