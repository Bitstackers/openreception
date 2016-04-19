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

import 'dart:io' as io;
import 'storage.dart' as Storage;
import 'service.dart' as Service;
import 'package:logging/logging.dart';

part 'service/io/service-io-client.dart';
part 'service/io/service-io-websocket_client.dart';

const String libraryName = "openreception.service.io";

final Logger log = new Logger(libraryName);

Future<String> _handleResponse(
    io.HttpClientResponse response, String method, Uri resource) async {
  final String body = await extractContent(response);
  Service.WebService.checkResponse(response.statusCode, method, resource, body);
  return body;
}

Future<String> extractContent(Stream<List<int>> request) {
  Completer<String> completer = new Completer();
  List<int> completeRawContent = new List<int>();

  request.listen(completeRawContent.addAll,
      onError: (error) => completer.completeError(error), onDone: () {
    try {
      String content = UTF8.decode(completeRawContent);
      completer.complete(content);
    } catch (error) {
      completer.completeError(error);
    }
  }, cancelOnError: true);

  return completer.future;
}
