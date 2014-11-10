library openreception.service;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'model.dart' as Model;
import 'storage.dart' as Storage;

part 'service/service-auth.dart';
part 'service/service-webservice.dart';
part 'service/service-message.dart';
part 'service/service-message_resource.dart';
part 'service/service-notification.dart';
part 'service/service-reception.dart';
part 'service/service-reception_resource.dart';
part 'service/service-user.dart';

final String libraryName = "service";

Uri appendToken (Uri uri, String token) =>
    Uri.parse('${uri}${uri.queryParameters.isEmpty ? '?' : '&'}token=${token}');


String _removeTailingSlashes (Uri host) {
   String _trimmedHostname = host.toString();

   while (_trimmedHostname.endsWith('/')) {
     _trimmedHostname = _trimmedHostname.substring(0, _trimmedHostname.length-1);
   }

   return _trimmedHostname;
}
