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

library openreception.management_server.utilities;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:openreception_framework/model.dart' as orf_model;
import 'package:openreception_framework/common.dart' as orf;
import 'package:openreception_framework/httpserver.dart' as orf_http;

const libraryName = 'Utilities';
final ContentType JSON_MIME_TYPE = new ContentType('application', 'json', charset: 'UTF-8');

class HttpMethod {
  static const String GET = 'GET';
  static const String POST = 'POST';
  static const String PUT = 'PUT';
  static const String DELETE = 'DELETE';
  static const String OPTIONS = 'OPTIONS';
}

Future<bool> authorizedRole(HttpRequest request, Uri authUrl, List<String> groups) {
  const context = '${libraryName}.authorizedRole';
  try {
    if(!request.uri.queryParameters.containsKey('token')) {
      Unauthorized(request);
      return new Future.value(false);
    }

    String token = request.uri.queryParameters['token'];
    Uri url = new Uri(scheme: authUrl.scheme, host: authUrl.host, port: authUrl.port, path: 'token/${token}');
    return http.get(url).then((http.Response response) {
      if(response.statusCode == HttpStatus.OK) {
        Map userMap = JSON.decode(response.body);
        orf_model.User user = new orf_model.User.fromMap(userMap);

        //If the user is in any of the required groups.
        if(groups != null && groups.isNotEmpty && user.inAnyGroups(groups)) {
          return true;

        } else {
          orf_http.forbidden(request, 'Do not have the required permissions.');
          return false;
        }

      } else {
        orf_http.forbidden(request, 'Auth server denied access. ${response.body}');
        return false;
      }
    }).catchError((error, stack) {
      orf.logger.errorContext('Auth request failed with: ${error}, \n${stack}', context);
      orf_http.serverError(request, error.toString());
      return false;
    });
  } catch (error) {
    orf.logger.errorContext('error: ${error} authUrl: "${authUrl}"', context);
    orf_http.serverError(request, error.toString());
    return new Future.value(false);
  }
}

Future<HttpServer> makeServer(int port) => HttpServer.bind(InternetAddress.ANY_IP_V4, port);

Future Unauthorized(HttpRequest request) {
  request.response.statusCode = HttpStatus.UNAUTHORIZED;
  return orf_http.writeAndClose(request, JSON.encode({'status': 'Unauthorized'}));
}

void printDebug(HttpRequest request) {
  print('------------------------- START --------------------------');
  print(request.method);
  if(request.method == 'OPTIONS') {
    orf_http.extractContent(request).then((String text) {
      print('-------- BODY: ${text}');
    });
  }
  request.headers.forEach((key, values) {
    print('$key -> "${values.join(', ')}"');
  });
  print('-------------------------- END ---------------------------');
}
