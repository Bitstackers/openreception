library adaheads.server.view.reception;

import 'dart:convert';

import 'package:openreception_framework/model.dart' as ORF;

import '../model.dart';

String receptionAsJson(Reception r) => JSON.encode(_receptionAsJsonMap(r));

String listReceptionAsJson(List<Reception> receptions) =>
    JSON.encode(_listReceptionAsJsonList(receptions));

String receptionIdAsJson(int id) => JSON.encode({'id': id});

List _listReceptionAsJsonList(List<Reception> receptions) =>
    receptions.map(_receptionAsJsonMap).toList();

Map _receptionAsJsonMap(Reception r) => r == null ? {} :
{ORF.ReceptionJSONKey.ID: r.id,
 ORF.ReceptionJSONKey.ORGANIZATION_ID: r.organizationId,
 ORF.ReceptionJSONKey.FULL_NAME: r.fullName,
 ORF.ReceptionJSONKey.ATTRIBUTES: r.attributes,
 ORF.ReceptionJSONKey.EXTRADATA_URI: r.extradatauri,
 ORF.ReceptionJSONKey.ENABLED: r.enabled,
 ORF.ReceptionJSONKey.EXTENSION: r.receptionNumber};
