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
  Bus<model.UserStatus> _agentStateChangeBus = new Bus<model.UserStatus>();
  Bus<event.CalendarChange> _calendarChangeBus =
      new Bus<event.CalendarChange>();
  Bus<event.CallEvent> _callStateChangeBus = new Bus<event.CallEvent>();
  Bus<ui_model.ClientConnectionState> _clientConnectionStateBus =
      new Bus<ui_model.ClientConnectionState>();
  final Logger _log = new Logger('$libraryName.Notification');
  Bus<event.PeerState> _peerStateChangeBus = new Bus<event.PeerState>();
  Bus<event.ReceptionChange> _receptionChangeBus =
      new Bus<event.ReceptionChange>();
  Bus<event.ContactChange> _contactChangeBus =
      new Bus<event.ContactChange>();
  Bus<event.ReceptionData> _receptionDataChangeBus =
      new Bus<event.ReceptionData>();

  final service.NotificationService _service;
  final service.NotificationSocket _socket;

  /**
   * Constructor.
   */
  Notification(service.NotificationSocket this._socket,
      service.NotificationService this._service) {
    _observers();
  }

  /**
   *
   */
  Future<Iterable<model.ClientConnection>> clientConnections() =>
      _service.clientConnections();

  /**
   * Handle the [OREvent.CalendarChange] [event].
   */
  void _calendarChange(event.CalendarChange event) {
    _calendarChangeBus.fire(event);
  }

  /**
   * Handle the [OREvent.CallEvent] [event].
   */
  void _callEvent(event.CallEvent event) {
    _callStateChangeBus.fire(event);
  }

  /**
   * Handle the [OREvent.ClientConnectionState] [event].
   */
  void _clientConnectionState(event.ClientConnectionState event) {
    _clientConnectionStateBus
        .fire(new ui_model.ClientConnectionState.fromMap(event.conn.toJson()));
  }

  /**
   * Fire [event] on relevant bus.
   */
  void _dispatch(event.Event event) {
    _log.finest(event.toJson());

    if (event is event.CallEvent) {
      _callEvent(event);
    } else if (event is event.CalendarChange) {
      _calendarChange(event);
    } else if (event is event.ClientConnectionState) {
      _clientConnectionState(event);
    } else if (event is event.MessageChange) {
      _messageChange(event);
    } else if (event is event.UserState) {
      _userState(event);
    } else if (event is event.PeerState) {
      _peerStateChangeBus.fire(event);
    } else if (event is event.ReceptionChange) {
      _receptionChangeBus.fire(event);
    } else if (event is event.ReceptionData) {
      _receptionDataChangeBus.fire(event);
    } else if (event is event.ContactChange) {
      _contactChangeBus.fire(event);
    } else {
      _log.severe('Failed to dispatch event ${event}');
    }
  }

  /**
   * Handle the [OREvent.MessageChange] [event].
   */
  void _messageChange(event.MessageChange event) {
    _log.info('Ignoring event ${event}');
  }

  /**
   * Agent state change stream.
   */
  Stream<model.UserStatus> get onAgentStateChange =>
      _agentStateChangeBus.stream;

  /**
   * Call state change stream.
   */
  Stream<event.CallEvent> get onAnyCallStateChange =>
      _callStateChangeBus.stream;

  /**
   * Calendar Event changes stream.
   */
  Stream<event.CalendarChange> get onCalendarChange =>
      _calendarChangeBus.stream;

  /**
   * Client connection state change stream.
   */
  Stream<ui_model.ClientConnectionState> get onClientConnectionStateChange =>
      _clientConnectionStateBus.stream;

  /**
   * Agent state change stream.
   */
  Stream<event.PeerState> get onPeerStateChange => _peerStateChangeBus.stream;

  /**
   * Reception change stream.
   */
  Stream<event.ReceptionChange> get onReceptionChange =>
      _receptionChangeBus.stream;

  /**
   * Contact change stream.
   */
  Stream<event.ContactChange> get onContactChange => _contactChangeBus.stream;

  /**
   * ReceptionData change stream.
   */
  Stream<event.ReceptionData> get onReceptionDataChange =>
      _receptionDataChangeBus.stream;

  /**
   * Observers.
   */
  void _observers() {
    _socket.onEvent.listen(_dispatch, onDone: () => null);
  }

  /**
   * Handle the [OREvent.UserState] [event].
   */
  void _userState(event.UserState event) {
    _agentStateChangeBus.fire(new model.UserStatus.fromMap(event.toJson()));
  }

  /**
   *
   */
  Future notifySystem(event.Event e) => _service.send([0], e);
}
