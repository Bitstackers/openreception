/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

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

/**
 * A list of [CalendarEvent] objects.
 */
class CalendarEventList extends IterableBase<CalendarEvent> {

  static const String className = '${libraryName}.CalendarEventList';

  static final EventType<Map> reload = new EventType<Map>();

  /// Local event stream.
  static EventBus _eventStream = new EventBus();
  static EventBus get events => _eventStream;

  List<CalendarEvent> _list = new List<CalendarEvent>();

  Iterator<CalendarEvent> get iterator => _list.iterator;

  static void registerObservers () {
    const String context = '${className}.registerObservers';
    event.bus.on(Service.EventSocket.contactCalendarEventCreated).listen((Map event) {
      Map calendarEvent = event['calendarEvent'];
      storage.Contact.invalidateCalendar(calendarEvent['contactID'], calendarEvent['receptionID']);
      log.debugContext('Notifying about change in calendar event list', context);
      _eventStream.fire(reload, calendarEvent);
    });

    event.bus.on(Service.EventSocket.receptionCalendarEventCreated).listen((Map event) {
      Map calendarEvent = event['calendarEvent'];
      storage.Reception.invalidateCalendar(calendarEvent['receptionID']);
      log.debugContext('Notifying about change in calendar event list', context);
      _eventStream.fire(reload, calendarEvent);
    });

    event.bus.on(Service.EventSocket.receptionCalendarEventUpdated).listen((Map event) {
      Map calendarEvent = event['calendarEvent'];
      storage.Reception.invalidateCalendar(calendarEvent['receptionID']);
      log.debugContext('Notifying about change in calendar event list', context);
      _eventStream.fire(reload, calendarEvent);
    });

    event.bus.on(Service.EventSocket.receptionCalendarEventDeleted).listen((Map event) {
      Map calendarEvent = event['calendarEvent'];
      storage.Reception.invalidateCalendar(calendarEvent['receptionID']);
      log.debugContext('Notifying about change in calendar event list', context);
      _eventStream.fire(reload, calendarEvent);
    });

  
  }

  /**
   * [CalendarEventList] constructor.
   */
  CalendarEventList();

  /**
   * [CalendarEventList] constructor. Builds a list of [CalendarEvent] objects
   * from the contents of json[key].
   */
  factory CalendarEventList.fromMap(List<Map> list) {

    const String context = '${className}.CalendarEventList.fromMap';

    CalendarEventList calendarEventList = new CalendarEventList();

    try {
      calendarEventList = new CalendarEventList._fromList(list);
    } catch (error) {
       log.criticalError(error, context);
    }

    return calendarEventList;
  }

  /**
   * [CalendarEventList] internal constructor for building up the internal list of.
   */
  CalendarEventList._fromList(List<Map> list) {
    list.forEach((item) => this._list.add(new CalendarEvent.fromJson(item)));
    this._list.sort();
  }
  
  /**
   * Retrieves a single CalendarEvent based on its ID.
   */
  CalendarEvent get (int eventID) {
    return this.firstWhere((CalendarEvent event) => event.ID == eventID);
   }
}
