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

Map<int, model.ContactList> _contactListCache = new Map<int, model.ContactList>();

/**
 * Get the [ContactList].
 *
 * Completes with
 *  On success   : the [ContactList]
 *  On not found : a empty [ContactList]
 *  On error     : an error message.
 */
Future<model.ContactList> getContactList(int id) {
  
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
