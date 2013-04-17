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

library call_handler;

import 'configuration.dart';
import 'environment.dart' as environment;
import 'logger.dart';
import 'model.dart' as model;
import 'notification.dart' as notify;

void initializeCallHandler() {
  notify.notification.addEventHandler('call_pickup', _callPickupEventHandler);
  notify.notification.addEventHandler('call_hangup', _callHangupEventHandler);
}

void _callPickupEventHandler(Map json) {
  var call = new model.Call(json['call']);
  //TODO it should not be nessesary to int.parse here.
  if (int.parse(call.content['assigned_to']) == configuration.agentID) {
    //it's to me! :D :D
    log.info('Call pickup for this agent.');
    environment.call.set(call);
  }else{
    //somebody else got a call. :(
    log.debug('Somebody else got a call.');
  }
}

void _callHangupEventHandler(Map json) {
  var call = json['call'];
  //TODO We don't need no Int.parse here. Well.. Server sends it as string.
  if (environment.call != null && int.parse(call['id']) == environment.call.current.id) {
    log.info('The current call hangup');
    environment.call.set(model.nullCall);
  }
}