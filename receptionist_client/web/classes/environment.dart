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

import 'common.dart';
import 'context.dart';
import 'logger.dart';
import 'model.dart' as model;

@observable String activeWidget = '';

final _Call         call         = new _Call();
final _ContextList  contextList  = new _ContextList();
final _Organization organization = new _Organization();

/**
 * The currently active call.
 */
class _Call{
  model.Call _call = model.nullCall;

  model.Call get current => _call;

  /**
   * _Call constructor.
   */
  _Call();

 /**
  * Replaces this environments call with [call].
  */
  void set(model.Call call) {
    if (call != _call) {
      _call = call;
      log.info('Current Call ${call}');

      if (_call != null && _call != model.nullCall){
        log.user('Call answered ${_call.toString()}');
      }
    }
  }
}

/**
 * A list of the application contexts.
 */
class _ContextList extends IterableBase<Context>{
  List<Context>        _list = toObservable(<Context>[]);
  Map<String, Context> _map  = new Map<String, Context>();

  Iterator<Context> get iterator => _list.iterator;

  /**
   * _ContextList constructor.
   */
  _ContextList();

  /**
   * Add [context] to the [_ContextList].
   */
  void add(Context context) {
    // We store the context twice. This is for fast lookup, so we don't have to
    // loop the list to find a context based on its id.
    _list.add(context);
    _map[context.id] = context;
  }

  /**
   * Decrease alert level for the [id] [Context].
   */
  void decreaseAlert(String id) {
    if (_map.containsKey(id)) {
      _map[id].decreaseAlert();
    }
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

  /**
   * Increase alert level for the [id] [Context].
   */
  void increaseAlert(String id) {
    if (_map.containsKey(id)) {
      _map[id].increaseAlert();
    }
  }
}

/**
 * The currently active organization.
 */
@observable
class _Organization{
  model.Organization _organization = model.nullOrganization;

  model.Organization get current  => _organization;

  /**
   * Organization constructor.
   */
  _Organization();

  /**
   * Set the environment [Organization] to [organization].
   */
  void set(model.Organization organization) {
    if (organization != _organization) {
      _organization = organization;
      log.info('Current Organization ${organization}');
    }
  }
}
