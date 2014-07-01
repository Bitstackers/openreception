library receptionserver.router;

import 'dart:io';
import 'dart:convert';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'cache.dart' as cache;
import 'configuration.dart';
import 'database.dart' as db;
import 'package:OpenReceptionFramework/httpserver.dart';
import 'package:OpenReceptionFramework/service.dart' as Service;

part 'router/reception-calendar.dart';
part 'router/getreception.dart';
part 'router/getcalendar.dart';
part 'router/updatereception.dart';
part 'router/deletereception.dart';
part 'router/getreceptionlist.dart';
part 'router/invalidatereception.dart';

final Pattern receptionResource                     = new UrlPattern(r'/reception/(\d+)');
final Pattern receptionUrl                          = new UrlPattern(r'/reception'); //TODO: Deprecate in protocol in favour of the more eloborate /reception/list
final Pattern receptionListResource                 = new UrlPattern(r'/reception/list');
final Pattern receptionInvalidateResource           = new UrlPattern(r'/reception/(\d+)/invalidate');
final Pattern receptionCalendarListResource         = new UrlPattern(r'/reception/(\d+)/calendar');
final Pattern receptionCalendarEventResource        = new UrlPattern(r'/reception/(\d+)/calendar/event/(\d+)');
final Pattern receptionCalendarEventCreateResource  = new UrlPattern(r'/reception/(\d+)/calendar/event');

final List<Pattern> allUniqueUrls = [receptionResource, receptionListResource,
                                     receptionUrl, receptionInvalidateResource,
                                     receptionCalendarListResource,
                                     receptionCalendarEventResource];

void setup(HttpServer server) {
  Router router = new Router(server)
    ..filter(matchAny(allUniqueUrls), auth(config.authUrl))
    ..serve(                   receptionResource, method: 'GET'   ).listen(getReception)
    ..serve(                   receptionResource, method: 'DELETE').listen(deleteReception)
    ..serve(                   receptionResource, method: 'PUT'   ).listen(updateReception)
    ..serve(                        receptionUrl, method: 'GET'   ).listen(getReceptionList)
    ..serve(               receptionListResource, method: 'GET'   ).listen(getReceptionList)
    ..serve(         receptionInvalidateResource, method: 'POST'  ).listen(invalidateReception)
    ..serve(       receptionCalendarListResource, method: 'GET'   ).listen(getReceptionCalendar)
    ..serve(      receptionCalendarEventResource, method: 'GET'   ).listen(ReceptionCalendar.get)
    ..serve(      receptionCalendarEventResource, method: 'PUT'   ).listen(ReceptionCalendar.update)
    ..serve(receptionCalendarEventCreateResource, method: 'POST'  ).listen(ReceptionCalendar.create)
    ..serve(      receptionCalendarEventResource, method: 'DELETE').listen(ReceptionCalendar.remove)
    ..defaultStream.listen(page404);
}
