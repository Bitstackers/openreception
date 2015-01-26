library model;

import 'dart:convert';

import 'package:libdialplan/libdialplan.dart';
import 'package:openreception_framework/model.dart' as ORF;

import 'logger.dart' as log;

part 'model/audiofile.dart';
part 'model/calendar_event.dart';
part 'model/cdr_entry.dart';
part 'model/checkpoint.dart';
part 'model/contact.dart';
part 'model/contact_attribute.dart';
part 'model/dialplan_template.dart';
part 'model/distributionlist.dart';
part 'model/endpoint.dart';
part 'model/organization.dart';
part 'model/reception.dart';
part 'model/phone.dart';
part 'model/playlist.dart';
part 'model/user.dart';
part 'model/user_group.dart';
part 'model/user_identity.dart';

String stringFromJson(Map json, String key) {
  if (json.containsKey(key)) {
    return json[key];
  } else {
    log.error('Key "$key" not found in "${json}"');
    return null;
  }
}
