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

Map<int, model.Reception> _receptionCache = new Map<int, model.Reception>();

/**
 * Get the [id] [Reception].
 *
 * Completes with
 *  On success   : the [id] [Reception]
 *  On not found : a [nullReception]
 *  On error     : an error message.
 */
Future<model.Reception> getReception(int id) {
  final Completer completer = new Completer<model.Reception>();

  if (_receptionCache.containsKey(id)) {
    //TODO DEEP CLONE
    completer.complete(_receptionCache[id]);
  } else {
    protocol.getReception(id).then((protocol.Response<model.Reception> response) {
      switch (response.status) {
        case protocol.Response.OK:
          model.Reception reception = response.data;
          _receptionCache[reception.id] = reception;
          completer.complete(reception);
          break;

        case protocol.Response.NOTFOUND:
          completer.complete(model.nullReception);
          break;

        default:
          completer.completeError('storage.getReception ERROR failed with ${response}');
      }
    }).catchError((error) {
      completer.completeError('storage.getReception ERROR protocol.getReception failed with ${error}');
    });
  }

  return completer.future;
}
