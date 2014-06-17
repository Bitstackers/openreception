library model;

import 'dart:async';
import 'dart:convert';

import 'package:OpenReceptionFramework/common.dart';
import 'package:mailer/mailer.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import 'database.dart';

part 'model/model-message.dart';
part 'model/template.dart';
part 'model/template-email.dart';

final String libraryName = 'model';

final Logger log = new Logger(libraryName);

