library adaheads.server.view.dialplan;

import 'package:libdialplan/libdialplan.dart';

import 'dart:convert';

String dialplanAsJson(Dialplan dialplan) => JSON.encode(_dialplanAsJsonMap(dialplan));

Map _dialplanAsJsonMap(Dialplan dialplan) {
  if(dialplan != null) {
    Map json = dialplan.toJson();
    json['number'] = dialplan.entryNumber;
    json['receptionid'] = dialplan.receptionId;
    return json;
  } else {
    return {};
  }
}
