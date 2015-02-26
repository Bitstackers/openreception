library openreception.service;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'model.dart' as Model;
import 'resource.dart' as Resource;
import 'storage.dart' as Storage;


import 'package:logging/logging.dart';

part 'service/service-auth.dart';
part 'service/service-call_flow_control.dart';
part 'service/service-contact.dart';
part 'service/service-message.dart';
part 'service/service-notification.dart';
part 'service/service-organization.dart';
part 'service/service-reception.dart';
part 'service/service-webservice.dart';
part 'service/service-websocket.dart';

const String libraryName = "service";

Uri appendToken (Uri uri, String token) =>
  token == null ? uri : Uri.parse('${uri}${uri.queryParameters.isEmpty ? '?' : '&'}token=${token}');


