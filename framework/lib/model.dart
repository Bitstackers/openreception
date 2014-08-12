library openreception.model;

import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import 'common.dart' as Common;
import 'database.dart';
import 'storage.dart' as Storage;

part 'model/model-user.dart';
part 'model/model-message.dart';
part 'model/model-message_context.dart';
part 'model/model-message_header.dart';
part 'model/model-message_endpoint.dart';
part 'model/model-message_filter.dart';
part 'model/model-message_queue_item.dart';
part 'model/model-message_recipient.dart';
part 'model/model-message_recipient_list.dart';
part 'model/model-template.dart';
part 'model/model-template_email.dart';

const String libraryName = "openreception.model";

final Level loglevel = Level.INFO;


