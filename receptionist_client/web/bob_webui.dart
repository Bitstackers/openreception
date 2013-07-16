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

/**
 * The Bob client. Helping receptionists do their work every day.
 */
import 'dart:async';

import 'package:web_ui/web_ui.dart';

import 'classes/configuration.dart';
import 'classes/logger.dart';

@observable bool bobReady = false;

/**
 * Get Bob going as soon as the configuration is loaded.
 */
void main() {
  fetchConfig().then((_) {
    log.info('Bob is ready to serve. Welcome!', toUserLog: true);
    log.debug('Stand back, Bob is about to start.');
    log.debug('Here he comes....');
    log.debug('Ladies and gentlemen, please join me in a warm round of applause for Bob!!!');
    log.debug('---------------------------------------------------------');
    bobReady = true;
  }).catchError((error) => log.critical('Bob main exception: ${error}'));
}
