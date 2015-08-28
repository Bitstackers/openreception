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

library openreception.model;

import 'dart:async';
import 'dart:collection';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import 'bus.dart';
import 'event.dart'   as Event;
import 'keys.dart'    as Key;
import 'util.dart'    as Util;

part 'model/model-audiofile.dart';
part 'model/model-base_contact.dart';
part 'model/model-calendar_entry.dart';
part 'model/model-calendar_entry_change.dart';
part 'model/model-call.dart';
part 'model/model-caller_info.dart';
part 'model/model-cdr_checkpoint.dart';
part 'model/model-cdr_entry.dart';
part 'model/model-channel.dart';
part 'model/model-client_configuration.dart';
part 'model/model-client_connection.dart';
part 'model/model-contact.dart';
part 'model/model-contact_filter.dart';
part 'model/model-dialplan_template.dart';
part 'model/model-distribution_list.dart';
part 'model/model-distribution_list_entry.dart';
part 'model/model-freeswitch_cdr_entry.dart';
part 'model/model-message.dart';
part 'model/model-message_context.dart';
part 'model/model-message_flag.dart';
part 'model/model-message_header.dart';
part 'model/model-message_endpoint.dart';
part 'model/model-message_filter.dart';
part 'model/model-message_queue_item.dart';
part 'model/model-message_recipient.dart';
part 'model/model-organization.dart';
part 'model/model-owner.dart';
part 'model/model-peer.dart';
part 'model/model-phone_number.dart';
part 'model/model-playlist.dart';
part 'model/model-reception.dart';
part 'model/model-reception_filter.dart';
part 'model/model-template.dart';
part 'model/model-template_email.dart';
part 'model/model-user.dart';
part 'model/model-user_group.dart';
part 'model/model-user_identity.dart';
part 'model/model-user_status.dart';

const String libraryName = "openreception.model";
