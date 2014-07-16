library model;

import 'dart:async';
import 'dart:convert';

import 'package:OpenReceptionFramework/common.dart';
import 'package:OpenReceptionFramework/model.dart' as SharedModel;

import 'package:mailer/mailer.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import 'database.dart' as Database;

part 'model/model-message.dart';
part 'model/model-message_context.dart';
part 'model/model-message_endpoint.dart';
part 'model/model-message_header.dart';
part 'model/model-message_recipient.dart';
part 'model/model-message_recipient_list.dart';
part 'model/template.dart';
part 'model/template-email.dart';

const String libraryName = 'model';

final Logger log = new Logger(libraryName);

