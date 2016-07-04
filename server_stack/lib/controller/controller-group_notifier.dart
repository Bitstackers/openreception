/*                  This file is part of OpenReception
                   Copyright (C) 2016-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library openreception.server.controller.group_notifier;

import 'dart:async';

import 'package:openreception.framework/event.dart' as event;
import 'package:openreception.framework/service.dart' as service;

/**
 * Controller class that is responsible for muticasting a message to a
 * group of clients.
 */
class GroupNotifier {
  final service.NotificationService _notificationService;
  final List<int> _uids;

  /**
   * Create a new [GroupNotifier] that sends events to the websockets of
   * users with id's in [uids], using [_notificationService] as backend.
   */
  GroupNotifier(this._notificationService, Iterable<int> uids)
      : _uids = new List<int>.from(uids);

  /**
   * Forward all events in [streams] to the users with id's [_uids].
   */
  void listenAll(Iterable<Stream<event.Event>> streams) {
    for (Stream s in streams) {
      s.listen((e) {
        _notificationService.send(_uids, e);
      });
    }
  }
}
