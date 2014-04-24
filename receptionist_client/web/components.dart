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

library components;

import 'dart:async';
import 'dart:html';

import 'package:logging/logging.dart';

import 'classes/configuration.dart';
import 'classes/context.dart';
import 'classes/commands.dart' as command;
import 'classes/common.dart';
import 'classes/focus.dart';
import 'classes/events.dart' as event;
import 'classes/id.dart' as id;
import 'classes/keyboardhandler.dart';
import 'classes/location.dart' as nav;
import 'classes/logger.dart';
import 'classes/model.dart' as model;
import 'classes/protocol.dart' as protocol;
import 'service.dart' as service;
import 'classes/storage.dart' as storage;
import 'classes/controller.dart' as controller;

part 'components/agentinfo.dart';
part 'components/boxwithheader.dart';
part 'components/callqueueitem.dart';
part 'components/companyaddresses.dart';
part 'components/companyalternatenames.dart';
part 'components/companybankinginformation.dart';
part 'components/companycustomertype.dart';
part 'components/companyemailaddresses.dart';
part 'components/companyevents.dart';
part 'components/companyhandling.dart';
part 'components/companyopeninghours.dart';
part 'components/companyother.dart';
part 'components/companyproduct.dart';
part 'components/companyregistrationnumber.dart';
part 'components/companysalescalls.dart';
part 'components/companyselector.dart';
part 'components/companytelephonenumbers.dart';
part 'components/companywebsites.dart';
part 'components/contextswitcher.dart';
part 'components/globalqueue.dart';
part 'components/localqueue.dart';
part 'components/sendmessage.dart';
part 'components/welcomemessage.dart';
part 'components/contactinfo.dart';
part 'components/contactinfosearch.dart';
part 'components/contactinfocalendar.dart';
part 'components/contactinfodata.dart';

part 'components/constants.dart';

part 'components/messagesearch.dart';
part 'components/messageoverview.dart';

part 'components/logbox.dart';

part 'components/phonebooth.dart';

part 'components/searchcomponent.dart';

typedef void onCallQueueClick(MouseEvent event, CallQueueItem queueItem);

bool handleFocusChange(Focus value, List<Element> focusElements, Element highlightElement) {
  Element focusedElement = focusElements.firstWhere((e) => e.id == value.current, orElse: () => null);
  highlightElement.classes.toggle(FOCUS, focusedElement != null);
  if(focusedElement != null) {
    focusedElement.focus();
  }

  return focusedElement != null;
}

class MessageSearchFilter {
  String agent;
  String type;
  model.BasicReception reception;
  model.Contact contact;

  MessageSearchFilter(this.agent, this.type, this.reception, this.contact);
}

