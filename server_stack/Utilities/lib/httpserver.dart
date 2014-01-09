library utilities.httpserver;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'common.dart';

final ContentType JSON_MIME_TYPE = new ContentType('application', 'json', charset: 'UTF-8');

void addCorsHeaders(HttpResponse res) {
  res.headers
    ..add("Access-Control-Allow-Origin", "*")
    ..add("Access-Control-Allow-Methods", "POST, GET, PUT, DELETE, OPTIONS")
    ..add("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
}

Future<bool> authFilter(HttpRequest request) {
  if(request.uri.queryParameters.containsKey('token')) {
    String host = 'auth.adaheads.com';
    int port = 80;
    String path = 'token/${request.uri.queryParameters['token']}';

    String url = 'http://$host:$port/$path';
    return http.get(url).then((response) {
      if (response.statusCode == 200) {
        return true;
      } else {
        writeAndClose(request, 'Auth Failed');
        return false;
      }
    });
    
  } else {
    request.response.statusCode = HttpStatus.UNAUTHORIZED;
    writeAndClose(request, '');
    return new Future(() => false);
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

void page404(HttpRequest request) {
  addCorsHeaders(request.response);
  
  log('404: ${request.uri}');
  request.response.statusCode = HttpStatus.NOT_FOUND;
  request.response.write("Not Found");
  request.response.close();
}

void serverError(HttpRequest request, String logMessage) {
  log(logMessage);
  request.response.statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
  writeAndClose(request, 'Internal Server Error');
}

void start(int port, void setupRoutes(HttpServer server)) {
  try {
    HttpServer.bind(InternetAddress.ANY_IP_V4, port)
      .then(setupRoutes)
      .catchError((e) => log('http.startHttp() -> HttpServer.bind() error: ${e}'));
  } catch(e) {
    log('http.startHttp() exception: ${e}');
  }
}

void writeAndClose(HttpRequest request, String text) {
  String time = new DateTime.now().toString();
  
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
  //log(sb.toString());
  
  addCorsHeaders(request.response);
  request.response.headers.contentType = JSON_MIME_TYPE;

  request.response
    ..write(text)
    ..close();
}
