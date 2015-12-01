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

part of view;

/**
 * Show the my call queue and registers keyboard shortcuts for call handling.
 *
 * This reloads the call queue list at a fixed refresh rate of [_refreshRate].
 */
class MyCallQueue extends ViewWidget {
  final Model.AppClientState _appState;
  final Controller.Call _callController;
  final Model.UIContactData _contactData;
  final Model.UIContactSelector _contactSelector;
  bool _callControllerBusy = false;
  final Map<String, String> _langMap;
  final Logger _log = new Logger('$libraryName.MyCallQueue');
  final Controller.Destination _myDestination;
  final Controller.Notification _notification;
  final Controller.Popup _popup;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIMyCallQueue _uiModel;

  /**
   * Constructor.
   */
  MyCallQueue(
      Model.UIMyCallQueue this._uiModel,
      Model.AppClientState this._appState,
      Controller.Destination this._myDestination,
      Controller.Notification this._notification,
      Controller.Call this._callController,
      Controller.Popup this._popup,
      Map<String, String> this._langMap,
      Model.UIContactData this._contactData,
      Model.UIContactSelector this._contactSelector,
      Model.UIReceptionSelector this._receptionSelector) {
    _loadCallList();

    _observers();
  }

  @override Controller.Destination get _destination => _myDestination;
  @override Model.UIMyCallQueue get _ui => _uiModel;

  @override void _onBlur(_) {}
  @override void _onFocus(_) {}

  /**
   * Simply navigate to my [Destination]. Matters not if this widget is already
   * focused.
   */
  void _activateMe(_) {
    _navigateToMyDestination();
  }

  /**
   * Add, remove, update the queue list, depending on the [call] state.
   */
  void _handleCallStateChanges(OREvent.CallEvent event) {
    if (event.call.assignedTo != _appState.currentUser.ID) {
      return;
    }

    switch (event.call.state) {
      case ORModel.CallState.Created:
        if (!event.call.inbound) {
          /// My outbound call.
          _ui.appendCall(event.call);
        }
        break;

      case ORModel.CallState.Hungup:
      case ORModel.CallState.Transferred:
        _ui.removeCall(event.call);
        break;

      default:
        _ui.updateCall(event.call);
        break;
    }
  }

  /**
   * Tries to dial the [phoneNumber].
   *
   * If this is called while [_appState.activeCall] is not [ORModel.Call.noCall], then mark both
   * calls ready for transfer.
   */
  Future _call(ORModel.PhoneNumber phoneNumber) async {
    ORModel.Call parkedCall;
    bool markTransfer =
        _appState.activeCall == ORModel.Call.noCall && _ui.markedForTransfer.length == 1;
    bool parkAndMarkTransfer =
        _appState.activeCall != ORModel.Call.noCall && _ui.markedForTransfer.length < 2;

    if (parkAndMarkTransfer) {
      _ui.removeTransferMarks();
      parkedCall = await park(_appState.activeCall);
      _ui.markForTransfer(parkedCall);
      _log.info('marked ${parkedCall.ID} for transfer');
    }

    _busyCallController();
    try {
      ORModel.Call newCall = await _callController.dial(
          phoneNumber, _receptionSelector.selectedReception, _contactSelector.selectedContact);
      if (markTransfer || parkAndMarkTransfer) {
        _ui.markForTransfer(newCall);
        _log.info('marked ${newCall.ID} for transfer');
      }
    } catch (error) {
      _error(error, _langMap[Key.callFailed], phoneNumber.value);
      _log.warning('dialing failed with ${error}');
    }

    _contactData.removeRinging();

    await _readyCallController();
  }

  /**
   * Mark the call controller busy. This is just a simply protection against hammering the call
   * controller with too many commands.
   */
  void _busyCallController() {
    _callControllerBusy = true;
  }

  /**
   *  Mark the call controller ready. This operation is delayed 100ms, to prevent against agents
   *  spamming commands at the call controller.
   */
  Future _readyCallController() {
    return new Future.delayed(new Duration(milliseconds: 100), () => _callControllerBusy = false);
  }

  /**
   * Popup with errors.
   */
  void _error(Exception error, String title, String message) {
    if (error is Controller.BusyException) {
      _popup.error(_langMap[Key.errorSystem], _langMap[Key.errorCallControllerBusy]);
    } else {
      _popup.error(title, message);
    }
  }

  /**
   * Park [call].
   */
  Future<ORModel.Call> park(ORModel.Call call) async {
    ORModel.Call parkedCall = ORModel.Call.noCall;

    if (!_callControllerBusy && call != ORModel.Call.noCall) {
      try {
        _busyCallController();
        parkedCall = await _callController.park(call);
      } catch (error) {
        _error(error, _langMap[Key.errorCallPark], 'ID ${_appState.activeCall.ID}');
        _log.warning('parking failed with ${error}');
      }
    }

    await _readyCallController();

    return parkedCall;
  }

  /**
   * Load the list of calls assigned to current user and not being transferred.
   */
  void _loadCallList() {
    bool isMine(ORModel.Call call) =>
        call.assignedTo == _appState.currentUser.ID && call.state != ORModel.CallState.Transferred;

    _callController.listCalls().then((Iterable<ORModel.Call> calls) {
      _ui.calls = calls.where(isMine).toList(growable: false);
    });
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_setWidgetState);

    _ui.onClick.listen(_activateMe);

    _ui.onDblClick.listen((ORModel.Call call) => unpark(call: call));

    /// Transfer
    _hotKeys.onCtrlNumMinus.listen((_) {
      final Iterable<ORModel.Call> calls = _ui.markedForTransfer;
      if (!_callControllerBusy &&
          _appState.activeCall != ORModel.Call.noCall &&
          calls.length == 2) {
        final ORModel.Call source =
            calls.firstWhere((ORModel.Call call) => call.ID == _appState.activeCall.ID);
        final ORModel.Call destination =
            calls.firstWhere((ORModel.Call call) => call.ID != _appState.activeCall.ID);
        _callControllerBusy = true;
        _callController.transfer(source, destination).catchError((error) {
          _error(error, _langMap[Key.errorCallTransfer], 'ID ${_appState.activeCall.ID}');
          _log.warning('transfer failed with ${error}');
        }).whenComplete(() => _readyCallController());
      }
    });

    /// Park
    _hotKeys.onF7.listen((_) => park(_appState.activeCall));

    /// Unpark
    _hotKeys.onF8.listen((_) => unpark());

    /// Hangup
    _hotKeys.onNumDiv.listen((_) {
      if (!_callControllerBusy && _appState.activeCall != ORModel.Call.noCall) {
        _callControllerBusy = true;
        _callController.hangup(_appState.activeCall).catchError((error) {
          _error(error, _langMap[Key.errorCallHangup], 'ID ${_appState.activeCall.ID}');
          _log.warning('hangup failed with ${error}');
        }).whenComplete(() => _readyCallController());
      }
    });

    /// Pickup new call
    _hotKeys.onNumPlus.listen((_) {
      if (!_callControllerBusy) {
        _callControllerBusy = true;
        _callController.pickupNext().then((ORModel.Call call) {
          _ui.removeTransferMarks();
        }).catchError((error) {
          _error(error, _langMap[Key.errorCallNotFound], _langMap[Key.errorCallNotFoundExtended]);
          _log.warning('pickup failed with ${error}');
        }).whenComplete(() => _readyCallController());
      }
    });

    /// Make call
    _hotKeys.onNumMult.listen(_setRinging);
    _contactData.onMarkedRinging.listen(_call);

    _notification.onAnyCallStateChange.listen(_handleCallStateChanges);
  }

  /**
   * If no phonenumber is marked ringing, mark the currently selected phone number ringing.
   */
  void _setRinging(_) {
    _contactData.ring();
  }

  /**
   * Unpark the first parked call or the given [call].
   */
  void unpark({ORModel.Call call}) {
    if (!_callControllerBusy &&
        _appState.activeCall == ORModel.Call.noCall &&
        _ui.calls.any((ORModel.Call call) => call.state == ORModel.CallState.Parked)) {
      _callControllerBusy = true;
      final Future<ORModel.Call> unparkCall =
          call != null ? _callController.pickup(call) : _callController.pickupFirstParkedCall();

      unparkCall.then((ORModel.Call call) {
        _ui.removeTransferMark(call);
      }).catchError((error) {
        _error(error, _langMap[Key.errorCallUnpark], '');
        _log.warning('unpark failed with ${error}');
      }).whenComplete(() => _readyCallController());
    }
  }
}
