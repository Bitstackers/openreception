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

@observable String                 activeWidget     = '';
@observable int                    bobReady         = 0;
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
  List<Context>        _list = toObservable(new List<Context>());
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
