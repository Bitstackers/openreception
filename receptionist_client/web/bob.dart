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

/**
 * The Bob client. Helping receptionists do their work every day.
 */
import 'dart:async';
import 'dart:html';

import 'classes/bob-active.dart';
import 'classes/bob-disaster.dart';
import 'classes/bob-loading.dart';
import 'config/configuration.dart';
import 'classes/constants.dart';
import 'classes/events.dart' as event;
import 'classes/location.dart' as nav;
import 'model/model.dart'     as Model;
import 'service/service.dart' as Service;
import 'classes/state.dart';
import 'view.nonflex/view.dart' as View;

import 'package:logging/logging.dart';
import 'package:openreception_framework/model.dart' as ORModel;

BobActive bobActive;
BobDisaster bobDiaster;
BobLoading bobLoading;

Logger log = new Logger('Main');

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  Model.AppClientState appState;

  new View.Notification();

  configuration.initialize().then((_) {
    appState = new Model.AppClientState(
                [login(),
                 Service.Notification.instance.connected()]);

    appState.load()
        .then((_) => log.info('Notification socket connected.'))
        .then((_) => state.websocketOK());


    bobLoading = new BobLoading(querySelector('#${Id.bobLoading}'));
    bobDiaster = new BobDisaster(querySelector('#${Id.bobDisaster}'));

    StreamSubscription subscription;
    subscription = event.bus.on(event.stateUpdated).listen((State state) {
      if(state.isOK) {
        bobActive = new BobActive(querySelector('#${Id.bobActive}'));
        subscription.cancel();

        nav.registerOnPopStateListeners();
        /// Reload the model.
        Model.PeerList.instance.reloadFromServer().then(print);
      }
    });
  });
}

Future login() {
  Uri url = Uri.parse(window.location.href);

  if(url.queryParameters.containsKey('settoken')) {
    configuration.token = url.queryParameters['settoken'];
  } else {
    String loginUrl = '${configuration.authBaseUrl}/token/create?returnurl=${window.location.toString()}';
    window.location.replace(loginUrl);
  }

  return Service.Authentication.instance.userOf(configuration.token).then((Model.User user) {
    Model.User.currentUser = user;
  }).catchError((error, stackTrace) {
    log.severe('Failed to load user');
    log.severe (error, stackTrace);
  });
}