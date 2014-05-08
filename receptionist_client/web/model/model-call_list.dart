/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

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

  static const String className = "${libraryName}.CallList";

  static final EventType reload = new EventType();
  static final EventType<Call> insert = new EventType<Call>();
  static final EventType<Call> delete = new EventType<Call>();

  EventBus _bus = new EventBus();
  EventBus get events => _bus;

  EventBus _eventStream = event.bus;

  /* Singleton instance - for quick and easy reference. */
  static CallList _instance = new CallList();
  static CallList get instance => _instance;
  static set instance(CallList newList) => _instance = newList;

  List<Call> _list = new List<Call>();

  /**
   * Iterator.
   */
  Iterator<Call> get iterator => _list.iterator;

  List<Call> get queuedCalls {
    List<Call> queuedCalls = new List<Call>();
    this._list.forEach((Call call) {
      //TODO: Only add non-parked calls.
      if ([User.currentUser.ID, User.nullUserID].contains(call.assignedAgent)) {
        queuedCalls.add(call);
      }
    });

    return queuedCalls;
  }

  /**
   * Default [CallList] constructor.
   */
  CallList() {
    this._registerObservers();
  }

  /**
   * [CallList] constructor. Builds a list of [Call] objects from the
   * contents of json[key].
   */
  factory CallList.fromJson(Map json, String key) {
    const String context = '${className}.CallList.fromJson';

    CallList callList = new CallList();

    if (json.containsKey(key) && json[key] is List) {
      log.debug('model.CallList.fromJson key: ${key} list: ${json[key]}');
      callList = new CallList._fromList(json[key]);
    } else {
      log.criticalContext('model.CallList.fromJson bad data key: ${key} map: ${json}', context);
    }

    return callList;
  }

  void _registerObservers() {
    this._eventStream.on(event.callCreated).listen(this.add);
    //this._eventStream.on(event.callQueueAdd).listen((Call call) {this.get(call.ID).changeState(CallState.QUEUED);});
    this._eventStream.on(event.callQueueRemove).listen(this.add);
    this._eventStream.on(event.callDestroyed).listen(this.remove);
  }

  /**
   * [CallList] Constructor.
   */
  CallList._fromList(List<Map> list) {
    const String context = '${className}.CallList._fromList';

    this._list.clear();

    list.forEach((item) => _list.add(new Call.fromJson(item)));
    _list.sort();

    log.debugContext('Populated list with ${list.length} elements.', context);
  }
  
  /**
   * Reloads the Call list from the server.
   */
  Future<CallList> reloadFromServer() {
    return Service.Call.list().then((CallList callList) {
      this._list = callList._list;

      /* Notify observers.*/
      this._bus.fire(CallList.reload, null);
      
      return this;
    });
  }
  
  /**
   * Appends [call] to the list.
   */
  void add(Call call) {
    const String context = '${className}.add';

    this._list.add(call);

    /* Notify observers.*/
    this._bus.fire(CallList.insert, call);

    log.debugContext('Added ${call}', context);
  }

  /**
   * Return the [id] [Call] or [nullCall] if [id] does not exist.
   */
  Call get(String ID) {

    this._list.forEach((Call call) {
      if (call.ID == ID) {
        return call;
      }
    });
    
    throw new CallNotFound('ID: ${ID}');
  }

  /**
   * Removes [call] from the list.
   */
  void remove(Call call) {
    const String context = '${className}.remove';

    if (this._list.contains(call)) {
      this._list.remove(call);
      log.debugContext('Removed call with ID: ${call.ID}', context);
    } else {
      log.errorContext('Call ${call.ID} not found in list', context);
    }
    /* Notify observers.*/
    this._bus.fire(CallList.delete, call);
  }
}
