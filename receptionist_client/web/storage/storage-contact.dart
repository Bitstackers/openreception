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

part of storage;

abstract class Contact {

  static Map<int, Map<int, model.Contact>> _contactCache = new Map<int, Map<int, model.Contact>>();

  static Map<int, model.ContactList> _contactListCache = new Map<int, model.ContactList>();

  static Map<int, Map<int, model.CalendarEventList>> _calendarCache = new Map<int, Map<int, model.CalendarEventList>>();
  
  static void invalidateCalendar (int contactID, int receptionID) {
    if (_calendarCache.containsKey(receptionID)) {
      if (_calendarCache[receptionID].containsKey(contactID)) {
        _calendarCache[receptionID].remove(contactID);
      }
    }
  }
  
  /**
   * Get the [ContactList].
   *
   * Completes with
   *  On success   : the [ContactList]
   *  On not found : a empty [ContactList]
   *  On error     : an error message.
   */
  static Future<model.ContactList> list(int receptionID) {
    const String context = '${libraryName}.list';

    final Completer completer = new Completer<model.ContactList>();

    if (_contactListCache.containsKey(receptionID)) {
      debugStorage("Loading contact list from cache.", context);
      completer.complete(_contactListCache[receptionID]);
    } else {
      debugStorage("Contact list not found in cache, loading from http.", context);
      Service.Contact.list(receptionID).then((model.ContactList contactList) {
        _contactListCache[receptionID] = contactList;
        completer.complete(contactList);
      }).catchError((error) {
        completer.completeError(error);
      });
    }

    return completer.future;
  }

  static Future<model.CalendarEventList> calendar(int contactID, int receptionID) {
    const String context = '${libraryName}.calendar';

    final Completer completer = new Completer<model.CalendarEventList>();

    if (_calendarCache.containsKey(receptionID) && _calendarCache[receptionID].containsKey(contactID)) {
      debugStorage("Loading contact calendar from cache.", context);
      completer.complete(_calendarCache[receptionID][contactID]);

    } else {
      debugStorage("Contact Calendar not found in cache, loading from http.", context);
      Service.Contact.calendar(contactID, receptionID).then((model.CalendarEventList eventList) {

        if (!_calendarCache.containsKey(receptionID)) {
          _calendarCache[receptionID] = new Map<int, model.CalendarEventList>();
        } else {
          _calendarCache[receptionID][contactID] = eventList;
        }

        completer.complete(eventList);
      }).catchError((error) {
        completer.completeError(error);
      });
    }

    return completer.future;
  }

  /**
   * Get the [Contact].
   *
   * Completes with
   *  On success   : the [Contact]
   *  On not found : a [nullContact]
   *  On error     : an error message.
   */
  static Future<model.Contact> get(int contactID, int receptionID) {

    const String context = '${libraryName}.getContact';

    final Completer<model.Contact> completer = new Completer<model.Contact>();

    if (_contactCache.containsKey(receptionID) && _contactCache[receptionID].containsKey(contactID)) {
      debugStorage("Loading contact from cache.", context);
      completer.complete(_contactCache[receptionID][contactID]);

    } else {
      debugStorage("Contact not found in cache, loading from http.", context);
      Service.Contact.get(contactID, receptionID).then((model.Contact contact) {
        if (!_contactCache.containsKey(receptionID)) {
          _contactCache[receptionID] = new Map<int, model.Contact>();
        } else {
          _contactCache[receptionID][contactID] = contact;
        }
        completer.complete(contact);
      }).catchError((error) {
        completer.completeError('storage.getContact ERROR protocol.getContact failed with ${error}');
      });
    }

    return completer.future;
  }
}
