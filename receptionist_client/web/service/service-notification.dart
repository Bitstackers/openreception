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
part of service;

class Notification {

  Logger log = new Logger('$libraryName.Notification');


  ORService.NotificationSocket _socket = null;

  Notification (this._socket) {
    _socket.eventStream.listen(_dispatch);
  }

  /// Agent state change
  Bus<Model.UserStatus> _agentStateChange = new Bus<Model.UserStatus>();
  Stream<Model.UserStatus> get onAgentStateChange => _agentStateChange.stream;

  /// Call state change
  Bus<Model.Call> _callStateChange = new Bus<Model.Call>();
  Stream<Model.Call> get onAnyCallStateChange => _callStateChange.stream;

  /// Client connection state change
  Bus<Model.ClientConnectionState> _clientConnectionState = new Bus<Model.ClientConnectionState>();
  Stream<Model.ClientConnectionState> get onClientConnectionStateChange => _clientConnectionState.stream;

  /// Calendar Event changes
  Bus<OREvent.CalendarChange> _calendarChange = new Bus<OREvent.CalendarChange>();
  Stream<OREvent.CalendarChange> get onCalendarChange => _calendarChange.stream;

  void _dispatch (OREvent.Event event) {
    if (event is OREvent.CallEvent) {
      _dispatchCall(event);
    }
    else if(event is OREvent.CalendarChange) {
      this._calendarChange.fire(event);
    }
    else if(event is OREvent.UserState) {
      _agentStateChange.fire(new Model.UserStatus.fromMap(event.asMap));
    } else {
      log.severe('Failed to dispatch event ${event}');
    }
  }

  void _dispatchCall (OREvent.CallEvent event) {
    this._callStateChange.fire(new Model.Call.fromORModel(event.call));
  }
}