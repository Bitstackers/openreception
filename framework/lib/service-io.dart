library openreception.service.io;

import 'httpserver.dart';

import 'dart:async';
import 'dart:io' as IO;
import 'storage.dart' as Storage;
import 'service.dart' as Service;
import 'package:logging/logging.dart';

part 'service/io/service-io-client.dart';
part 'service/io/service-io-websocket_client.dart';

const String libraryName = "openreception.service.io";

final Logger log = new Logger(libraryName);

Future<String> _handleResponse(IO.HttpClientResponse response, String method, Uri resource) {
  try {

    return extractContent(response).then((String responseBody){
      Service.WebService.checkResponse (response.statusCode, method, resource, responseBody);
      return responseBody;
    });
  } catch (error, stacktrace) {
    if (!(error is Storage.NotFound    ||
          error is Storage.ClientError ||
          error is Storage.Forbidden   ||
          error is Storage.NotAuthorized ||
          error is Storage.ServerError)) {
      log.severe('$error : $resource\n$stacktrace');
    }

    return new Future.error(error,stacktrace);
  }
}

