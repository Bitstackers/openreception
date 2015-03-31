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

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:html';


import '../controller/controller.dart' as Controller;
import '../classes/events.dart' as event;
import '../classes/logger.dart';
import '../classes/service-notification.dart' as Service;
import '../service/service.dart' as Service;
import '../storage/storage.dart' as storage;
import 'package:event_bus/event_bus.dart';
import 'package:openreception_framework/bus.dart';
import 'package:openreception_framework/model.dart' as ORModel;

part 'model-call.dart';
part 'model-call-list.dart';
part 'model-contact.dart';
part 'model-contact-calendar.dart';
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
part 'model-reception.dart';
part 'model-reception-calendar.dart';
part 'model-recipient.dart';
part 'model-transfer-request.dart';
part 'model-user.dart';
part 'model-user-status.dart';

part 'model-ui-agent-info.dart';
part 'model-ui-calendar-editor.dart';
part 'model-ui-contact-calendar.dart';
part 'model-ui-contact-data.dart';
part 'model-ui-contact-list.dart';
part 'model-ui-contexts.dart';
part 'model-ui-message-compose.dart';
part 'model-ui-reception-calendar.dart';
part 'model-ui-reception-commands.dart';



abstract class DomModel {
  /**
   * SHOULD return the root element for this specific DomModel. MAY return null
   * if the root doesn't matter.
   */
  HtmlElement get root => null;
}

abstract class UIModel {
  HtmlElement get firstTabElement;
  HtmlElement get focusElement;
  HtmlElement get lastTabElement;
  HtmlElement get root;

  set firstTabElement(HtmlElement element);
  set focusElement   (HtmlElement element);
  set lastTabElement (HtmlElement element);
}

enum AgentState {BUSY, IDLE, PAUSE, UNKNOWN}
enum AlertState {OFF, ON}

const String libraryName = "model";
