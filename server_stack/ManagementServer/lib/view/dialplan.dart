library adaheads.server.view.dialplan;

import 'package:libdialplan/libdialplan.dart';

import 'dart:convert';

String dialplanAsJson(Dialplan dialplan) => JSON.encode(_dialplanAsJsonMap(dialplan));

Map _dialplanAsJsonMap(Dialplan dialplan) {
  if(dialplan != null) {
    Map json = dialplan.toJson();
    json['entrynumber'] = dialplan.entryNumber;
    json['receptionid'] = dialplan.receptionId;
    json['iscompiled'] = dialplan.isCompiled;
    return json;
  } else {
    return {};
  }
}
