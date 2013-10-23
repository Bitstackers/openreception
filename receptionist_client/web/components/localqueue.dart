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

import 'package:polymer/polymer.dart';

import '../classes/common.dart';
import '../classes/configuration.dart';
import '../classes/events.dart' as event;
import '../classes/logger.dart';
import '../classes/model.dart' as model;
import '../classes/protocol.dart' as protocol;

@CustomTag('local-queue')
class LocalQueue extends PolymerElement with ApplyAuthorStyle {
  @observable model.CallList localCallQueue = new model.CallList();
              String         title          = 'Lokal kø';

  LocalQueue.created() : super.created() {
    registerEventListerns();
    _initialFill();
  }

  void registerEventListerns() {
    event.bus.on(event.localCallQueueAdd)
      .listen((model.Call call) => localCallQueue.addCall(call));

    event.bus.on(event.callQueueRemove)
      .listen((model.Call call) => localCallQueue.removeCall(call));
  }

  void _initialFill() {
    protocol.callLocalList(configuration.agentID).then((protocol.Response response) {
      switch(response.status) {
        case protocol.Response.OK:
          localCallQueue = response.data;

          log.debug('LocalQueue._initialFill updated environment.localCallQueue');
          break;

        default:
          localCallQueue = new model.CallList();
          log.debug('LocalQueue._initialFill updated environment.localCallQueue with empty list');
      }
    }).catchError((error) {
      localCallQueue = new model.CallList();
      log.critical('LocalQueue._initialFill protocol.callLocalList failed with ${error}');
    });
  }
}
