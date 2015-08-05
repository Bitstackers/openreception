/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library openreception.bus;

import 'dart:async';

/**
 * Type "safe" event bus, using the Dart Stream API.
 *
 * This is basically just a thin wrapper around [StreamController].
 */
class Bus<Type> {
  StreamController _streamController;

  /**
   * Get the [Stream] stream.
   */
  Stream<Type> get stream => _streamController.stream;

  Bus() {
    _streamController = new StreamController.broadcast();
  }

  /**
   * Push a [Type] event to the [Stream].
   */
  void fire(Type event) {
    _streamController.add(event);
  }

  /**
   * Close the [Stream].
   */
  Future close() => _streamController.close();
}
