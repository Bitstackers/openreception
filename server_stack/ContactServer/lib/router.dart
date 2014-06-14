library contactserver.router;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'cache.dart' as cache;
import 'configuration.dart';
import 'package:Utilities/common.dart';
import 'database.dart' as db;
import 'package:Utilities/httpserver.dart';

part 'router/getcalendar.dart';
part 'router/getcontact.dart';
part 'router/getcontactlist.dart';
part 'router/getcontactsphones.dart';
part 'router/getphone.dart';
part 'router/invalidatecontact.dart';
part 'router/contact-calendar.dart';
part 'router/contact.dart';

final Pattern receptionContactInvalidateResource     = new UrlPattern(r'/contact/(\d+)/reception/(\d+)/invalidate');
final Pattern receptionContactResource               = new UrlPattern(r'/contact/(\d+)/reception/(\d+)');
final Pattern receptionContactListResource           = new UrlPattern(r'/contact/list/reception/(\d+)');
final Pattern receptionContactCalendarResource       = new UrlPattern(r'/contact/(\d+)/reception/(\d+)/calendar/event/(\d+)');
final Pattern receptionContactCalendarCreateResource = new UrlPattern(r'/contact/(\d+)/reception/(\d+)/calendar/event');
final Pattern receptionContactCalendarListResource   = new UrlPattern(r'/contact/(\d+)/reception/(\d+)/calendar');

final List<Pattern> allUniqueUrls = 
   [receptionContactInvalidateResource, 
    receptionContactResource, 
    receptionContactListResource,
    receptionContactCalendarResource,
    receptionContactCalendarListResource];

void setup(HttpServer server) {
  Router router = new Router(server)
      ..filter(matchAny(allUniqueUrls), auth(config.authUrl))
      ..serve(              receptionContactResource, method: 'GET'   ).listen(getContact)
      ..serve(          receptionContactListResource, method: 'GET'   ).listen(getContactList)
      ..serve(  receptionContactCalendarListResource, method: 'GET'   ).listen(getContactCalendar)
      ..serve(    receptionContactInvalidateResource, method: 'POST'  ).listen(invalidateReception)
      ..serve(      receptionContactCalendarResource, method: 'GET'   ).listen(ContactCalendar.get)
      ..serve(      receptionContactCalendarResource, method: 'PUT'   ).listen(ContactCalendar.update)
      ..serve(receptionContactCalendarCreateResource, method: 'POST'  ).listen(ContactCalendar.create)
      ..serve(      receptionContactCalendarResource, method: 'DELETE').listen(ContactCalendar.remove)
      ..defaultStream.listen(page404);
}
