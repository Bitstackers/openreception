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

part of openreception.model;

/**
 * 'bitvector' class representing different messageflags that can be set.
 */
class MessageFlag {
  bool pleaseCall = false;
  bool willCallBack = false;
  bool called = false;
  bool urgent = false;
  bool manuallyClosed = false;

  /**
   * Default empty constructor.
   */
  MessageFlag.empty();

  /**
   * Default constructor.
   */
  MessageFlag(Iterable<String> flags) {
    pleaseCall = flags.contains(Key.pleaseCall);
    willCallBack = flags.contains(Key.willCallBack);
    called = flags.contains(Key.called);
    urgent = flags.contains(Key.urgent);
    manuallyClosed = flags.contains(Key.manuallyClosed);
  }

  /**
   * JSON serialization function.
   */
  List toJson() {
    List<String> retVal = [];

    pleaseCall ? retVal.add(Key.pleaseCall) : '';
    willCallBack ? retVal.add(Key.willCallBack) : '';
    called ? retVal.add(Key.called) : '';
    urgent ? retVal.add(Key.urgent) : '';
    manuallyClosed ? retVal.add(Key.manuallyClosed) : '';

    return retVal;
  }

}