/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library openreception.service.io;

import 'dart:async';
import 'dart:convert';

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

Future<String> extractContent(Stream<List<int>> request) {
  Completer completer = new Completer();
  List<int> completeRawContent = new List<int>();

  request.listen(completeRawContent.addAll,
     onError: (error) => completer.completeError(error),
     onDone: () {
       try {
         String content = UTF8.decode(completeRawContent);
         completer.complete(content);
       } catch(error) {
         completer.completeError(error);
       }
  }, cancelOnError: true);

  return completer.future;
}
