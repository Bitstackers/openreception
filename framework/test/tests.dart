//import 'dart:async';

import 'package:unittest/unittest.dart';
//import 'package:logging/logging.dart';
//import 'package:junitconfiguration/junitconfiguration.dart';

import '../lib/model.dart'    as Model;
//import '../lib/service.dart'  as Service;
import '../lib/resource.dart' as Resource;

import 'data/testdata.dart'  as Test_Data;

void main() {
  //Logger.root.onRecord.listen(print);

//  JUnitConfiguration.install();

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

  group('service.ResourceCallFlowControl', () {
    test('userStatusMap', ResourceCallFlowControl.userStatusMap);
    test('channelList', ResourceCallFlowControl.channelList);
    test('userStatusIdle', ResourceCallFlowControl.userStatusIdle);
    test('peerList', ResourceCallFlowControl.peerList);
    test('single', ResourceCallFlowControl.single);
    test('pickup', ResourceCallFlowControl.pickup);
    test('originate', ResourceCallFlowControl.originate);
    test('park', ResourceCallFlowControl.park);
    test('hangup', ResourceCallFlowControl.hangup);
    test('transfer', ResourceCallFlowControl.transfer);
    test('list', ResourceCallFlowControl.list);
    test('queue', ResourceCallFlowControl.queue);
    test('root', ResourceCallFlowControl.root);

  });
}

abstract class ResourceCallFlowControl {
  static Uri callFlowControlUri = Uri.parse('http://localhost:4242');

  static void userStatusMap () =>
      expect(Resource.CallFlowControl.userStatus(callFlowControlUri, 1),
        equals(Uri.parse('${callFlowControlUri}/userstatus/1')));

  static void channelList () =>
      expect(Resource.CallFlowControl.channelList(callFlowControlUri),
        equals(Uri.parse('${callFlowControlUri}/channel/list')));

  static void userStatusIdle () =>
      expect(Resource.CallFlowControl.userStatusIdle(callFlowControlUri, 1),
        equals(Uri.parse('${callFlowControlUri}/userstatus/1/idle')));

  static void peerList () =>
      expect(Resource.CallFlowControl.peerList(callFlowControlUri),
        equals(Uri.parse('${callFlowControlUri}/peer/list')));

  static void single () =>
      expect(Resource.CallFlowControl.single(callFlowControlUri, 'abcde'),
        equals(Uri.parse('${callFlowControlUri}/call/abcde')));

  static void pickup () =>
      expect(Resource.CallFlowControl.pickup(callFlowControlUri, 'abcde'),
        equals(Uri.parse('${callFlowControlUri}/call/abcde/pickup')));

  static void originate () =>
      expect(Resource.CallFlowControl.originate(callFlowControlUri, '12345678', 1, 2),
        equals(Uri.parse('${callFlowControlUri}/call/originate/12345678/reception/2/contact/1')));

  static void park () =>
      expect(Resource.CallFlowControl.park(callFlowControlUri, 'abcde'),
        equals(Uri.parse('${callFlowControlUri}/call/abcde/park')));

  static void hangup () =>
      expect(Resource.CallFlowControl.hangup(callFlowControlUri, 'abcde'),
        equals(Uri.parse('${callFlowControlUri}/call/abcde/hangup')));

  static void transfer () =>
      expect(Resource.CallFlowControl.transfer(callFlowControlUri, 'abcde', 'edcba'),
        equals(Uri.parse('${callFlowControlUri}/call/abcde/transfer/edcba')));

  static void list () =>
      expect(Resource.CallFlowControl.list(callFlowControlUri),
        equals(Uri.parse('${callFlowControlUri}/call/list')));

  static void queue () =>
      expect(Resource.CallFlowControl.queue(callFlowControlUri),
        equals(Uri.parse('${callFlowControlUri}/call/queue')));

  static void root () =>
      expect(Resource.CallFlowControl.root(callFlowControlUri),
        equals(Uri.parse('${callFlowControlUri}/call')));
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

