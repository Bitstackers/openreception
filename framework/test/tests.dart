//import 'dart:async';

import 'package:unittest/unittest.dart';
//import 'package:logging/logging.dart';
import 'package:junitconfiguration/junitconfiguration.dart';

import '../lib/model.dart'   as Model;
import '../lib/service.dart' as Service;

import 'data/testdata.dart'  as Test_Data;

void main() {
  //Logger.root.onRecord.listen(print);

  JUnitConfiguration.install();

  test('service.ContactObject.serializationDeserialization', ContactObject.serializationDeserialization);

  group('service.MessageObject', () {
    test('serializationDeserialization', MessageObject.serializationDeserialization);
    test('serialization', MessageObject.serialization);
  });

  group('service.MessageResource', () {
    test('singleMessage', MessageResource.singleMessage);
    test('send', MessageResource.send);
    test('list', MessageResource.list);
    test('subset', MessageResource.subset);
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

abstract class MessageResource {
  static Uri messageServer = Uri.parse('http://localhost:4040');

  static void singleMessage () =>
      expect(Service.MessageResource.single(messageServer, 5),
        equals(Uri.parse('${messageServer}/message/5')));

  static void send () =>
      expect(Service.MessageResource.send(messageServer, 5),
        equals(Uri.parse('${messageServer}/message/5/send')));

  static void list () =>
      expect(Service.MessageResource.list(messageServer),
        equals(Uri.parse('${messageServer}/message/list')));

  static void subset () =>
      expect(Service.MessageResource.subset(messageServer, 10, 20),
        equals(Uri.parse('${messageServer}/message/list/10/limit/20')));
}
