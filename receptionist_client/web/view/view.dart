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

library view;

import 'dart:async';
import 'dart:html';

import 'package:event_bus/event_bus.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'package:openreception_framework/model.dart' as ORModel;

import '../classes/events.dart' as event;
import '../model/model.dart' as model;
import '../classes/constants.dart';
import '../service/service.dart' as Service;
import '../storage/storage.dart' as Storage;
import '../classes/location.dart' as nav;
import '../controller/controller.dart' as Controller;
import '../classes/logger.dart';

import '../config/configuration.dart';
import '../classes/context.dart';
import '../classes/common.dart';
import '../classes/focus.dart';
import '../classes/commands-keyboard.dart';
import '../storage/storage.dart' as storage;

import 'view-labels-en.dart';

part 'view-call.dart';
part 'view-icons.dart';
part 'view-call-list.dart';
part 'view-call-management.dart';
part 'view-reception-selector.dart';
part 'view-context-switcher.dart';
part 'view-log-box.dart';
part 'view-message-list.dart';
part 'view-message-edit.dart';
part 'view-notification.dart';
part 'view-nudge.dart';
part 'view-reception-calendar.dart';
part 'view-message-compose.dart';

part 'view-agent-info.dart';
part '../components/boxwithheader.dart';
part 'view-reception-addresses.dart';
part 'view-reception-alternate-names.dart';
part 'view-reception-banking-information.dart';
part 'view-reception-customer-type.dart';
part 'view-reception-email-addresses.dart';
part 'view-reception-extra-information.dart';
part 'view-reception-handling.dart';
part 'view-reception-opening-hours.dart';
part 'view-reception-product.dart';
part 'view-reception-registration-number.dart';
part 'view-reception-sales-calls.dart';
part 'view-reception-telephone-numbers.dart';
part 'view-reception-websites.dart';
part 'view-welcome-message.dart';
part 'view-contact.dart';
part 'view-contact-search.dart';
part 'view-contact-calendar.dart';
part 'view-contact-data.dart';
part '../components/constants.dart';
part 'view-message-filter.dart';
part '../components/searchcomponent.dart';

const String libraryName = "view";

abstract class StyleClass {
  static const String NUDGE = 'nudge';

  static String selector(String styleClass) {
    return '.$styleClass';
  }
}

const String defaultElementId = 'data-default-element';

typedef void onCallQueueClick(MouseEvent event, Call queueItem);

bool handleFocusChange(Focus value, List<Element> focusElements, Element highlightElement) {
  Element focusedElement = focusElements.firstWhere((e) => e.id == value.current, orElse: () => null);
  highlightElement.classes.toggle(FOCUS, focusedElement != null);
  if (focusedElement != null) {
    focusedElement.focus();
  }

  return focusedElement != null;
}

//TODO move to model and merge with the one from the framework.
class MessageSearchFilter {
  String agent;
  String type;
  model.ReceptionStub reception;
  model.Contact contact;

  MessageSearchFilter(this.agent, this.type, this.reception, this.contact);
}
