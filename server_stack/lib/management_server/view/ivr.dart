library adaheads.server.view.ivr;

import 'package:libdialplan/ivr.dart';

import 'dart:convert';

String ivrListAsJson(IvrList ivrList) => JSON.encode(_ivrListAsJsonMap(ivrList));

Map _ivrListAsJsonMap(IvrList ivrList) => ivrList != null ? ivrList.toJson() : {};
