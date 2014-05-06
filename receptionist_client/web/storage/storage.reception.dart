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


abstract class Reception {
  
  /**
   * Get the [id] [Reception].
   *
   * Completes with
   *  On success   : the [id] [Reception]
   *  On not found : a [nullReception]
   *  On error     : an error message.
   */
  static Future<model.Reception> get(int id) {

    const String context = '${libraryName}.getReception';

    final Completer completer = new Completer<model.Reception>();

    if (_receptionCache.containsKey(id)) {
      debug("Loading reception from cache.", context);
      completer.complete(_receptionCache[id]);
    } else {
      debug("Reception not found in cache, loading from http.", context);
      Service.Reception.single(id).then((model.Reception reception) {
        // Store the reception in the cache.
        _receptionCache[reception.id] = reception;
        completer.complete(reception);
      }).catchError((error) {
        completer.completeError(error);
      });
    }

    return completer.future;
  }
}
