/*                                Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This library is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License and
  a copy of the GCC Runtime Library Exception along with this program;
  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
  <http://www.gnu.org/licenses/>.
*/

/**
 * Contains the current state of Bob.
 */
library environment;

import 'dart:async';
import 'dart:collection';

import 'package:web_ui/web_ui.dart';

import 'common.dart';
import 'context.dart';
import 'logger.dart';
import 'model.dart' as model;

/**
 * Environment singletons.
 */
final _Call call = new _Call();
final _ContextList contextList = new _ContextList();
final _Organization organization = new _Organization();

/**
 * TODO comment
 */
class _Call{
  StreamController _stream = new StreamController<model.Call>();
  Stream<model.Call> _onChange;

  model.Call _call = model.nullCall;
  model.Call get current => _call;

  /**
   * Subscribe to call changes.
   */
  Stream<model.Call> get onChange => _onChange;

  _Call(){
    _onChange = _stream.stream.asBroadcastStream();
  }

 /**
  * Replaces this environments call with [call].
  */
  void set(model.Call call) {
    if (call == _call) {
      return;
    }
    _call = call;
    log.info('The current call is changed to: ${call.toString()}');
    //dispatch the new call.
    if (_call != null && _call != model.nullCall){
      log.user('Du fik opkaldet: ${_call.toString()}');
    }
    _stream.sink.add(call);
  }
}

/**
 * The application contexts. Contexts can be added and the list can be iterated,
 * but contexts cannot be removed or the list cleared.
 */
class _ContextList extends IterableBase<Context>{
  List<Context> list = toObservable(new List<Context>());

  _ContextList();

  void add(Context context) {
    list.add(context);
  }

  void decreaseAlert(String contextId) {
    list.forEach((context) {
      if (contextId == context.id) { // ???? Master Joda. 2 == context.id
        context.decreaseAlert();
      }
    });
  }

  void increaseAlert(String contextId) {
    list.forEach((context) {
      if (contextId == context.id) {
        context.increaseAlert();
      }
    });
  }

  Iterator<Context> get iterator => new GenericListIterator<Context>(list);
}

/**
 * TODO comment
 */
class _Organization{
  StreamController _stream = new StreamController<model.Organization>();
  Stream<model.Organization> _onChange;

  Stream<model.Organization> get onChange => _onChange;

  model.Organization _organization = model.nullOrganization;
  model.Organization get current => _organization;

  _Organization(){
    _onChange = _stream.stream.asBroadcastStream();
  }

  /**
   * Replaces this environments organization with [organization].
   */
  void set(model.Organization organization) {
    if (organization == _organization) {
      return;
    }

    _organization = organization;
    log.info('Environment organization is changed to: ${organization.toString()}');
    //dispatch the new organization.
    _stream.sink.add(organization);
  }
}
