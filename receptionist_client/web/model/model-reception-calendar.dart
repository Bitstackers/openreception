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

class ReceptionCalendarEntry extends ORModel.CalendarEntry{

  static int get noID => ORModel.CalendarEntry.noID;

  ReceptionCalendarEntry.fromMap(Map map) : super.fromMap(map);

  ReceptionCalendarEntry (int receptionID) :
    super.forReception(receptionID);
}

class ReceptionCalendar {
  /// Local event streams.
  Bus<ReceptionCalendarEntry> _calendarEventCreate = new Bus<ReceptionCalendarEntry>();
  Stream<ReceptionCalendarEntry> get onCalendarEventCreate => _calendarEventCreate.stream;

  Bus<ReceptionCalendarEntry> _calendarEventUpdate = new Bus<ReceptionCalendarEntry>();
  Stream<ReceptionCalendarEntry> get onCalendarEventUpdate => _calendarEventUpdate.stream;

  Bus<ReceptionCalendarEntry> _calendarEventDelete = new Bus<ReceptionCalendarEntry>();
  Stream<ReceptionCalendarEntry> get onCalendarEventDelete => _calendarEventDelete.stream;

  Bus<Iterable<ReceptionCalendarEntry>> _reload = new Bus<Iterable<ReceptionCalendarEntry>>();
  Stream<Iterable<ReceptionCalendarEntry>> get onReload => _reload.stream;


  ReceptionCalendar (Service.Notification notification) {
    this._registerObservers(notification);
  }

  void _registerObservers (Service.Notification notification) {
    notification.onReceptionCalendarEventCreate.listen (_calendarEventCreate.fire);
    notification.onReceptionCalendarEventUpdate.listen (_calendarEventUpdate.fire);
    notification.onReceptionCalendarEventDelete.listen (_calendarEventDelete.fire);
  }
}