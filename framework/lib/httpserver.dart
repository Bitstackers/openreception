library utilities.httpserver;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:route/server.dart';

import 'common.dart';

final ContentType JSON_MIME_TYPE = new ContentType('application', 'json', charset: 'UTF-8');

class ParameterNotFoundException implements Exception {
  String parameterName;
  ParameterNotFoundException(String this.parameterName);

  String toString() => 'Parameter not found ${parameterName}';
}

void addCorsHeaders(HttpResponse res) {
  res.headers
    ..add("Access-Control-Allow-Origin", "*")
    ..add("Access-Control-Allow-Methods", "POST, GET, PUT, DELETE, OPTIONS")
    ..add("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
}

Filter auth(Uri authUrl) {
  return (HttpRequest request) {

    try {
      if(request.uri.queryParameters.containsKey('token')) {
        String path = 'token/${request.uri.queryParameters['token']}/validate';
        Uri url = new Uri(scheme: authUrl.scheme, host: authUrl.host, port: authUrl.port, path: path);
        return http.get(url).then((response) {
          if (response.statusCode == 200) {
            return true;
          } else {
            request.response.statusCode = HttpStatus.FORBIDDEN;
            writeAndClose(request, JSON.encode({'description': 'Authorization failure.'}));
            return false;
          }
        }).catchError((error) {
          if (error is SocketException) {
            serverError(request, 'failed to connect to authentication server');
          } else {
            serverError(request, 'utilities.httpserver.auth() ${error} config.authUrl: "${authUrl}" final authurl: ${url}');
          }
          return false;
        });

      } else {
        request.response.statusCode = HttpStatus.UNAUTHORIZED;
        writeAndClose(request, JSON.encode({'description': 'No token was specified'}));
        return new Future.value(false);
      }
    } catch (e) {
      logger.critical('utilities.httpserver.auth() ${e} authUrl: "${authUrl}"');
      serverError(request, 'utilities.httpserver.auth() ${e} config.authUrl: "${authUrl}"');
      return new Future.value(false);
    }
  };
}

void preFlight(HttpRequest request) {
  writeAndClose(request, '');
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

String mapToUrlFormEncodedPostBody(Map body) {
  return body.keys.map((key) {
    try {
      return '$key=${Uri.encodeQueryComponent(body[key])}';
    } catch (e) {
      logger.error('mapToUrlFormEncodedPostBody() Key "${key}", value "${body[key]}"');
      throw e;
    }
  }).join('&');
}

String queryParameter(Uri uri, String key) => uri.queryParameters.containsKey(key) ? uri.queryParameters[key] : null;

void page404(HttpRequest request) {
  addCorsHeaders(request.response);

  access('404: ${request.uri}');
  request.response.statusCode = HttpStatus.NOT_FOUND;
  request.response.write(JSON.encode({'error':'No handler found for ' + request.uri.toString() }));
  request.response.close();
}

int pathParameter(Uri uri, String key) {
  try {
    return int.parse(pathParameterString(uri, key));
  } catch(error) {
    return null;
  }
}

String pathParameterString(Uri uri, String key) {
  try {
    return uri.pathSegments.elementAt(uri.pathSegments.indexOf(key) + 1);
  } catch(error) {
    access('utilities.httpserver.pathParameter failed $error Key: $key Uri: $uri');
    throw new ParameterNotFoundException(key);
  }
}

void serverErrorTrace(HttpRequest request, error, {StackTrace stackTrace : null}) {
  const String context = 'serverErrorTrace';

  logger.errorContext('$error ${stackTrace != null ? ' : ${stackTrace}' : ''}', context);
  request.response.statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
  writeAndClose(request, JSON.encode({'error': 'Internal Server Error',
                                      'description' : error.toString()}));
}


void serverError(HttpRequest request, String logMessage) {
  logger.errorContext(logMessage, "serverError");
  request.response.statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
  writeAndClose(request, JSON.encode({'error': 'Internal Server Error',
                                      'description' : logMessage}));
}

//TODO: Implement real TimeZone! TimeFormatter throws NotImplemented.
DateFormat ClfDate = new DateFormat('dd/MMMM/yyyy:HH:mm:ss');

void commonLogFormat (HttpRequest request) {
  DateTime now = new DateTime.now();
  logger.access('${request.connectionInfo != null ? request.connectionInfo.remoteAddress.address : '-'} - - ${ClfDate.format(now)} ${timeZoneFormat(now.timeZoneOffset)}'
                ' "${request.method} ${request.requestedUri}" ${request.response.statusCode}'
                ' ${request.response.contentLength}');
}

String timeZoneFormat(Duration timezone) {
  String sign = timezone.inMilliseconds < 0 ? '-' : '+';
  return '${sign}${doubleDigit(timezone.inHours)}${doubleDigit(timezone.inMinutes % 60)}';
}

String doubleDigit(int number) {
  if(number < 10) {
    return '0${number.abs()}';
  } else {
    return '${number.abs()}';
  }
}

void allOk(HttpRequest request, [String body = '{}']) {
  request.response.statusCode = HttpStatus.OK;
  writeAndClose(request, body);
}

void forbidden(HttpRequest request, String reason) {
  logger.error(reason);
  request.response.statusCode = HttpStatus.FORBIDDEN;
  writeAndClose(request, JSON.encode({'error': reason}));
}

void clientError(HttpRequest request, String reason) {
  logger.error(reason);
  request.response.statusCode = HttpStatus.BAD_REQUEST;
  writeAndClose(request, JSON.encode({'error': reason}));
}

void notFound(HttpRequest request, Map reply) {
  addCorsHeaders(request.response);
  Map responseBody = {'error':'Not found.'};
  responseBody.addAll(reply);

  access('${HttpStatus.NOT_FOUND} : ${request.uri}');
  request.response.statusCode = HttpStatus.NOT_FOUND;
  writeAndClose(request, JSON.encode(responseBody));
}

void resourceNotFound(HttpRequest request) {
  addCorsHeaders(request.response);

  access(HttpStatus.NOT_FOUND.toString() +': ${request.uri}');
  request.response.statusCode = HttpStatus.NOT_FOUND;
  writeAndClose(request, JSON.encode({'error':'Resource not found.'}));
}

void start(int port, void setupRoutes(HttpServer server)) {
  HttpServer.bind(InternetAddress.ANY_IP_V4, port)
    .then(setupRoutes)
    .catchError((e) {
      logger.error('utilities.httpserver.start() -> HttpServer.bind() error: ${e}');
      throw e;
    });
}

Future writeAndClose(HttpRequest request, String text) {

  StringBuffer sb        = new StringBuffer();
  final String logPrefix = request.response.statusCode == 200 ? 'Access' : 'Error';

  sb.write('${logPrefix} - ');
  sb.write('${request.uri} - ');

  if(request.connectionInfo != null) {
    sb.write('${request.connectionInfo.remoteAddress} - ');
  } else {
    sb.write('Unknown remote address - ');
  }

  sb.write(request.response.statusCode);

  addCorsHeaders(request.response);
  try {
    request.response
      ..headers.contentType = JSON_MIME_TYPE
      ..write(text);

    return new Future(() => commonLogFormat(request))
      .then((_) => request.response.close())
      .catchError((error) => logger.errorContext ('Failed to write to access log', 'Common.writeAndClose'));
  } catch (error) {
    logger.errorContext(error.toString(), 'WriteAndClose');
  }

}

Future<int> getUserID (HttpRequest request, Uri authUrl) {
  try {
    if(request.uri.queryParameters.containsKey('token')) {
      String path = 'token/${request.uri.queryParameters['token']}';
      Uri url = new Uri(scheme: authUrl.scheme, host: authUrl.host, port: authUrl.port, path: path);
      return http.get(url).then((response) {
        if (response.statusCode == 200) {
          return JSON.decode(response.body)['id'];
        } else {
          return 0;
        }
      }).catchError((error) {
        return 0;
      });

    } else {
      return new Future.value(false);
    }
  } catch (e) {
    logger.critical('utilities.httpserver.auth() ${e} authUrl: "${authUrl}"');
  }
}

Future<Map> getUserMap (HttpRequest request, Uri authUrl) {
  try {
    if(request.uri.queryParameters.containsKey('token')) {
      String path = 'token/${request.uri.queryParameters['token']}';
      Uri url = new Uri(scheme: authUrl.scheme, host: authUrl.host, port: authUrl.port, path: path);
      return http.get(url).then((response) {
        if (response.statusCode == 200) {
          return JSON.decode(response.body);
        } else {
          return {};
        }
      }).catchError((error) {
        return {};
      });

    } else {
      return new Future.value({});
    }
  } catch (e) {
    logger.critical('utilities.httpserver.auth() ${e} authUrl: "${authUrl}"');
  }
}

