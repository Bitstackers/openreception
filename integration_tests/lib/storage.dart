library openreception_tests.storage;

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
import 'package:openreception_framework/model.dart' as model;
import 'package:openreception_framework/storage.dart' as storage;
import 'package:openreception_tests/support.dart';

part 'storage/storage-calendar.dart';
part 'storage/storage-contact.dart';
part 'storage/storage-dialplan.dart';
part 'storage/storage-ivr.dart';
part 'storage/storage-message_queue.dart';
part 'storage/storage-message.dart';
part 'storage/storage-organization.dart';
part 'storage/storage-reception.dart';
part 'storage/storage-user.dart';

const String _libraryName = 'storage';

final notFoundError = new isInstanceOf<storage.NotFound>();
final unchangedError = new isInstanceOf<storage.Unchanged>();
