library router;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'cache.dart' as cache;
import 'db.dart' as db;
import '../../Shared/httpserver.dart';

import 'package:route/server.dart';
import 'package:route/pattern.dart';

part 'router/getorganization.dart';
part 'router/getcalendar.dart';
part 'router/updateorganization.dart';
part 'router/createorganization.dart';
part 'router/deleteorganization.dart';
part 'router/getorganizationlist.dart';
part 'router/invalidateorganization.dart';

final Pattern organizationUrl           = new UrlPattern(r'/organization/(\d)*');
final Pattern createOrganizationUrl     = new UrlPattern('/organization');
final Pattern organizationListUrl       = new UrlPattern('/organization/list');
final Pattern invalidateOrganizationUrl = new UrlPattern(r'/organization/(\d)*/invalidate');
final Pattern getOrganizationCalendarListUrl  = new UrlPattern(r'/organization/(\d)*/calendar');
final List<Pattern> allUniqueUrls = [organizationUrl, organizationListUrl, invalidateOrganizationUrl, getOrganizationCalendarListUrl];

void setup(HttpServer server) {
  Router router = new Router(server)
    ..filter(matchAny(allUniqueUrls), authFilter)
    ..serve(organizationUrl, method: 'GET').listen(getOrg)
    ..serve(organizationUrl, method: 'DELETE').listen(deleteOrg)
    ..serve(createOrganizationUrl, method: 'POST').listen(createOrg)
    ..serve(organizationUrl, method: 'PUT').listen(updateOrg)
    ..serve(organizationListUrl, method: 'GET').listen(getOrgList)
    ..serve(invalidateOrganizationUrl, method: 'POST').listen(invalidateOrg)
    ..serve(getOrganizationCalendarListUrl, method: 'GET').listen(getOrganizationCalendar)
    ..defaultStream.listen(page404);
}
