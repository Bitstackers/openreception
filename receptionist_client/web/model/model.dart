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

library model;

import 'package:event_bus/event_bus.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'dart:math' hide log;

import 'package:intl/intl.dart';

import '../classes/service-notification.dart' as Service;
import '../classes/events.dart' as event;
import '../classes/logger.dart';
import '../storage/storage.dart' as storage;
import '../service/service.dart' as Service;
import '../controller/controller.dart' as Controller;
import 'package:openreception_framework/model.dart' as ORModel;

part 'model-call.dart';
part 'model-call-list.dart';
part 'model-calendar-event.dart';
part 'model-contact.dart';
part 'model-contact-list.dart';
part 'model-extension.dart';
part 'model-message.dart';
part 'model-message-filter.dart';
part 'model-message-list.dart';
part 'model-notification.dart';
part 'model-notification-list.dart';
part 'model-origination-request.dart';
part 'model-peer.dart';
part 'model-peer-list.dart';
part 'model-phone-number.dart';
part 'model-recipient.dart';
part 'model-user.dart';
part 'model-user-status.dart';
part 'model-reception.dart';
part 'model-transfer-request.dart';

const String libraryName = "model";
