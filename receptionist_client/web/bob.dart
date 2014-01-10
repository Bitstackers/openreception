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
//import 'dart:async';
//
//import 'classes/common.dart';
//import 'classes/configuration.dart';
//import 'classes/logger.dart';
//import 'classes/notification.dart';

//Future _configurationCheck() => repeatCheck(configuration.isLoaded, 0, new Duration(milliseconds: 50), timeoutMessage: 'configuration.isLoaded is false');
//Future _notificationCheck() => repeatCheck(notification.isConnected, 0, new Duration(milliseconds: 100), timeoutMessage: 'notification.isConnected is false');

/**
 * Get Bob going as soon as the configuration is loaded.
 */
//@initMethod
//void main() {
//  _configurationCheck().then((_) => _notificationCheck())
//                       .then((_) => log.debug('Main -- Everything seems to work! --'))
//                       .catchError((error) {
//                         log.critical('Bob main exception: ${error}');
//                       });
//}

import 'dart:async';
import 'dart:html';

import 'classes/bobactive.dart';
import 'classes/bobdisaster.dart';
import 'classes/bobloading.dart';
import 'classes/boblogin.dart';
import 'classes/events.dart' as event;
import 'classes/state.dart';

BobActive bobActive;
BobDisaster bobDiaster;
BobLoading bobLoading;
BobLogin boblogin;

int userId = 1;

void main() {

  boblogin = new BobLogin(querySelector('#boblogin'));

  //notification.initialize();
  //configuration.initialize();

  bobLoading = new BobLoading(querySelector('#bobloading'));
  bobDiaster = new BobDisaster(querySelector('#bobdisaster'));

  StreamSubscription subscription;
  subscription = event.bus.on(event.stateUpdated).listen((State value) {
    if(value.isConfigurationOK) {

      bobActive = new BobActive(querySelector('#bobactive'));
      subscription.cancel();
    }
  });
}


