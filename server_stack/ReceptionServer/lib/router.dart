library receptionserver.router;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'cache.dart' as cache;
import 'database.dart' as db;
import 'package:Utilities/httpserver.dart';

part 'router/getreception.dart';
part 'router/getcalendar.dart';
part 'router/updatereception.dart';
part 'router/createreception.dart';
part 'router/deletereception.dart';
part 'router/getreceptionlist.dart';
part 'router/invalidatereception.dart';

final Pattern receptionIdUrl               = new UrlPattern(r'/reception/(\d+)');
final Pattern receptionUrl                 = new UrlPattern(r'/reception');
final Pattern invalidateReceptionUrl       = new UrlPattern(r'/reception/(\d+)/invalidate');
final Pattern getReceptionCalendarListUrl  = new UrlPattern(r'/reception/(\d+)/calendar');
final List<Pattern> allUniqueUrls = [receptionIdUrl, receptionUrl, invalidateReceptionUrl, getReceptionCalendarListUrl];

void setup(HttpServer server) {
  Router router = new Router(server)
    ..filter(matchAny(allUniqueUrls), authFilter)
    ..serve(receptionIdUrl, method: 'GET').listen(getReception)
    ..serve(receptionIdUrl, method: 'DELETE').listen(deleteReception)
    ..serve(receptionUrl,   method: 'POST').listen(createReception)
    ..serve(receptionIdUrl, method: 'PUT').listen(updateReception)
    ..serve(receptionUrl,   method: 'GET').listen(getReceptionList)
    ..serve(invalidateReceptionUrl, method: 'POST').listen(invalidateReception)
    ..serve(getReceptionCalendarListUrl, method: 'GET').listen(getReceptionCalendar)
    ..defaultStream.listen(page404);
}
