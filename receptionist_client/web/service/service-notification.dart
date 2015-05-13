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

/**
 * Contains a bunch of notification streams for various events.
 */
class Notification {
  Bus<Model.UserStatus>            _agentStateChange      = new Bus<Model.UserStatus>();
  Bus<OREvent.CalendarChange>      _calendarChange        = new Bus<OREvent.CalendarChange>();
  Bus<Model.Call>                  _callStateChange       = new Bus<Model.Call>();
  Bus<Model.ClientConnectionState> _clientConnectionState = new Bus<Model.ClientConnectionState>();
  final Logger                     _log                   = new Logger('$libraryName.Notification');
  ORService.NotificationSocket     _socket                = null;

  /**
   * Constructor.
   */
  Notification (this._socket) {
    _observers();
  }

  /**
   * Fire [event] on relevant bus.
   */
  void _dispatch (OREvent.Event event) {
    if(event is OREvent.CallEvent) {
      _callStateChange.fire(new Model.Call.fromORModel(event.call));
    } else if(event is OREvent.CalendarChange) {
      _calendarChange.fire(event);
    } else if(event is OREvent.ClientConnectionState) {
      _clientConnectionState.fire(new Model.ClientConnectionState.fromMap(event.asMap));
    } else if(event is OREvent.UserState) {
      _agentStateChange.fire(new Model.UserStatus.fromMap(event.asMap));
    } else {
      _log.severe('Failed to dispatch event ${event}');
    }
  }

  /**
   * Agent state change stream.
   */
  Stream<Model.UserStatus> get onAgentStateChange => _agentStateChange.stream;

  /**
   * Call state change stream.
   */
  Stream<Model.Call> get onAnyCallStateChange => _callStateChange.stream;

  /**
   * Calendar Event changes stream.
   */
  Stream<OREvent.CalendarChange> get onCalendarChange => _calendarChange.stream;

  /**
   * Client connection state change stream.
   */
  Stream<Model.ClientConnectionState> get onClientConnectionStateChange => _clientConnectionState.stream;

  /**
   * Observers.
   */
  void _observers() {
    _socket.eventStream.listen(_dispatch);
  }
}
