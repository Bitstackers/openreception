/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library openreception.server.controller.client_notifier;

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:openreception.framework/model.dart' as model;
import 'package:openreception.framework/service.dart' as service;
import 'package:openreception.server/model.dart' as model;

/**
 * Controller class that is responsible for notifying clients about state
 * changes in the user server.
 * Listens to model changes, and sends these to the appropriate clients.
 */
class ClientNotifier {
  Logger _log = new Logger('server.controller.client_notifier');

  final service.NotificationService _notificationServer;
  StreamSubscription _userStateListSubscription;

  ClientNotifier(this._notificationServer);

  StreamSubscription userStateSubscribe(model.UserStatusList statusList) {
    void logError(error, stackTrace) =>
        _log.shout('Failed to dispatch event', error, stackTrace);

    _userStateListSubscription = statusList.onChange
        .listen(_notificationServer.broadcastEvent, onError: logError);

    return _userStateListSubscription;
  }

  Future cancelCallEventSubscription() => _userStateListSubscription.cancel();
}
