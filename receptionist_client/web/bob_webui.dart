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

import 'classes/call_handler.dart';
import 'classes/configuration.dart';
import 'classes/keyboardhandler.dart';
import 'classes/logger.dart';

//TESTING
import 'classes/context.dart';
import 'classes/environment.dart';

/**
 * Get Bob going as soon as the configuration is loaded.
 */
void main() {
  log.info('Welcome to Bob.');
  log.user('Velkommen fra Bob.');

  Future<bool> configLoaded = fetchConfig();

  configLoaded.then((_) {
    log.info('configuration loaded.');
    initializeCallHandler();
    _setupGlobalShortcuts();
  }).catchError((error) => log.critical('Bob main exception: ${error}'));

}

void _setupGlobalShortcuts(){
  Context home, messages, contextlog, contextstatistics;
  for(var c in contextList){
    switch(c.id) {
      case 'contexthome':
        home = c;
        break;

      case 'contextmessages':
        messages = c;
        break;

      case 'contextlog':
        contextlog = c;
        break;

      case 'contextstatistics':
        contextstatistics = c;
        break;
    }
  }

  if (home == null) {
    log.critical('It was not possible to find the home context for setting up global keyboardshortcuts.');
  }else if(messages == null) {
    log.critical('It was not possible to find the messages context for setting up global keyboardshortcuts.');
  }else if(contextlog == null) {
    log.critical('It was not possible to find the log context for setting up global keyboardshortcuts.');
  }else if (contextstatistics == null) {
    log.critical('It was not possible to find the statistics context for setting up global keyboardshortcuts.');
  }else{
    keyboardHandler.global = new KeyboardShortcuts()
      ..add(Keys.ONE,   () => home.activate())
      ..add(Keys.TWO,   () => messages.activate())
      ..add(Keys.THREE, () => contextlog.activate())
      ..add(Keys.FOUR,  () => contextstatistics.activate());
  }
}