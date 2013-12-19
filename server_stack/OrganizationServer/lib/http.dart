library http;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'cache.dart' as cache;
import 'common.dart';
import 'configuration.dart';
import 'db.dart' as db;

import 'package:route/server.dart';

part 'http/getorganization.dart';
part 'http/updateorganization.dart';
part 'http/createorganization.dart';
part 'http/deleteorganization.dart';
part 'http/getorganizationlist.dart';
part 'http/invalidateorganization.dart';

final Pattern getOrganizationUrl        = new UrlPattern(r'/organization/(\d)*');
final Pattern deleteOrganizationUrl     = new UrlPattern(r'/organization/(\d)*');
final Pattern createOrganizationUrl     = new UrlPattern('/organization');
final Pattern updateOrganizationUrl     = new UrlPattern(r'/organization/(\d)*');
final Pattern getOrganizationListUrl    = new UrlPattern('/organization/list');
final Pattern invalidateOrganizationUrl = new UrlPattern(r'/organization/(\d)*/invalidate');

void setupRoutes(HttpServer server) {
  Router router = new Router(server)
    ..serve(getOrganizationUrl, method: 'GET').listen(getOrg)
    ..serve(deleteOrganizationUrl, method: 'DELETE').listen(deleteOrg)
    ..serve(createOrganizationUrl, method: 'POST').listen(createOrg)
    ..serve(updateOrganizationUrl, method: 'PUT').listen(updateOrg)
    ..serve(getOrganizationListUrl, method: 'GET').listen(getOrgList)
    ..serve(invalidateOrganizationUrl, method: 'POST').listen(invalidateOrg)
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
