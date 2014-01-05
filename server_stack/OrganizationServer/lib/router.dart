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

final Pattern organizationIdUrl               = new UrlPattern(r'/organization/(\d)+');
final Pattern organizationUrl                 = new UrlPattern(r'/organization');
final Pattern invalidateOrganizationUrl       = new UrlPattern(r'/organization/(\d)+/invalidate');
final Pattern getOrganizationCalendarListUrl  = new UrlPattern(r'/organization/(\d)+/calendar');
final List<Pattern> allUniqueUrls = [organizationIdUrl, organizationUrl, invalidateOrganizationUrl, getOrganizationCalendarListUrl];

void setup(HttpServer server) {
  Router router = new Router(server)
    //..filter(matchAny(allUniqueUrls), authFilter)
    ..serve(organizationIdUrl, method: 'GET').listen(getOrg)
    ..serve(organizationIdUrl, method: 'DELETE').listen(deleteOrg)
    ..serve(organizationUrl,   method: 'POST').listen(createOrg)
    ..serve(organizationIdUrl, method: 'PUT').listen(updateOrg)
    ..serve(organizationUrl,   method: 'GET').listen(getOrgList)
    ..serve(invalidateOrganizationUrl, method: 'POST').listen(invalidateOrg)
    ..serve(getOrganizationCalendarListUrl, method: 'GET').listen(getOrganizationCalendar)
    ..defaultStream.listen(page404);
}
