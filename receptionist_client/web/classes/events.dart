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

library events;

import 'package:event_bus/event_bus.dart';

import '../components.dart';
import 'focus.dart';
import 'model.dart' as model;
import 'location.dart';
import 'state.dart';

final EventType keyUp                                           = new EventType();
final EventType keyDown                                         = new EventType();
final EventType keyEsc                                          = new EventType();
final EventType keyEnter                                        = new EventType();
final EventType<model.Call> callChanged                         = new EventType<model.Call>();
final EventType<model.Call> callQueueAdd                        = new EventType<model.Call>();
final EventType<model.Call> callQueueRemove                     = new EventType<model.Call>();
final EventType<model.Contact> contactChanged                   = new EventType<model.Contact>();
final EventType<MessageSearchFilter> messageSearchFilterChanged = new EventType<MessageSearchFilter>();
final EventType<Focus> focusChanged                             = new EventType<Focus>();
final EventType<model.Call> localCallQueueAdd                   = new EventType<model.Call>();
final EventType<model.Call> localCallQueueRemove                = new EventType<model.Call>();
final EventType<Location> locationChanged                       = new EventType<Location>();
final EventType<model.Reception> receptionChanged               = new EventType<model.Reception>();
final EventType<State> stateUpdated                             = new EventType<State>();

// Keyboards
final EventType<String> pickupNextCall                          = new EventType<String>();
final EventType<String> hangupCall                              = new EventType<String>();
final EventType<String> parkCall                                = new EventType<String>();
final EventType<String> CallSelectedContact                     = new EventType<String>();

EventBus _bus = new EventBus();
EventBus get bus => _bus;