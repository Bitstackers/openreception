library Adaheads.server.Utilities;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;

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
    ..add("Access-Control-Allow-Methods", "POST,GET,PUT,DELETE,OPTIONS")
    ..add("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
}

Future<bool> authorized(HttpRequest request, Uri authUrl, {String groupName}) {
  try {
    if(request.uri.queryParameters.containsKey('token')) {
      String token = request.uri.queryParameters['token'];
      Uri url = new Uri(scheme: authUrl.scheme, host: authUrl.host, port: authUrl.port, path: 'token/${token}');
      return http.get(url).then((http.Response response) {
        if (response.statusCode == 200) {
          if(groupName != null) {
            Map content = JSON.decode(response.body);
            if(content.containsKey('groups') && content['groups'] is List) {
              if ((content['groups'] as List).contains(groupName)) {
                return true;
              } else {
                logger.debug('The list "${content['groups']}" does not containt "${groupName}"');
                Forbidden(request, 'You do not have the right premissions');
                return false;
              }
            } else {
              logger.error('Request for token "${token}" gave malformed data.');
              Internal_Error(request);
              return false;
            }
          } else {
            return true;
          }
        }
        logger.debug('Auth return with code "${response.statusCode}" on url "${url}"');
        Forbidden(request);
        return false;

      }).catchError((error) {
        logger.error('authorized() Url: "${request.uri}" authUrl: "${url}" Error: $error');
        Internal_Error(request);
        return false;
      });

    } else {
      Unauthorized(request);
      return new Future.value(false);
    }
  } catch (e) {
    logger.critical('authorized() ${e} authUrl: "${authUrl}"');
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

Future Internal_Error(HttpRequest request) {
  request.response.statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
  return writeAndCloseJson(request, JSON.encode({'status': 'Internal Server Error'}));
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

int pathParameter(Uri uri, String key) {
  try {
    return int.parse(uri.pathSegments.elementAt(uri.pathSegments.indexOf(key) + 1));
  } catch(error) {
    logger.error('utilities.http.pathParameter failed $error Key: $key Uri: $uri');
    return null;
  }
}

void PreFlight(HttpRequest request) {
  print('PREFLIGHT');
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

