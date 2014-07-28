library Adaheads.server.Utilities;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:OpenReceptionFramework/model.dart' as orf_model;
import 'package:OpenReceptionFramework/common.dart' as orf;
import 'package:OpenReceptionFramework/httpserver.dart' as orf_http;

const libraryName = 'userController';
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
