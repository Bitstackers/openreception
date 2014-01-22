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
import 'dart:html';

import 'classes/bobactive.dart';
import 'classes/bobdisaster.dart';
import 'classes/bobloading.dart';
import 'classes/boblogin.dart';
import 'classes/configuration.dart';
import 'classes/events.dart' as event;
import 'classes/location.dart';
import 'classes/notification.dart';
import 'classes/state.dart';

BobActive bobActive;
BobDisaster bobDiaster;
BobLoading bobLoading;
BobLogin boblogin;

int userId = 1;

void main() {
  Uri url = Uri.parse(window.location.href);
  if(url.queryParameters.containsKey('settoken')) {
    configuration.token = url.queryParameters['settoken']; 
  } else {
    window.location.assign('http://auth.adaheads.com');
  }
  
  configuration.initialize().then((_) {
    notification.initialize();
  });
  
  //boblogin = new BobLogin(querySelector('#boblogin'));

  //notification.initialize();
  //configuration.initialize();

  bobLoading = new BobLoading(querySelector('#bobloading'));
  bobDiaster = new BobDisaster(querySelector('#bobdisaster'));

  StreamSubscription subscription;
  subscription = event.bus.on(event.stateUpdated).listen((State value) {
    if(value.isConfigurationOK) {
      bobActive = new BobActive(querySelector('#bobactive'));
      subscription.cancel();
      
      registerOnPopStateListeners();
    }
  });
}


