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

part of controller;

/**
 * Contains a bunch of notification streams for various events.
 */
class Notification {
  Bus<ORModel.UserStatus>          _agentStateChangeBus      = new Bus<ORModel.UserStatus>();
  final Model.AppClientState       _appState;
  Bus<OREvent.CalendarChange>      _calendarChangeBus        = new Bus<OREvent.CalendarChange>();
  Bus<OREvent.CallEvent>            _callStateChangeBus       = new Bus<OREvent.CallEvent>();
  Bus<Model.ClientConnectionState> _clientConnectionStateBus = new Bus<Model.ClientConnectionState>();
  final Logger                     _log                      = new Logger('$libraryName.Notification');
  ORService.NotificationSocket     _socket                   = null;

  /**
   * Constructor.
   */
  Notification (ORService.NotificationSocket this._socket, Model.AppClientState this._appState) {
    _observers();
  }

  /**
   * Handle the [OREvent.CalendarChange] [event].
   */
  void _calendarChange(OREvent.CalendarChange event) {
    _calendarChangeBus.fire(event);
  }

  /**
   * Handle the [OREvent.CallEvent] [event].
   */
  void _callEvent(OREvent.CallEvent event) {
    _callStateChangeBus.fire(event);

    /// If my call was hung up, update the model.
    if (event is OREvent.CallHangup && _appState.activeCall == event.call) {
      _appState.activeCall = ORModel.Call.noCall;
    }
  }

  /**
   * Handle the [OREvent.ClientConnectionState] [event].
   */
  void _clientConnectionState(OREvent.ClientConnectionState event) {
    _clientConnectionStateBus.fire(new Model.ClientConnectionState.fromMap(event.conn.asMap));
  }

  /**
   * Fire [event] on relevant bus.
   */
  void _dispatch(OREvent.Event event) {
    if(event is OREvent.CallEvent) {
      _callEvent(event);
    } else if(event is OREvent.CalendarChange) {
      _calendarChange(event);
    } else if(event is OREvent.ClientConnectionState) {
      _clientConnectionState(event);
    } else if(event is OREvent.MessageChange) {
      _messageChange(event);
    } else if(event is OREvent.UserState) {
      _userState(event);
    } else {
      _log.severe('Failed to dispatch event ${event}');
    }
  }

  /**
   * Handle the [OREvent.MessageChange] [event].
   */
  void _messageChange(OREvent.MessageChange event) {
    _log.info('Ignoring event ${event}');
  }

  /**
   * Agent state change stream.
   */
  Stream<ORModel.UserStatus> get onAgentStateChange => _agentStateChangeBus.stream;

  /**
   * Call state change stream.
   */
  Stream<OREvent.CallEvent> get onAnyCallStateChange =>
      _callStateChangeBus.stream;

  /**
   * Calendar Event changes stream.
   */
  Stream<OREvent.CalendarChange> get onCalendarChange => _calendarChangeBus.stream;

  /**
   * Client connection state change stream.
   */
  Stream<Model.ClientConnectionState> get onClientConnectionStateChange =>
      _clientConnectionStateBus.stream;

  /**
   * Observers.
   */
  void _observers() {
    _socket.eventStream.listen(_dispatch, onDone: () => null);
  }

  /**
   * Handle the [OREvent.UserState] [event].
   */
  void _userState(OREvent.UserState event) {
    _agentStateChangeBus.fire(new ORModel.UserStatus.fromMap(event.asMap));
  }
}
