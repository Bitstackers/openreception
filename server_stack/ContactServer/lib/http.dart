library http;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'cache.dart' as cache;
import 'common.dart';
import 'configuration.dart';
import 'db.dart' as db;

import 'package:route/server.dart';

part 'http/getcontact.dart';
part 'http/updatecontact.dart';
part 'http/createcontact.dart';
part 'http/deletecontact.dart';
part 'http/getcontactlist.dart';
part 'http/invalidatecontact.dart';

final Pattern getContactUrl        = new UrlPattern(r'/organization/(\d)*/contact/(\d)*');
final Pattern deleteContactUrl     = new UrlPattern(r'/organization/(\d)*/contact/(\d)*');
final Pattern createContactUrl     = new UrlPattern(r'/organization/(\d)*/contact');
final Pattern updateContactUrl     = new UrlPattern(r'/organization/(\d)*/contact/(\d)*');
final Pattern getContactListUrl    = new UrlPattern(r'/organization/(\d)*/contact/list');
final Pattern invalidateContactUrl = new UrlPattern(r'/organization/(\d)*/contact/(\d)*/invalidate');

void setupRoutes(HttpServer server) {
  Router router = new Router(server)
    ..serve(getContactUrl, method: 'GET').listen(getContact)
    ..serve(deleteContactUrl, method: 'DELETE').listen(deleteOrg)
    ..serve(createContactUrl, method: 'POST').listen(createOrg)
    ..serve(updateContactUrl, method: 'PUT').listen(updateOrg)
    ..serve(getContactListUrl, method: 'GET').listen(getOrgList)
    ..serve(invalidateContactUrl, method: 'POST').listen(invalidateOrg)
    ..defaultStream.listen(page404);
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

void serverError(HttpRequest request, String logMessage) {
  log(logMessage);
  request.response.statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
  writeAndClose(request, 'Internal Server Error');
}

void page404(HttpRequest request) {
  log('404: ${request.uri}');
  send404(request);
}

void startHttp() {
  try {
    HttpServer.bind(InternetAddress.ANY_IP_V4, config.httpport).then((HttpServer server) {
      setupRoutes(server);
    }).catchError((e) => log('http.startHttp() -> HttpServer.bind() error: ${e}'));
  } catch(e) {
    log('http.startHttp() exception: ${e}');
  }
}

void writeAndClose(HttpRequest request, String text) {
  StringBuffer sb        = new StringBuffer();
  final String logPrefix = request.response.statusCode == 200 ? 'Access' : 'Error';

  sb.write('${logPrefix} - ');
  sb.write('${request.uri} - ');
  sb.write('${request.connectionInfo.remoteAddress} - ');
  sb.write(request.response.statusCode);

  log(sb.toString());

  request.response
    ..write(text)
    ..close();
}
