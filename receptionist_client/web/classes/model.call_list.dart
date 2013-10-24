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
class CallList extends IterableBase<Call>{
  List<Call> _list = new List<Call>();

  /**
   * Iterator.
   */
  Iterator<Call> get iterator => _list.iterator;

  /**
   * Default [CallList] constructor.
   */
  CallList();

  /**
   * [CallList] constructor. Builds a list of [Call] objects from the
   * contents of json[key].
   */
  factory CallList.fromJson(Map json, String key) {
    CallList callList = new CallList();

    if (json.containsKey(key) && json[key] is List) {
      log.debug('model.CallList.fromJson key: ${key} list: ${json[key]}');
      callList = new CallList._fromList(json[key]);
    } else {
      log.critical('model.CallList.fromJson bad data key: ${key} map: ${json}');
    }

    return callList;
  }

  /**
   * [CallList] Constructor.
   */
  CallList._fromList(List<Map> list) {
    list.forEach((item) => _list.add(new Call.fromJson(item)));
    _list.sort();

    log.debug('CallList._internal populated list from ${list}');
  }

  /**
   * Appends [call] to the list.
   */
  void addCall(Call call) {
    _list.add(call);
    log.debug('model.callList added ${call}');
  }

  /**
   * Return the [id] [Call] or [nullCall] if [id] does not exist.
   */
  Call getCall(int id) {
    for(Call call in _list) {
      if(id == call.id) {
        return call;
      }
    }

    return nullCall;
  }

  /**
   * Removes [call] from the list.
   */
  void removeCall(Call call) {
    for (Call c in _list) {
      if (c.id == call.id) {
        _list.remove(c);
        log.debug('model.callList removeCall Removed call: ${c}');
        break;
      }
    }
  }
}
