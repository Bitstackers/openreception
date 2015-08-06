library adaheads.server.view.reception;

import 'dart:convert';

import 'package:openreception_framework/keys.dart'  as Key;

import '../model.dart';

String receptionAsJson(Reception r) => JSON.encode(_receptionAsJsonMap(r));

String listReceptionAsJson(List<Reception> receptions) =>
    JSON.encode(_listReceptionAsJsonList(receptions));

String receptionIdAsJson(int id) => JSON.encode({'id': id});

List _listReceptionAsJsonList(List<Reception> receptions) =>
    receptions.map(_receptionAsJsonMap).toList();

Map _receptionAsJsonMap(Reception r) => r == null ? {} :
{Key.ID: r.id,
 Key.organizationId: r.organizationId,
 Key.fullName: r.fullName,
 Key.attributes: r.attributes,
 Key.extradataUri: r.extradatauri,
 Key.enabled: r.enabled,
 Key.receptionTelephonenumber: r.receptionNumber};
