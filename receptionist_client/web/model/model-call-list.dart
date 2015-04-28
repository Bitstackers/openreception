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

part of model;

/**
 * A list of [Call] objects.
 */

class CallNotFound extends StateError {
  CallNotFound(String message): super(message);
}

class CallList extends IterableBase<Call> {

  Logger log  = new Logger('${libraryName}.CallList');

  Bus<CallList> _reload = new Bus<CallList>();
  Stream<CallList> get onReload => _reload.stream;

  Bus<Call> _insert = new Bus<Call>();
  Stream<Call> get onInsert => _insert.stream;

  Bus<Call> _remove = new Bus<Call>();
  Stream<Call> get onRemove => _remove.stream;

  /// Internal call storage.
  Map<String, Call> _map = new Map<String, Call>();

  /**
   * Iterator forward.
   */
  Iterator<Call> get iterator => this._map.values.iterator;

  /**
   *
   */
  Iterable<Call> get pendingCalls =>
      this.where ((Call call) =>
          [User.currentUser.ID, ORModel.User.nullID].contains(call.assignedTo));

  /**
   *
   */
  Iterable<Call> get ownedCalls =>
      this.where ((Call call) =>
          [User.currentUser.ID].contains(call.assignedTo));

  /**
   *
   */
  Iterable<Call> get parkedCalls =>
      this.ownedCalls.where
        ((Call call) => call.currentState == CallState.PARKED);

  /**
   * Return the first parked [Call] or [noCall] if there are no parked calls.
   */
  Call get firstParkedCall {
    try {
      return parkedCalls.first;
    } catch(_) {
      return noCall;
    }
  }

  /**
   * Default [CallList] constructor.
   */
  CallList(Service.Notification notification) {
    this._registerObservers(notification);
  }

  /**
   * Registers the internal observers.
   */
  void _registerObservers(Service.Notification notification) {
    log.finest('Registering observers.');
    notification.onAnyCallStateChange.listen((this.update));
  }

  /**
   * [CallList] Constructor.
   */
  void replaceAll(Iterable<Call> calls) {
    this._map.clear();

    calls.forEach((Call call) {
      this._map[call.ID] = call;
        /// Look for the currently active call - if any.
        this.forEach((Call call) {
          if (call.assignedTo == User.currentUser.ID &&
              call.state == CallState.SPEAKING) {

            log.info("Found an already active call.");
            Call.activeCall = call;
          }
        });
    });

    log.info('Reloaded call list with ${calls.length} elements.');
    this._reload.fire(this);
  }

  /**
   * Reloads the Call list from the server.
   */
  Future<CallList> reloadFromServer(Service.Call callService) {

    return callService.listCalls().then((Iterable<Call> calls) {
      this.replaceAll(calls);

      return this;
    });
  }

  /**
   * Updates the [Call] in the list with the values from the supplied object.
   */
  void update (ORModel.Call call) {
    log.finest('Updating call ${call}');
    try {
      if (!this._map.containsKey(call.ID)) {
        this.add(call);
      }
        this._map[call.ID].update(call);
      }

    catch (error, stacktrace) {
      log.severe('Failed to Update call ${call}');
      log.severe(error, stacktrace);
    }

    if (this._map[call.ID].currentState == CallState.HUNGUP) {
      this.remove(call);
    }

  }

  /**
   * Appends [call] to the list.
   */
  void add(Call call) {
    this._map[call.ID] = call;
    this._insert.fire(call);

    log.finest('Added ${call}');
    }

  /**
   * Return the [id] [Call] or [noCall] if [id] does not exist.
   */
  Call get(String ID) {
    try {
      return this._map[ID];
    } catch (_) {
      throw new CallNotFound('ID: ${ID}');
    }
  }

  /**
   * Removes [call] from the list.
   */
  void remove(Call call) {
    try {
      this._map.remove(call);

    } catch (_) {
      log.severe('Call ${call} not found in list - so cannot remove');
      throw new CallNotFound('ID: ${call.ID}');
    }

    /* Notify observers.*/
    this._remove.fire(call);
  }
}
