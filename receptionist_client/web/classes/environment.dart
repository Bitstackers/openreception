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

library environment;

import 'dart:async';
import 'dart:collection';

import 'package:web_ui/web_ui.dart';

import 'context.dart';
import 'logger.dart';
import 'model.dart' as model;
import 'state.dart';

@observable String                 activeWidget     = '';
@observable model.Call             call             = model.nullCall;
@observable model.CallList         callQueue        = new model.CallList();
@observable model.CallList         localCallQueue   = new model.CallList();
@observable model.Contact          contact          = model.nullContact;
@observable model.Organization     organization     = model.nullOrganization;
@observable model.OrganizationList organizationList = new model.OrganizationList();

final _ContextList  contextList  = new _ContextList();

/**
 * A list of the application contexts.
 */
class _ContextList extends IterableBase<Context> {
  LinkedHashMap<String, Context> _map  = new LinkedHashMap<String, Context>();

  Iterator<Context> get iterator => new MapIterator<String, Context>(_map);

  /**
   * _ContextList constructor.
   */
  _ContextList() {
     state.stream.listen((int status){
       if (status == State.ERROR){
         _map = new LinkedHashMap<String, Context>();
       }
     });
  }

  /**
   * Add [context] to the [_ContextList].
   */
  void add(Context context) {
    _map[context.id] = context;

    log.debug('environment._ContextList.add ${context.id}');
  }

  /**
   * Return the [id] [Context].
   */
  Context get(String id) {
    if(_map.containsKey(id)) {
      return _map[id];
    }

    return null;
  }
}

/**
 * Iterator for [Map].
 */
class MapIterator<T_Key, T_Value> extends Iterator<T_Value> {
  Iterator<T_Key> keys;
  Map<T_Key, T_Value> map;

  MapIterator(this.map) {
    keys = map.keys.iterator;
  }

  /**
   * Returns the current element.
   * Return null if the iterator has not yet been moved to the first element, or if the iterator has been moved after the last element of the Iterable.
   */
  T_Value get current {
    if (keys.current != null) {
      return map[keys.current];
    }
    return null;
  }

  /**
   * Moves to the next element. Returns true if current contains the next element. Returns false, if no element was left.
   * It is safe to invoke moveNext even when the iterator is already positioned after the last element. In this case moveNext has no effect.
   */
  bool moveNext() {
    return keys.moveNext();
  }
}
