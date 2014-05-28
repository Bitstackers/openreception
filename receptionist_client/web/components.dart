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

import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import 'classes/configuration.dart';
import 'classes/context.dart';
import 'classes/commands.dart' as command;
import 'classes/common.dart';
import 'classes/focus.dart';
import 'classes/events.dart' as event;
import 'classes/id.dart' as id;
import 'classes/commands.keyboard.dart';
import 'classes/location.dart' as nav;
import 'classes/logger.dart';
import 'model/model.dart' as model;
import 'protocol/protocol.dart' as protocol;
import 'storage/storage.dart' as storage;
import 'controller/controller.dart' as Controller;
import 'view/view.dart' as View;

part 'components/agentinfo.dart';
part 'components/boxwithheader.dart';
part 'components/view-call.dart';
part 'components/companyaddresses.dart';
part 'components/companyalternatenames.dart';
part 'components/companybankinginformation.dart';
part 'components/companycustomertype.dart';
part 'components/companyemailaddresses.dart';
part 'components/view-reception-handling.dart';
part 'components/companyopeninghours.dart';
part 'components/companyother.dart';
part 'components/companyproduct.dart';
part 'components/companyregistrationnumber.dart';
part 'components/companysalescalls.dart';
part 'components/companyselector.dart';
part 'components/companytelephonenumbers.dart';
part 'components/companywebsites.dart';
part 'components/globalqueue.dart';
part 'components/localqueue.dart';
part 'components/welcomemessage.dart';
part 'components/contactinfo.dart';
part 'components/contactinfosearch.dart';
part 'components/contactinfocalendar.dart';
part 'components/contactinfodata.dart';

part 'components/constants.dart';

part 'components/messagesearch.dart';

part 'components/logbox.dart';

part 'components/phonebooth.dart';

part 'components/searchcomponent.dart';

const String libraryName = 'components';

typedef void onCallQueueClick(MouseEvent event, Call queueItem);

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

