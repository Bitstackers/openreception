library adaheads.server.view.reception;

import 'dart:convert';

import '../model.dart';

String receptionAsJson(Reception r) => JSON.encode(_receptionAsJsonMap(r));

String listReceptionAsJson(List<Reception> receptions) =>
    JSON.encode({'receptions': _listReceptionAsJsonList(receptions)});

String receptionIdAsJson(int id) => JSON.encode({'id': id});

List _listReceptionAsJsonList(List<Reception> receptions) =>
    receptions.map(_receptionAsJsonMap).toList();

Map _receptionAsJsonMap(Reception r) => r == null ? {} :
{'id': r.id,
 'organization_id': r.organizationId,
 'full_name': r.fullName,
 'attributes': r.attributes,
 'extradatauri': r.extradatauri,
 'enabled': r.enabled,
 'number': r.receptionNumber};
