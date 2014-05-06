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

Map<int, Map<int, model.Contact>> _contactCache = new Map<int, Map<int, model.Contact>>();


abstract class Contact {
  /**
   * Get the [ContactList].
   *
   * Completes with
   *  On success   : the [ContactList]
   *  On not found : a empty [ContactList]
   *  On error     : an error message.
   */
  static Future<model.ContactList> list(int id) {
    
    const String context = '${libraryName}.getContactList';
    
    final Completer completer = new Completer<model.ContactList>();

    if (_contactListCache.containsKey(id)) {
      debug("Loading contactList from cache.",context);
      completer.complete(_contactListCache[id]);
    } else {
      debug("ContactList not found in cache, loading from http.", context);
      protocol.getContactList(id).then((protocol.Response<model.ContactList> response) {
        switch(response.status) {
          case protocol.Response.OK:
            model.ContactList reception = response.data;
            _contactListCache[id] = reception;
            completer.complete(reception);
            break;

          case protocol.Response.NOTFOUND:
            completer.complete(new model.ContactList.emptyList());
            break;

          default:
            completer.completeError('storage.getContactList ERROR failed with ${response}');
        }
      })
      .catchError((error) {
        completer.completeError('storage.getContactList ERROR protocol.getContactList failed with ${error}');
      });
    }

    return completer.future;
  }
}

/**
 * Get the [Contact].
 *
 * Completes with
 *  On success   : the [Contact]
 *  On not found : a [nullContact]
 *  On error     : an error message.
 */
Future<model.Contact> getContact(int receptionId, int contactId) {
  
  const String context = '${libraryName}.getContact';
  
  final Completer<model.Contact> completer = new Completer<model.Contact>();

  if (_contactCache.containsKey(receptionId) && _contactCache[receptionId].containsKey(contactId)) {
    debug("Loading contact from cache.", context);
    completer.complete(_contactCache[receptionId][contactId]);

  } else {
    debug("Contact not found in cache, loading from http.", context);
    protocol.getContact(receptionId, contactId).then((protocol.Response<model.Contact> response) {
      switch (response.status) {
        case protocol.Response.OK:
          model.Contact contact = response.data;
          if (!_contactCache.containsKey(receptionId)) {
            _contactCache[receptionId] = new Map<int, model.Contact>();
          } else {
            _contactCache[receptionId][contactId] = contact;
          }
          completer.complete(contact);
          break;

        case protocol.Response.NOTFOUND:
          completer.complete(model.nullContact);
          break;

        default:
          completer.completeError('storage.getContact ERROR failed with ${response}');
      }
    }).catchError((error) {
      completer.completeError('storage.getContact ERROR protocol.getContact failed with ${error}');
    });
  }

  return completer.future;
  }
