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

library model;

import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'dart:math' hide log;

import 'package:intl/intl.dart';

import 'environment.dart' as environment;
import 'events.dart' as event;
import 'logger.dart';
import 'protocol.dart' as protocol;
import 'storage.dart' as storage;
import 'configuration.dart' as config;
import '../constants.dart' as constant;

part 'model.call.dart';
part 'model.call_list.dart';
part 'model.calendar_event.dart';
part 'model.calendar_event_list.dart';
part 'model.contact.dart';
part 'model.contact_list.dart';
part 'model-message.dart';
part 'model.minibox_list_item.dart';
part 'model.minibox_list.dart';
part 'model-phone_number.dart';
part 'model-recipient.dart';
part 'model-user.dart';
part 'model.reception.dart';
part 'model.reception_list.dart';

final String packageName = "model"; 
