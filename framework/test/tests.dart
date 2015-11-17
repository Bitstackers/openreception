/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library openreception.test;

import 'dart:async';
import 'dart:convert';

import '../lib/bus.dart';
import '../lib/event.dart'    as Event;
import '../lib/model.dart'    as Model;
import '../lib/resource.dart' as Resource;
//import '../lib/service.dart'  as Service;
import 'data/testdata.dart'  as Test_Data;

import 'package:logging/logging.dart';
import 'package:junitconfiguration/junitconfiguration.dart';
import 'package:unittest/unittest.dart';

part 'src/bus.dart';
part 'src/model/model-agent_history.dart';
part 'src/model/model-base_contact.dart';
part 'src/model/model-calendar_entry.dart';
part 'src/model/model-calendar_entry_change.dart';
part 'src/model/model-call.dart';
part 'src/model/model-caller_info.dart';
//part 'src/model-channel.dart';
part 'src/model/model-client_configuration.dart';
part 'src/model/model-client_connection.dart';
part 'src/model/model-contact.dart';
//part 'src/model-contact_filter.dart';
part 'src/model/model-distribution_list.dart';
part 'src/model/model-distribution_list_entry.dart';
part 'src/model/model-message.dart';
part 'src/model/model-message_context.dart';
//part 'src/model-message_header.dart';
//part 'src/model-message_endpoint.dart';
part 'src/model/model-message_filter.dart';
part 'src/model/model-message_queue_entry.dart';
part 'src/model/model-message_recipient.dart';
part 'src/model/model-organization.dart';
//part 'src/model-peer.dart';
part 'src/model/model-phone_number.dart';
part 'src/model/model-reception.dart';
//part 'src/model-reception_filter.dart';
//part 'src/model-template.dart';
//part 'src/model-template_email.dart';
part 'src/model/model-user.dart';
part 'src/model/model-user_status.dart';

part 'src/model/dialplan/model-ivr_entry.dart';
part 'src/model/dialplan/model-playback.dart';

part 'src/resource/resource-authentication.dart';
part 'src/resource/resource-calendar.dart';
part 'src/resource/resource-call_flow_control.dart';
part 'src/resource/resource-cdr.dart';
part 'src/resource/resource-config.dart';
part 'src/resource/resource-contact.dart';
part 'src/resource/resource-distribution_list.dart';
part 'src/resource/resource-endpoint.dart';
part 'src/resource/resource-message.dart';
part 'src/resource/resource-notification.dart';
part 'src/resource/resource-organization.dart';
part 'src/resource/resource-reception.dart';

part 'src/event.dart';
part 'src/event-calendar_change.dart';
part 'src/event-message_change.dart';

void main() {
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen((LogRecord record) =>
      logMessage(record.toString()));
  JUnitConfiguration.install();



  testModelIvrMenu();
  testModelPlayback();
  testBus();

  testEvent();
  testEventMessageChange();
  testEventCalendarChange();

  testModelAgentStatistics();
  testModelBaseContact();
  testModelCalendarEntry();
  testModelCalendarEntryChange();
  testModelCall();
  testModelClientConfiguration();
  testModelClientConnection();
  testModelContact();
  testModelDistributionList();
  testModelDistributionListEntry();

  testModelOrganization();
  testModelReception();
  testModelMessage();
  testModelCallerInfo();
  testModelMessageContext();
  testModelMessageFilter();
  testModelMessageQueueEntry();
  testModelMessageRecipient();

  testModelPhoneNumber();
  testModelUserStatus();
  testModelUser();

  testResourceAuthentication();
  testResourceCalendar();
  testResourceCallFlowControl();
  testResourceCDR();
  testResourceConfig();
  testResourceContact();
  testResourceDistributionList();
  testResourceEndpoint();
  testResourceMessage();
  testResourceNotification();
  testResourceReception();
}
