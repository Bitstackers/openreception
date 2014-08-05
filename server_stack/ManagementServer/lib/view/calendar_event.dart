library adaheads.server.view.calendar;

import 'dart:convert';

import '../model.dart';

String listEventsAsJson(List<Event> events) =>
    JSON.encode({'events':_listEventAsJsonList(events)});

Map _eventAsJsonMap(Event event) => event == null ? {} :
    {'id'     : event.id,
     'start'  : event.start.millisecondsSinceEpoch~/1000,
     'stop'   : event.stop.millisecondsSinceEpoch~/1000,
     'content': event.message};

List _listEventAsJsonList(List<Event> events) =>
    events.map(_eventAsJsonMap).toList();
