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

Map<int, model.Organization> _organizationCache = new Map<int, model.Organization>();

/**
 * Get the [id] [Organization].
 *
 * Completes with
 *  On success   : the [id] [Organization]
 *  On not found : a [nullOrganization]
 *  On error     : an error message.
 */
Future<model.Organization> getOrganization(int id) {
  final Completer completer = new Completer<model.Organization>();

  if (_organizationCache.containsKey(id)) {
    completer.complete(_organizationCache[id]);
  } else {
    protocol.getOrganization(id).then((protocol.Response<model.Organization> response) {
      switch(response.status) {
        case protocol.Response.OK:
          model.Organization org = response.data;
          _organizationCache[org.id] = org;
          completer.complete(org);
          break;

        case protocol.Response.NOTFOUND:
          completer.complete(model.nullOrganization);
          break;

        default:
          completer.completeError('storage.getOrganization ERROR failed with ${response}');
      }
    })
    .catchError((error) {
      completer.completeError('storage.getOrganization ERROR protocol.getOrganization failed with ${error}');
    });
  }

  return completer.future;
}
