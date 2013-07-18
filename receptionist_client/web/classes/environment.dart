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
import 'state.dart';

@observable String                 activeWidget     = '';
@observable model.Call             call             = model.nullCall;
@observable model.CallList         callQueue        = new model.CallList();
@observable model.CallList         localCallQueue   = new model.CallList();
@observable model.Contact          contact          = model.nullContact;
@observable model.Organization     organization     = model.nullOrganization;
@observable model.OrganizationList organizationList = new model.OrganizationList();

final _ContextList contextList  = new _ContextList();

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
    stateUpdates.listen((BobState state) {
       if (state.isError){
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
