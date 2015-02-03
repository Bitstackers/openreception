/*                  This file is part of OpenReception
                   Copyright (C) 2012-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

/**
 * This file defines and describes the different events that can occur
 * throughout the client ecosystem.
 */

library events;

import 'package:event_bus/event_bus.dart';
import 'package:openreception_framework/model.dart' as ORModel;

import 'focus.dart';
import '../model/model.dart' as model;
import 'location.dart';
import 'state.dart';
import '../model/model.dart';
import '../classes/context.dart' as UIContext;

final EventType keyUp                                           = new EventType();
final EventType keyDown                                         = new EventType();
final EventType keyEsc                                          = new EventType();
final EventType keyEnter                                        = new EventType();
final EventType<bool> keyNav                                    = new EventType<bool>();
final EventType<bool> keyCommand                                = new EventType<bool>();
final EventType<model.Call> callCreated                         = new EventType<model.Call>();
final EventType<model.Call> callDestroyed                       = new EventType<model.Call>();
final EventType<model.Call> callChanged                         = new EventType<model.Call>();
final EventType<model.Call> callQueueAdd                        = new EventType<model.Call>();
final EventType<model.Call> callQueueRemove                     = new EventType<model.Call>();
//final EventType<MessageSearchFilter> messageSearchFilterChanged = new EventType<MessageSearchFilter>();
final EventType<Focus> focusChanged                             = new EventType<Focus>();
final EventType<model.Call> localCallQueueAdd                   = new EventType<model.Call>();
final EventType<model.Call> localCallQueueRemove                = new EventType<model.Call>();
final EventType<Location> locationChanged                       = new EventType<Location>();
final EventType<UIContext.Context> contextChanged               = new EventType<UIContext.Context>();
final EventType<model.MessageFilter> messageFilterChanged       = new EventType<model.MessageFilter>();

final EventType<model.Reception>  receptionChanged              = new EventType<model.Reception>();
final EventType<model.UserStatus> userStatusChanged             = new EventType<model.UserStatus>();


final EventType selectedMessagesChanged                         = new EventType();
final EventType<State> stateUpdated                             = new EventType<State>();
final EventType CreateNewContactEvent                           = new EventType();
final EventType Save                                            = new EventType();
final EventType Send                                            = new EventType();
final EventType Edit                                            = new EventType();
final EventType Delete                                          = new EventType();

// Keyboards
final EventType<String> hangupCall                              = new EventType<String>();
final EventType<String> parkCall                                = new EventType<String>();
final EventType<int>    CallSelectedContact                     = new EventType<int>();
final EventType         TransferFirstParkedCall                 = new EventType();
final EventType         dialSelectedContact                     = new EventType();


/* Pickup */
final EventType<Call> pickupCallRequest     = new EventType<Call>();
final EventType       pickupNextCallRequest = new EventType();
final EventType<Call> pickupCallSuccess     = new EventType();
final EventType<Call> pickupCallFailure     = new EventType();

/* Hangup */
final EventType<Call> hangupCallRequest        = new EventType<Call>();
final EventType<Call> hangupCallRequestSuccess = new EventType<Call>();
final EventType<Call> hangupCallRequestFailure = new EventType<Call>();

/* Originate */
final EventType<String> originateCallRequest  = new EventType<String>();
final EventType originateCallRequestSuccess   = new EventType();
final EventType originateCallRequestFailure   = new EventType();
final EventType<String> originateCallProgress = new EventType<String>();

/* Park */
final EventType<Call> parkCallRequest        = new EventType<Call>();
final EventType<Call> parkCallRequestSuccess = new EventType<Call>();
final EventType<Call> parkCallRequestFailure = new EventType<Call>();

/* Transfer */
final EventType<Call> transferCallRequest        = new EventType<Call>();
final EventType<Call> transferCallRequestSuccess = new EventType<Call>();
final EventType<Call> transferCallRequestFailure = new EventType<Call>();


EventBus _bus = new EventBus();
EventBus get bus => _bus;