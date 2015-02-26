/*                  This file is part of OpenReception
                   Copyright (C) 2012-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/
part of model;

class CalendarEvent extends ORModel.CalendarEvent {

  static int get noID => ORModel.CalendarEvent.noID;

  CalendarEvent.fromMap(Map map, int receptionID, {int contactID : ORModel.CalendarEvent.noID}) : super.fromMap(map, receptionID, contactID : contactID);

  CalendarEvent.forReception(int receptionID) : super.forReception(receptionID);

  CalendarEvent.forContact (int contactID, int receptionID) : super.forContact(contactID, receptionID);

  static findEvent (int eventID, List<CalendarEvent> events) => events.firstWhere((CalendarEvent event) => event.ID == eventID);

  static final EventType<Map> reload = new EventType<Map>();

  /// Local event stream.
  static EventBus _eventStream = new EventBus();
  static EventBus get events => _eventStream;

  List<CalendarEvent> _list = new List<CalendarEvent>();

  Iterator<CalendarEvent> get iterator => _list.iterator;

  static void registerObservers () {

    event.bus.on(Service.EventSocket.contactCalendarEventCreated).listen((Map event) {
      Map calendarEvent = event['calendarEvent'];
      storage.Contact.invalidateCalendar(calendarEvent['contactID'], calendarEvent['receptionID']);
      _eventStream.fire(reload, calendarEvent);
    });

    event.bus.on(Service.EventSocket.contactCalendarEventUpdated).listen((Map event) {
      Map calendarEvent = event['calendarEvent'];
      storage.Contact.invalidateCalendar(calendarEvent['contactID'], calendarEvent['receptionID']);
      _eventStream.fire(reload, calendarEvent);
    });

    event.bus.on(Service.EventSocket.contactCalendarEventDeleted).listen((Map event) {
      Map calendarEvent = event['calendarEvent'];
      storage.Contact.invalidateCalendar(calendarEvent['contactID'], calendarEvent['receptionID']);
      _eventStream.fire(reload, calendarEvent);
    });

    event.bus.on(Service.EventSocket.receptionCalendarEventCreated).listen((Map event) {
      Map calendarEvent = event['calendarEvent'];
      storage.Reception.invalidateCalendar(calendarEvent['receptionID']);
      _eventStream.fire(reload, calendarEvent);
    });

    event.bus.on(Service.EventSocket.receptionCalendarEventUpdated).listen((Map event) {
      Map calendarEvent = event['calendarEvent'];
      storage.Reception.invalidateCalendar(calendarEvent['receptionID']);
      _eventStream.fire(reload, calendarEvent);
    });

    event.bus.on(Service.EventSocket.receptionCalendarEventDeleted).listen((Map event) {
      Map calendarEvent = event['calendarEvent'];
      storage.Reception.invalidateCalendar(calendarEvent['receptionID']);
      _eventStream.fire(reload, calendarEvent);
    });
  }
}


Future saveCalendarEvent(ORModel.CalendarEvent event) {
  /// Dispatch to the correct service.
  if (event.contactID != Contact.noContact.ID) {
    if (event.ID == Contact.noContact.ID) {
      return Service.Contact.store.calendarEventCreate(event);
    } else {
      return Service.Contact.store.calendarEventUpdate(event);
    }
  } else if (event.receptionID != Reception.noReception.ID) {
    if (event.ID == ORModel.CalendarEvent.noID) {
      return Service.Reception.store.calendarEventCreate(event);
    } else {
      return Service.Reception.store.calendarEventUpdate(event);
    }
  } else {
    return new Future(() {
      throw new StateError("Trying to update an event object without an owner!");
    });
  }
}

Future deleteCalendarEvent(ORModel.CalendarEvent event) {
  /// Dispatch to the correct service.
  if (event.contactID != Contact.noContact.ID) {
    return Service.Contact.store.calendarEventRemove(event);
  } else if (event.receptionID != Reception.noReception.ID) {
    return Service.Reception.store.calendarEventRemove(event);
  } else {
    return new Future(() {
      throw new StateError("Trying to update an event object without an owner!");
    });
  }
}

findEvent (List<ORModel.CalendarEvent> events, int eventID) =>
   events.firstWhere((ORModel.CalendarEvent event) => event.ID == eventID);