/*                  This file is part of OpenReception
                   Copyright (C) 2012-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library commands;

import 'dart:async';

import 'logger.dart';
import '../model/model.dart' as model;
import '../protocol/protocol.dart' as protocol;
import '../storage/storage.dart' as storage;

const CONTACTID_TYPE = 1;
const PSTN_TYPE = 2;
const SIP_TYPE = 3;


const String libraryName = 'commands';

abstract class CommandHandlers {

  static const String className = '${libraryName}.CommandHandlers';

  /**
   * Registers the appropriate command handlers.
   */
  static void registerListeners() {}

}
