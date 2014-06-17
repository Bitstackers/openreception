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

  static final EventType<CallList> reload = new EventType<CallList>();
  static final EventType<Call> insert = new EventType<Call>();
  static final EventType<Call> delete = new EventType<Call>();

  /// Local event stream.
  EventBus _eventStream = new EventBus();
  EventBus get events => _eventStream;
 
  /// Singleton instance - for quick and easy reference.
  static CallList _instance = new CallList();
  static CallList get instance => _instance;
  static set instance(CallList newList) => _instance = newList;

  /// A set would have been a better fit here, but it makes the code read terrible.
  Map<String, Call> _map = new Map<String, Call>();

  /**
   * Iterator.
   */
  Iterator<Call> get iterator => this._map.values.iterator;

  List<Call> get queuedCalls {
    List<Call> queuedCalls = new List<Call>();
    this.forEach((Call call) {
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

  /**
   * Registers the internal observers.
   */
  void _registerObservers() {
    event.bus.on(Service.EventSocket.callPickup).listen((Map map) {this.update(new Call.fromMap(map['call']));});
    event.bus.on(Service.EventSocket.callPark).listen((Map map) {this.update(new Call.fromMap(map['call']));});
    event.bus.on(Service.EventSocket.callHangup).listen((Map map) {this.update(new Call.fromMap(map['call']));});
    event.bus.on(Service.EventSocket.callState).listen((Map map) {this.update(new Call.fromMap(map['call']));});
    event.bus.on(Service.EventSocket.callLock).listen((Map map) {this.update(new Call.fromMap(map['call']));});
    event.bus.on(Service.EventSocket.callUnlock).listen((Map map) {this.update(new Call.fromMap(map['call']));});
    event.bus.on(event.callCreated).listen(this.add);
    event.bus.on(event.callDestroyed).listen(this.remove);
  }

  /**
   * [CallList] Constructor.
   */
  CallList._fromList(List<Map> list) {
    const String context = '${className}.CallList._fromList';

    this._map.clear();
    
    list.forEach((item){
      Call newCall = new Call.fromMap(item);
      
      if (newCall.isCall) {
      _map[newCall.ID] = newCall;
      }
    });

    log.debugContext('Populated list with ${list.length} elements.', context);
  }
  
  /**
   * Reloads the Call list from the server.
   */
  Future<CallList> reloadFromServer() {
    
    const String context = '${className}.reloadFromServer';
    
    return Service.Call.list().then((CallList callList) {
      this._map = callList._map;

      /* Notify observers.*/
      this._eventStream.fire(CallList.reload, this);

      /// Look for the currently active call - if any.
      this.forEach((Call call) {
        if (call.assignedAgent != User.nullUserID && 
            call.assignedAgent == User.currentUser.ID &&
            call.state == CallState.SPEAKING) {
            
          log.debugContext("Found an already active call.", context);
          Call.currentCall = call;
          
          Reception.get(call.receptionId).then((Reception reception) {
            Reception.selectedReception = reception;
          });
        }
      });
      
      return this;
    });
  }
  
  /**
   * Updates the [Call] in the list with the values from the supplied object. 
   */
  void update (Call call) {
    const String context = '${className}.update';
    log.debugContext('Updating call ${call.ID}', context);
    try {
      if (!this._map.containsKey(call.ID)) {
        this._map[call.ID] = call;
      } else {
        this._map[call.ID].update(call);
      }
    }
    catch (error, stacktrace) {
      log.errorContext('Failed to Update call ${call}, stacktrace ${stacktrace}', context); 
    }
  }
  
  /**
   * Appends [call] to the list.
   */
  void add(Call call) {
    const String context = '${className}.add';

    if (!this._map.containsKey(call.ID)) {
      this._map[call.ID] = call;

      /* Notify observers.*/
      this._eventStream.fire(CallList.insert, call);

      log.debugContext('Added ${call}', context);
    }
  }

  /**
   * Return the [id] [Call] or [nullCall] if [id] does not exist.
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
    const String context = '${className}.remove';

    try {
      this._map.remove(call);

    } catch (_) {
      log.errorContext('Call ${call.ID} not found in list', context);
      throw new CallNotFound('ID: ${call.ID}');
    }

    /* Notify observers.*/
    this._eventStream.fire(CallList.delete, call);
  
  }
}
