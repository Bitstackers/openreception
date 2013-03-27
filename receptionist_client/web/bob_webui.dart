/*                                Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This library is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License and
  a copy of the GCC Runtime Library Exception along with this program;
  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
  <http://www.gnu.org/licenses/>.
*/

/**
 * The Bob client. Helping receptionists do their work every day.
 */
import 'dart:async';
import 'dart:html';
import 'dart:uri';

import 'classes/call_handler.dart';
import 'classes/common.dart';
import 'classes/configuration.dart';
import 'classes/environment.dart';
import 'classes/keyboardhandler.dart';
import 'classes/logger.dart';
import 'classes/storage.dart';

/**
 * Instantiates all the [view] objects and gets Bob going.
 */
void main() {
  log.info('Welcome to Bob.');

  Future<bool> configLoaded = fetchConfig();

  configLoaded.then((_) {
    log.info('configuration loaded.');
    initializeCallHandler();
  }).catchError((error) => log.critical('Bob main exception: ${error.toString()}'));

}