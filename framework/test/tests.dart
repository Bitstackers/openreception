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
    test('service.MessageResource.singleMessage', MessageResource.singleMessage);
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
  static void singleMessage () =>
      expect(Service.MessageResource.single(Uri.parse('http://test/'), 5),
        equals(Uri.parse('http://test/message/5')));
}
