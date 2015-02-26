//import 'dart:async';

import 'package:unittest/unittest.dart';
//import 'package:logging/logging.dart';
import 'package:junitconfiguration/junitconfiguration.dart';

import '../lib/model.dart'    as Model;
//import '../lib/service.dart'  as Service;
import '../lib/resource.dart' as Resource;

import 'data/testdata.dart'  as Test_Data;

void main() {
  //Logger.root.onRecord.listen(print);

  JUnitConfiguration.install();

  test('service.ContactObject.serializationDeserialization', ContactObject.serializationDeserialization);

  group('service.MessageObject', () {
    test('serializationDeserialization', MessageObject.serializationDeserialization);
    test('serialization', MessageObject.serialization);
  });

  group('service.ResourceMessage', () {
    test('singleMessage', ResourceMessage.singleMessage);
    test('send', ResourceMessage.send);
    test('list', ResourceMessage.list);
    test('subset', ResourceMessage.subset);
  });

  group('service.ResourceReception', () {
    test('singleMessage', ResourceReception.single);
    test('list', ResourceReception.list);
    test('subset', ResourceReception.subset);
    test('calendar', ResourceReception.calendar);
    test('calendarEvent', ResourceReception.calendarEvent);
  });

}

abstract class MessageObject {
  static void serializationDeserialization () =>
      expect(new Model.Message.fromMap(Test_Data.testMessage_1_Map).asMap,
        equals(Test_Data.testMessage_1_Map));

  /**
   * Merely asserts that no exceptions arise.
   */
  static void serialization () =>
      expect(new Model.Message.fromMap(Test_Data.testMessage_1_Map), isNotNull);
}

abstract class ContactObject {
  static void serializationDeserialization () =>
      expect(new Model.Contact.fromMap(Test_Data.testContact_1_2).asMap,
        equals(Test_Data.testContact_1_2));
}

abstract class ResourceReception {
  static Uri receptionServer = Uri.parse('http://localhost:4000');

  static void single () =>
      expect(Resource.Reception.single(receptionServer, 1),
        equals(Uri.parse('${receptionServer}/reception/1')));

  static void list () =>
      expect(Resource.Reception.list(receptionServer),
        equals(Uri.parse('${receptionServer}/reception')));

  static void subset () =>
      expect(Resource.Reception.subset(receptionServer, 10, 20),
        equals(Uri.parse('${receptionServer}/reception/10/limit/20')));

  static void calendar () =>
      expect(Resource.Reception.calendar(receptionServer, 1),
        equals(Uri.parse('${receptionServer}/reception/1/calendar')));

  static void calendarEvent () =>
      expect(Resource.Reception.calendarEvent(receptionServer, 1, 2),
        equals(Uri.parse('${receptionServer}/reception/1/calendar/event/2')));
}

abstract class ResourceMessage {
  static Uri messageServer = Uri.parse('http://localhost:4040');

  static void singleMessage () =>
      expect(Resource.Message.single(messageServer, 5),
        equals(Uri.parse('${messageServer}/message/5')));

  static void send () =>
      expect(Resource.Message.send(messageServer, 5),
        equals(Uri.parse('${messageServer}/message/5/send')));

  static void list () =>
      expect(Resource.Message.list(messageServer),
        equals(Uri.parse('${messageServer}/message/list')));

  static void subset () =>
      expect(Resource.Message.subset(messageServer, 10, 20),
        equals(Uri.parse('${messageServer}/message/list/10/limit/20')));
}

