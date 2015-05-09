library receptionserver.router;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:route/pattern.dart';
import 'package:route/server.dart';
import 'package:logging/logging.dart';

import 'cache.dart' as cache;
import 'configuration.dart';
import 'database.dart' as db;
import 'package:logging/logging.dart';
import 'package:openreception_framework/httpserver.dart';
import 'package:openreception_framework/event.dart'      as Event;
import 'package:openreception_framework/model.dart'      as Model;
import 'package:openreception_framework/service.dart'    as Service;
import 'package:openreception_framework/service-io.dart' as Service_IO;

part 'router/reception-calendar.dart';
part 'router/getreception.dart';
part 'router/updatereception.dart';
part 'router/deletereception.dart';
part 'router/invalidatereception.dart';
part 'router/reception.dart';

final Pattern anything = new UrlPattern(r'/(.*)');
final Pattern receptionResource                     = new UrlPattern(r'/reception/(\d+)');
final Pattern receptionUrl                          = new UrlPattern(r'/reception');
final Pattern receptionListResource                 = new UrlPattern(r'/reception/list');
final Pattern receptionInvalidateResource           = new UrlPattern(r'/reception/(\d+)/invalidate');
final Pattern receptionCalendarListResource         = new UrlPattern(r'/reception/(\d+)/calendar');
final Pattern receptionCalendarEventResource        = new UrlPattern(r'/reception/(\d+)/calendar/event/(\d+)');
final Pattern receptionCalendarEventCreateResource  = new UrlPattern(r'/reception/(\d+)/calendar');

final List<Pattern> allUniqueUrls = [receptionResource, receptionListResource,
                                     receptionUrl, receptionInvalidateResource,
                                     receptionCalendarListResource,
                                     receptionCalendarEventResource];

Service.NotificationService Notification = null;
const String libraryName = 'receptionserver.router';

void connectNotificationService() {
  Notification = new Service.NotificationService
      (config.notificationServer, config.serverToken, new Service_IO.Client());
}

Router setup(HttpServer server) =>
  new Router(server)
    ..filter(matchAny(allUniqueUrls), auth(config.authUrl))
    ..serve(                   receptionResource, method: 'GET'   ).listen(getReception)
    ..serve(                   receptionResource, method: 'DELETE').listen(deleteReception)
    ..serve(                   receptionResource, method: 'PUT'   ).listen(updateReception)
    ..serve(                        receptionUrl, method: 'GET'   ).listen(Reception.list)
    ..serve(               receptionListResource, method: 'GET'   ).listen(Reception.list)
    ..serve(         receptionInvalidateResource, method: 'POST'  ).listen(invalidateReception)
    ..serve(       receptionCalendarListResource, method: 'GET'   ).listen(ReceptionCalendar.list)
    ..serve(      receptionCalendarEventResource, method: 'GET'   ).listen(ReceptionCalendar.get)
    ..serve(      receptionCalendarEventResource, method: 'PUT'   ).listen(ReceptionCalendar.update)
    ..serve(receptionCalendarEventCreateResource, method: 'POST'  ).listen(ReceptionCalendar.create)
    ..serve(      receptionCalendarEventResource, method: 'DELETE').listen(ReceptionCalendar.remove)
    ..serve(anything, method: 'OPTIONS').listen(preFlight)
    ..defaultStream.listen(page404);
