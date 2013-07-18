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

/**
 * Get the [OrganizationList].
 *
 * Completes with
 *  On success : the [OrganizationList]
 *  On error   : an error message
 */
Future<model.OrganizationList> getOrganizationList() {
  final Completer completer = new Completer<model.OrganizationList>();

  protocol.getOrganizationList().then((protocol.Response response) {
    switch(response.status) {
      case protocol.Response.OK:
        completer.complete(new model.OrganizationList.fromJson(response.data, 'organization_list'));
        break;

      default:
        completer.completeError('storage.getOrganizationList ERROR failed with ${response}');
    }
  })
  .catchError((error) {
    completer.completeError('storage.getOrganizationList ERROR protocol.getOrganizationList failed with ${error}');
  });

  return completer.future;
}
