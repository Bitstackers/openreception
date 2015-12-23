import 'dart:io';
import 'dart:convert';

import 'package:openreception_framework/database.dart' as or_db;
import 'package:openreception_framework/model.dart' as or_model;
import 'package:openreception_framework/pbx-keys.dart';

import '../lib/configuration.dart';

main(List<String> args) async {
  final or_db.Connection connection = await or_db.Connection.connect(config.database.dsn);
  or_db.Cdr cdrStore = new or_db.Cdr(connection);

  List<FileSystemEntity> listing = new Directory('cdr-json').listSync();

  bool isJsonFile(FileSystemEntity fse) => fse is File && fse.path.toLowerCase().endsWith('.json');

  String readFile(FileSystemEntity fse) => new File(fse.path).readAsStringSync();

  listing
      .where(isJsonFile)
      .map(readFile)
      .map(JSON.decode)
      .map(FsCdr.decode)
      .where(isNotAgentChannel)
      .forEach((cdr) async {
    or_model.FreeSWITCHCDREntry entry = new or_model.FreeSWITCHCDREntry.empty()
      ..uuid = cdr.channelId
      ..inbound = cdr.inbound
      ..receptionId = cdr.receptionId
      ..extension = cdr.extension
      ..duration = cdr.duration
      ..waitTime = cdr.waitTime
      ..startedAt = cdr.startedAt
      ..owner = cdr.owner
      ..contact_id = cdr.contactId;

    try {
      if (entry.receptionId != 0) {
        await cdrStore.create(entry);
      }

      //TODO: Perform long-term storage.
    } catch (error) {
      print(error);
    }
  });
}

String dir(bool inbound) => inbound ? '↙' : '↗';

String filename(String path) => path.split('/').last;

bool isNotAgentChannel(FsCdr cdr) => !cdr.channelId.startsWith('agent-');

class FsCdr {
  final Map data;

  String get coreUuid => data['core-uuid'];

  String get switchname => data['switchname'];

  Map get channelData => data['channel_data'];

  Map get _appLog => data.containsKey('app_log') ? data['app_log'] : {};

  Iterable get appLog =>
      _appLog.containsKey('applications') ? _appLog['applications'].map(AppEntry.decode) : [];

  List get callflow => data['callflow'];

  FsCdr.fromMap(this.data);

  static decode(Map map) => new FsCdr.fromMap(map);

  String get channelId => variables['uuid'];

  int get receptionId => variables.containsKey('reception_id')
      ? int.parse(variables['reception_id'])
      : or_model.Reception.noID;

  int get contactId => variables.containsKey('contact_id')
      ? int.parse(variables['contact_id'])
      : or_model.Contact.noID;

  Map get variables => data.containsKey('variables') ? data['variables'] : {};

  // bool isALeg =>

  bool get inbound => variables['direction'] == 'inbound';
  String get extension =>
      callflow.firstWhere((Map map) => map['profile_index'] == '1')['caller_profile']
          ['destination_number'];
  int get duration => int.parse(variables['billmsec']);
  int get waitTime => int.parse(variables['waitmsec']);
  DateTime get startedAt =>
      new DateTime.fromMillisecondsSinceEpoch(int.parse(variables['start_epoch']) * 1000);

  int get owner => variables.containsKey(PbxKey.ownerId)
      ? int.parse(variables[PbxKey.ownerId])
      : or_model.User.noID;
}

class AppEntry {
  final String name;
  final String data;

  AppEntry.fromMap(Map map)
      : name = map['app_name'],
        data = map['app_data'];

  static AppEntry decode(Map map) => new AppEntry.fromMap(map);

  @override
  String toString() => '$name($data)';
}
