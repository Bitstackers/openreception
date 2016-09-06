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

part of orf.model;

/// 'bitvector' class representing different messageflags that can be set.
class MessageFlag {
  bool pleaseCall = false;
  bool willCallBack = false;
  bool called = false;
  bool urgent = false;

  /// Default constructor.
  MessageFlag(Iterable<String> flags) {
    pleaseCall = flags.contains(key.pleaseCall);
    willCallBack = flags.contains(key.willCallBack);
    called = flags.contains(key.called);
    urgent = flags.contains(key.urgent);
  }

  /// Default empty constructor.
  MessageFlag.empty();

  /// JSON serialization function.
  List<String> toJson() {
    final List<String> retVal = <String>[];

    pleaseCall ? retVal.add(key.pleaseCall) : '';
    willCallBack ? retVal.add(key.willCallBack) : '';
    called ? retVal.add(key.called) : '';
    urgent ? retVal.add(key.urgent) : '';

    return retVal;
  }
}
