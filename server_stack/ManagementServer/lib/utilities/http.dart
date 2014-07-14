library Adaheads.server.Utilities;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:OpenReceptionFramework/model.dart' as ORF;

import 'logger.dart';

final ContentType JSON_MIME_TYPE = new ContentType('application', 'json', charset: 'UTF-8');

class HttpMethod {
  static const String GET = 'GET';
  static const String POST = 'POST';
  static const String PUT = 'PUT';
  static const String DELETE = 'DELETE';
  static const String OPTIONS = 'OPTIONS';
}

void addCorsHeaders(HttpResponse res) {
  res.headers
    ..add("Access-Control-Allow-Origin", "*")
    ..add("Access-Control-Allow-Methods", "GET, PUT, POST, DELETE, OPTIONS")
    ..add("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
}

Future<bool> authorizedRole(HttpRequest request, Uri authUrl, List<String> groups) {
  try {
    String token = request.uri.queryParameters['token'];
    Uri url = new Uri(scheme: authUrl.scheme, host: authUrl.host, port: authUrl.port, path: 'token/${token}');
    return http.get(url).then((http.Response response) {
      if(response.statusCode == HttpStatus.OK) {
        Map userMap = JSON.decode(response.body);
        ORF.User user = new ORF.User.fromMap(userMap);

        //If the user is in any of the required groups.
        if(groups != null && groups.isNotEmpty && user.inAnyGroups(groups)) {
          return true;

        } else {
          Forbidden(request, 'Do not have the required permissions.');
          return false;
        }

      } else {
        Forbidden(request);
        return false;
      }
    }).catchError((error, stack) {
      logger.critical('authorizedRole. Auth request failed with: ${error}, \n${stack}');
      Internal_Error(request);
      return false;
    });
  } catch (e) {
    logger.critical('authorizedRole() ${e} authUrl: "${authUrl}"');
    Internal_Error(request);
    return new Future.value(false);
  }
}

Future<String> extractContent(HttpRequest request) {
  Completer completer = new Completer();
  List<int> completeRawContent = new List<int>();

  request.listen((List<int> data) {
    completeRawContent.addAll(data);
  }, onError: (error) => completer.completeError(error),
     onDone: () {
    String content = UTF8.decode(completeRawContent);
    completer.complete(content);
  }, cancelOnError: true);

  return completer.future;
}

Future Forbidden(HttpRequest request, [String reason = null]) {
  request.response.statusCode = HttpStatus.FORBIDDEN;
  Map data = {'status': 'Forbidden'};
  if(reason != null) {
    data['reason'] = reason;
  }
  return writeAndCloseJson(request, JSON.encode(data));
}

Future Internal_Error(HttpRequest request, [String error]) {
  request.response.statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
  Map response = {'status': 'Internal Server Error'};
  if(error != null) {
    response['error'] = error;
  }
  return writeAndCloseJson(request, JSON.encode(response));
}

Future<bool> logHit(HttpRequest request, Logger logger) {
  logger.debug('${request.connectionInfo.remoteAddress.address} ${request.method} ${request.uri}');
  return new Future.value(true);
}

Future<HttpServer> makeServer(int port) => HttpServer.bind(InternetAddress.ANY_IP_V4, port);

Future NOTFOUND(HttpRequest request) {
  request.response.statusCode = HttpStatus.NOT_FOUND;
  return writeAndCloseJson(request, JSON.encode({'status': 'Not found'}));
}

int intPathParameter(Uri uri, String key) => int.parse(PathParameter(uri, key));

String PathParameter(Uri uri, String key) {
  try {
    return uri.pathSegments.elementAt(uri.pathSegments.indexOf(key) + 1);
  } catch(error) {
    logger.error('utilities.http.pathParameter failed $error Key: $key Uri: $uri');
    return null;
  }
}

void PreFlight(HttpRequest request) {
  logger.debug('PREFLIGHT');
  writeAndCloseJson(request, '');
}

Future Unauthorized(HttpRequest request) {
  request.response.statusCode = HttpStatus.UNAUTHORIZED;
  return writeAndCloseJson(request, JSON.encode({'status': 'Unauthorized'}));
}

Future writeAndCloseJson(HttpRequest request, String body) {
  //TODO Timestamp
  logger.debug('${request.response.statusCode} ${request.method} ${request.uri}');

  addCorsHeaders(request.response);
  request.response.headers.contentType = JSON_MIME_TYPE;

  request.response
    ..write(body)
    ..write('\n');

  return request.response.close();
}

void printDebug(HttpRequest request) {
  print('------------------------- START --------------------------');
  print(request.method);
  if(request.method == 'OPTIONS') {
    extractContent(request).then((String text) {
      print('-------- BODY: ${text}');
    });
  }
  request.headers.forEach((key, values) {
    print('$key -> "${values.join(', ')}"');
  });
  print('-------------------------- END ---------------------------');
}

