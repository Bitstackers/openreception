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

part of openreception.call_flow_control_server.controller;

/**
 * Controller class that is responsible for notifying clients about state
 * changes in the call-flow-control server.
 * Listens to model changes, and sends these to the appropriate clients.
 */
class ClientNotifier {

  Logger _log = new Logger('controller.ClientNotifier');

  final ORService.NotificationService _notificationServer;
  StreamSubscription _callListSubscription;

  ClientNotifier(this._notificationServer) {
  }

  void listenForCallEvents(Model.CallList callList) {
    void logError(error, stackTrace) =>
        _log.shout('Failed to dispatch event', error, stackTrace);


    _callListSubscription = callList.onEvent.
        listen(_notificationServer.broadcastEvent, onError: logError);
  }

  Future cancelCallEventSubscription() =>
    _callListSubscription.cancel();

}