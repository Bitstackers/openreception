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

Future<String> _handleResponse(IO.HttpClientResponse response, Uri resource) {
  try {
    Service.WebService.checkResponseCode(response.statusCode);
    return extractContent(response);
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

