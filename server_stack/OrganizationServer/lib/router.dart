library router;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'cache.dart' as cache;
import 'db.dart' as db;
import '../../Shared/httpserver.dart';

import 'package:route/server.dart';

part 'router/getorganization.dart';
part 'router/updateorganization.dart';
part 'router/createorganization.dart';
part 'router/deleteorganization.dart';
part 'router/getorganizationlist.dart';
part 'router/invalidateorganization.dart';

final Pattern getOrganizationUrl        = new UrlPattern(r'/organization/(\d)*');
final Pattern deleteOrganizationUrl     = new UrlPattern(r'/organization/(\d)*');
final Pattern createOrganizationUrl     = new UrlPattern('/organization');
final Pattern updateOrganizationUrl     = new UrlPattern(r'/organization/(\d)*');
final Pattern getOrganizationListUrl    = new UrlPattern('/organization/list');
final Pattern invalidateOrganizationUrl = new UrlPattern(r'/organization/(\d)*/invalidate');

void setup(HttpServer server) {
  Router router = new Router(server)
    ..serve(getOrganizationUrl, method: 'GET').listen(getOrg)
    ..serve(deleteOrganizationUrl, method: 'DELETE').listen(deleteOrg)
    ..serve(createOrganizationUrl, method: 'POST').listen(createOrg)
    ..serve(updateOrganizationUrl, method: 'PUT').listen(updateOrg)
    ..serve(getOrganizationListUrl, method: 'GET').listen(getOrgList)
    ..serve(invalidateOrganizationUrl, method: 'POST').listen(invalidateOrg)
    ..defaultStream.listen(page404);
}
