library router;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'cache.dart' as cache;
import 'db.dart' as db;

import '../../Shared/httpserver.dart';
import 'package:route/server.dart';
import 'package:route/pattern.dart';

part 'router/getcalendar.dart';
part 'router/getcontact.dart';
part 'router/getcontactlist.dart';
part 'router/getphone.dart';
part 'router/invalidatecontact.dart';

final Pattern invalidateContactUrl           = new UrlPattern(r'/contact/(\d)*/invalidate');
final Pattern getOrganizationContactUrl      = new UrlPattern(r'/contact/(\d)*/organization/(\d)*');
final Pattern getOrganizationContactListUrl  = new UrlPattern(r'/contact/list/organization/(\d)*');
final Pattern getPhoneUrl                    = new UrlPattern(r'/phone/(\d)*');
final Pattern getOrganizationContactCalendarListUrl  = new UrlPattern(r'/contact/(\d)*/organization/(\d)*/calendar');
final List<Pattern> allUniqueUrls = [invalidateContactUrl, getOrganizationContactUrl, getOrganizationContactListUrl, getPhoneUrl, getOrganizationContactCalendarListUrl];

void setup(HttpServer server) {
  Router router = new Router(server)
    ..filter(matchAny(allUniqueUrls), authFilter)
    ..serve(getOrganizationContactUrl, method: 'GET').listen(getContact)
    ..serve(getOrganizationContactListUrl, method: 'GET').listen(getOrgList)
    ..serve(getPhoneUrl, method: 'GET').listen(getPhone)
    ..serve(getOrganizationContactCalendarListUrl, method: 'GET').listen(getContactCalendar)
    ..defaultStream.listen(page404);
}

