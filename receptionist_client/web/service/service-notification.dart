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
part of service;

class Notification {

  Logger log = new Logger('$libraryName.Notification');


  ORService.NotificationSocket _socket = null;

  Notification (this._socket) {
    _socket.eventStream.listen(_dispatch);
  }

  /// Contact calendar entry create
  Bus<Model.Call> _callStateChange = new Bus<Model.Call>();
  Stream<Model.Call> get onAnyCallStateChange => _callStateChange.stream;


  /// Contact calendar entry create
  Bus<Model.ContactCalendarEntry> _onContactCalendarEventCreate =
      new Bus<Model.ContactCalendarEntry>();
  Stream<Model.ContactCalendarEntry> get onContactCalendarEventCreate =>
      _onContactCalendarEventCreate.stream;

  /// Contact calendar entry update
  Bus<Model.ContactCalendarEntry> _onContactCalendarEventUpdate =
      new Bus<Model.ContactCalendarEntry>();
  Stream<Model.ContactCalendarEntry> get onContactCalendarEventUpdate =>
      _onContactCalendarEventUpdate.stream;

  /// Contact calendar entry delete
  Bus<Model.ContactCalendarEntry> _onContactCalendarEventDelete =
      new Bus<Model.ContactCalendarEntry>();
  Stream<Model.ContactCalendarEntry> get onContactCalendarEventDelete =>
      _onContactCalendarEventDelete.stream;

  /// Reception calendar entry create
  Bus<Model.ReceptionCalendarEntry> _onReceptionCalendarEventCreate =
      new Bus<Model.ReceptionCalendarEntry>();
  Stream<Model.ReceptionCalendarEntry> get onReceptionCalendarEventCreate =>
      _onReceptionCalendarEventCreate.stream;

  /// Reception calendar entry update
  Bus<Model.ReceptionCalendarEntry> _onReceptionCalendarEventUpdate =
      new Bus<Model.ReceptionCalendarEntry>();
  Stream<Model.ReceptionCalendarEntry> get onReceptionCalendarEventUpdate =>
      _onReceptionCalendarEventUpdate.stream;

  /// Reception calendar entry delete
  Bus<Model.ReceptionCalendarEntry> _onReceptionCalendarEventDelete =
      new Bus<Model.ReceptionCalendarEntry>();
  Stream<Model.ReceptionCalendarEntry> get onReceptionCalendarEventDelete =>
      _onReceptionCalendarEventDelete.stream;

  void _dispatch (OREvent.Event event) {
    if (event is OREvent.CallEvent) {
      _dispatchCall(event);
    }
    else if(event is OREvent.CalendarEvent) {
      _dispatchCalender(event);
    }
    else {
      log.severe('Failed to dispatch event ${event}');
    }
  }

  _dispatchCalender(event) {
    if (event is OREvent.ContactCalendarEntryCreate) {
      _onContactCalendarEventCreate.fire (event.calendarEntry);
    }

    else if (event is OREvent.ContactCalendarEntryUpdate) {
      _onContactCalendarEventUpdate.fire (event.calendarEntry);
    }

    else if (event is OREvent.ContactCalendarEntryDelete) {
      _onContactCalendarEventDelete.fire (event.calendarEntry);
    }
    else if (event is OREvent.ReceptionCalendarEntryCreate) {
      _onReceptionCalendarEventCreate.fire (event.calendarEntry);
    }

    else if (event is OREvent.ReceptionCalendarEntryUpdate) {
      _onReceptionCalendarEventUpdate.fire (event.calendarEntry);
    }

    else if (event is OREvent.ReceptionCalendarEntryDelete) {
      _onReceptionCalendarEventDelete.fire (event.calendarEntry);
    }

  }

  void _dispatchCall (OREvent.CallEvent event) {
    this._callStateChange.fire(new Model.Call.fromORModel(event.call));
  }
}