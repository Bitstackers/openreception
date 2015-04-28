library contactserver.router;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'cache.dart' as cache;
import 'configuration.dart';
import 'database.dart' as db;
import 'package:logging/logging.dart';
import 'package:openreception_framework/httpserver.dart';
import 'package:openreception_framework/model.dart'   as Model;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/service-io.dart' as Service_IO;

part 'router/getcontact.dart';
part 'router/getcontactlist.dart';
part 'router/getcontactsphones.dart';
part 'router/getphone.dart';
part 'router/invalidatecontact.dart';
part 'router/contact-calendar.dart';
part 'router/contact.dart';

const String libraryName = 'contactserver.router';

final Pattern anything = new UrlPattern(r'/(.*)');
final Pattern receptionContactInvalidateResource     = new UrlPattern(r'/contact/(\d+)/reception/(\d+)/invalidate');
final Pattern receptionContactResource               = new UrlPattern(r'/contact/(\d+)/reception/(\d+)');
final Pattern receptionContactListResource           = new UrlPattern(r'/contact/list/reception/(\d+)');
final Pattern receptionContactCalendarResource       = new UrlPattern(r'/contact/(\d+)/reception/(\d+)/calendar/event/(\d+)');
final Pattern receptionContactCalendarCreateResource = new UrlPattern(r'/contact/(\d+)/reception/(\d+)/calendar');
final Pattern receptionContactCalendarListResource   = new UrlPattern(r'/contact/(\d+)/reception/(\d+)/calendar');

final List<Pattern> allUniqueUrls =
   [receptionContactInvalidateResource,
    receptionContactResource,
    receptionContactListResource,
    receptionContactCalendarResource,
    receptionContactCalendarListResource];

Service.Authentication      AuthService  = null;
Service.NotificationService Notification = null;

void connectAuthService() {
  AuthService = new Service.Authentication
      (config.authUrl, config.serverToken, new Service_IO.Client());
}

void connectNotificationService() {
  Notification = new Service.NotificationService
      (config.notificationServer, config.serverToken, new Service_IO.Client());
}


Router setup(HttpServer server) =>
  new Router(server)
    ..filter(matchAny(allUniqueUrls), auth(config.authUrl))
    ..serve(              receptionContactResource, method: 'GET'   ).listen(Contact.get)
    ..serve(          receptionContactListResource, method: 'GET'   ).listen(getContactList)
    ..serve(    receptionContactInvalidateResource, method: 'POST'  ).listen(invalidateReception)
    ..serve(  receptionContactCalendarListResource, method: 'GET'   ).listen(ContactCalendar.list)
    ..serve(      receptionContactCalendarResource, method: 'GET'   ).listen(ContactCalendar.get)
    ..serve(      receptionContactCalendarResource, method: 'PUT'   ).listen(ContactCalendar.update)
    ..serve(receptionContactCalendarCreateResource, method: 'POST'  ).listen(ContactCalendar.create)
    ..serve(      receptionContactCalendarResource, method: 'DELETE').listen(ContactCalendar.remove)
    ..serve(anything, method: 'OPTIONS').listen(preFlight)
    ..defaultStream.listen(page404);
