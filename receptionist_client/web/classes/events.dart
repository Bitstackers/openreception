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

import 'context.dart';
import 'focus.dart';
import 'model.dart' as model;
import 'state.dart';

final EventType<Context> activeContextChanged           = new EventType<Context>();
final EventType<String> activeWidgetChanged             = new EventType<String>();
final EventType<model.Call> callChanged                 = new EventType<model.Call>();
final EventType<model.Call> callQueueAdd                = new EventType<model.Call>();
final EventType<model.Call> callQueueRemove             = new EventType<model.Call>();
final EventType<model.Contact> contactChanged           = new EventType<model.Contact>();
final EventType<Focus> focusChanged                     = new EventType<Focus>();
final EventType<model.Call> localCallQueueAdd           = new EventType<model.Call>();
final EventType<model.Organization> organizationChanged = new EventType<model.Organization>();
final EventType<State> stateUpdated                     = new EventType<State>();

EventBus _bus = new EventBus();
EventBus get bus => _bus;