library contactserver.router;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'cache.dart' as cache;
import 'package:Utilities/common.dart';
import 'database.dart' as db;
import 'package:Utilities/httpserver.dart';

part 'router/getcalendar.dart';
part 'router/getcontact.dart';
part 'router/getcontactlist.dart';
part 'router/getphone.dart';
part 'router/invalidatecontact.dart';

final Pattern invalidateContactUrl                = new UrlPattern(r'/contact/(\d+)/reception/(\d+)/invalidate');
final Pattern getReceptionContactUrl              = new UrlPattern(r'/contact/(\d+)/reception/(\d+)');
final Pattern getReceptionContactListUrl          = new UrlPattern(r'/contact/list/reception/(\d+)');
final Pattern getPhoneUrl                         = new UrlPattern(r'/phone/(\d+)');
final Pattern getReceptionContactCalendarListUrl  = new UrlPattern(r'/contact/(\d+)/reception/(\d+)/calendar');
final List<Pattern> allUniqueUrls = [invalidateContactUrl, getReceptionContactUrl, getReceptionContactListUrl, getPhoneUrl, getReceptionContactCalendarListUrl];

void setup(HttpServer server) {
  Router router = new Router(server)
    ..filter(matchAny(allUniqueUrls), authFilter)
    ..serve(getReceptionContactUrl, method: 'GET').listen(getContact)
    ..serve(getReceptionContactListUrl, method: 'GET').listen(getContactList)
    ..serve(getPhoneUrl, method: 'GET').listen(getPhone)
    ..serve(getReceptionContactCalendarListUrl, method: 'GET').listen(getContactCalendar)
    ..serve(invalidateContactUrl, method: 'POST').listen(invalidateReception)
    ..defaultStream.listen(page404);
}

