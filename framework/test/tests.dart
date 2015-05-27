import 'dart:async';
import 'dart:convert';

import '../lib/bus.dart';
import '../lib/event.dart'    as Event;
import '../lib/model.dart'    as Model;
import '../lib/resource.dart' as Resource;
//import '../lib/service.dart'  as Service;
import 'data/testdata.dart'  as Test_Data;

import 'package:logging/logging.dart';
import 'package:junitconfiguration/junitconfiguration.dart';
import 'package:unittest/unittest.dart';

void main() {
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen((LogRecord record) =>
      logMessage(record.toString()));
  JUnitConfiguration.install();

  test('async openreception.bus test', () {
    final String testEvent = 'Foo!';
    Bus bus = new Bus<String>();
    Stream<String> stream = bus.stream;
    Timer timer;

    timer = new Timer(new Duration(seconds: 1), () {
      fail('testEvent not fired or caught within 1 second');
    });

    stream.listen(expectAsync((String value) {
      expect(value, equals(testEvent));

      if(timer != null) {
        timer.cancel();
      }
    }));

    bus.fire(testEvent);
  });

  test('Model.Contact serializationDeserialization', ModelContact.serializationDeserialization);

  group('Model.Message', () {
    test('serializationDeserialization', MessageObject.serializationDeserialization);
    test('serialization', MessageObject.serialization);
  });

  group('Model.Reception', () {
    test('serializationDeserialization', ModelReception.serializationDeserialization);
    test('serialization', ModelReception.serialization);
    test('buildObject', ModelReception.buildObject);
  });

  group('Model.CalendarEntry', () {
    test('serializationDeserialization', CalendarEntryObject.serializationDeserialization);
    test('serialization', CalendarEntryObject.serialization);
    test('contactEntryBuild', CalendarEntryObject.contactEntryBuild);
  });


  group('Model.CalendarEntryChange', () {
    test('serializationDeserialization', ModelCalendarEntryChange.serializationDeserialization);
    test('serialization', ModelCalendarEntryChange.serialization);
    test('buildObject', ModelCalendarEntryChange.buildObject);
  });

  group('Model.Config', () {
    test('serializationDeserialization', ConfigObject.serializationDeserialization);
    test('serialization', ConfigObject.serialization);
  });

  group('Model.PhoneNumber', () {
    test('buildObject', ModelPhoneNumber.buildObject);
  });

  group('Resource.Authentication', () {
    test('userOf', ResourceAuthentication.userOf);
    test('validate', ResourceAuthentication.validate);
  });

  group('Resource.Config', () {
    test('get', ResourceConfig.get);
  });

  group('Resource.Message', () {
    test('singleMessage', ResourceMessage.singleMessage);
    test('send', ResourceMessage.send);
    test('list', ResourceMessage.list);
  });

  group('Resource.Notification', () {
    test('socket', ResourceNotification.notifications);
    test('socket (bad schema)', ResourceNotification.notificationsBadSchema);
    test('send', ResourceNotification.send);
    test('broadcast', ResourceNotification.broadcast);
  });

  group('Resource.Reception', () {
    test('singleMessage', ResourceReception.single);
    test('list', ResourceReception.list);
    test('subset', ResourceReception.subset);
    test('calendar', ResourceReception.calendar);
    test('calendarEvent', ResourceReception.calendarEvent);
    test('calendarEntryChanges', ResourceReception.calendarEntryChanges);
    test('calendarEntryLatestChange', ResourceReception.calendarEntryLatestChange);
});

  group('Resource.CallFlowControl', () {
    test('userStatusMap', ResourceCallFlowControl.userStatusMap);
    test('channelList', ResourceCallFlowControl.channelList);
    test('userStatusIdle', ResourceCallFlowControl.userStatusIdle);
    test('userStatusKeepAlive', ResourceCallFlowControl.userStatusKeepAlive);
    test('userStatusLoggedOut', ResourceCallFlowControl.userStatusLogout);
    test('peerList', ResourceCallFlowControl.peerList);
    test('single', ResourceCallFlowControl.single);
    test('pickup', ResourceCallFlowControl.pickup);
    test('originate', ResourceCallFlowControl.originate);
    test('park', ResourceCallFlowControl.park);
    test('hangup', ResourceCallFlowControl.hangup);
    test('transfer', ResourceCallFlowControl.transfer);
    test('list', ResourceCallFlowControl.list);
  });

  group('Resource.Contact', () {
    test('calendar', ResourceContact.calendar);
    test('calendarEvent', ResourceContact.calendarEvent);
    test('endpoints', ResourceContact.endpoints);
    test('list', ResourceContact.list);
    test('phones', ResourceContact.phones);
    test('single', ResourceContact.single);
    test('singleByReception', ResourceContact.singleByReception);
    test('calendarEntryChanges', ResourceReception.calendarEntryChanges);
    test('calendarEntryLatestChange', ResourceReception.calendarEntryLatestChange);
  });

  group('Event.CalendarChangeEvent', () {
    test('buildObject', CalendarChangeEvent.buildObject);
    test('serialization', CalendarChangeEvent.serialization);
    test('serializationDeserialization', CalendarChangeEvent.serializationDeserialization);
  });

  group('Event.MessageChange', () {
    test('buildObject', EventMessageChange.buildObject);
    test('serialization', EventMessageChange.serialization);
    test('serializationDeserialization', EventMessageChange.serializationDeserialization);
  });

}

abstract class ResourceCallFlowControl {
  static Uri callFlowControlUri = Uri.parse('http://localhost:4242');

  static void userStatusMap () =>
      expect(Resource.CallFlowControl.userStatus(callFlowControlUri, 1),
        equals(Uri.parse('${callFlowControlUri}/userstate/1')));

  static void channelList () =>
      expect(Resource.CallFlowControl.channelList(callFlowControlUri),
        equals(Uri.parse('${callFlowControlUri}/channel/list')));

  static void userStatusIdle () =>
      expect(Resource.CallFlowControl.userStatusIdle(callFlowControlUri, 1),
        equals(Uri.parse('${callFlowControlUri}/userstate/1/idle')));

  static void userStatusKeepAlive () =>
      expect(Resource.CallFlowControl.userStateKeepAlive(callFlowControlUri, 1),
        equals(Uri.parse('${callFlowControlUri}/userstate/1/keep-alive')));

  static void userStatusLogout() =>
      expect(Resource.CallFlowControl.userStateLoggedOut(callFlowControlUri, 1),
        equals(Uri.parse('${callFlowControlUri}/userstate/1/loggedOut')));

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
      expect(() => new Model.Message.fromMap(Test_Data.testMessage_1_Map), returnsNormally);
}

abstract class ModelReception {
  static void serializationDeserialization () {
      expect(new Model.Reception.fromMap(Test_Data.testReception).asMap,
        equals(Test_Data.testReception));

      expect(new Model.Reception.fromMap(Test_Data.testReception2).asMap,
        equals(Test_Data.testReception2));

   }


  /**
   * Merely asserts that no exceptions arise.
   */
  static void serialization () =>
      expect(() => new Model.Reception.fromMap(Test_Data.testReception), returnsNormally);

  static void buildObject () {
    Model.Reception testReception = new Model.Reception()
      ..addresses = []
      ..alternateNames = []
      ..attributes = {}
      ..bankingInformation = []
      ..customerTypes = ['Not defined']
      ..emailAddresses = []
      ..enabled = true
      ..extension = '12340001'
      ..extraData = Uri.parse ('http://localhost/test')
      ..fullName = 'Test test'
      ..greeting = 'Go away'
      ..handlingInstructions = ['Hang up']
      ..ID = 999
      ..lastChecked = new DateTime.now()
      ..openingHours = []
      ..organizationId  = 888
      ..otherData = 'Nope'
      ..product = 'Butter'
      ..salesMarketingHandling = []
      ..shortGreeting = 'Please go'
      ..telephoneNumbers = [new Model.PhoneNumber.empty()
                              ..value = '56 33 21 44']
      ..vatNumbers = []
      ..websites = [];
    expect(testReception.toJson, returnsNormally);
  }
}

abstract class CalendarEntryObject {
  static void serializationDeserialization () =>
      expect(new Model.CalendarEntry.fromMap(Test_Data.testReceptionCalendarEntry).asMap,
        equals(Test_Data.testReceptionCalendarEntry));

  /**
   * Merely asserts that no exceptions arise.
   */
  static void serialization () =>
      expect(() => new Model.CalendarEntry.fromMap(Test_Data.testReceptionCalendarEntry), returnsNormally);

  static void contactEntryBuild () {
    final int id = 1;
    final int rid = 2;
    final int cid = 3;
    final String body = 'test test test';
    final DateTime begin = new DateTime.now().add(new Duration(hours : 1));
    final DateTime end = new DateTime.now().add(new Duration(hours : 2));

    Model.CalendarEntry testEntry = new Model.CalendarEntry.forContact(cid, rid)
      ..ID = id
      ..content = body
      ..beginsAt = begin
      ..until = end;

    expect(testEntry.ID, equals (id));
    expect(testEntry.contactID, equals (cid));
    expect(testEntry.receptionID, equals (rid));
    expect(testEntry.content, equals (body));
    expect(testEntry.start, equals (begin));
    expect(testEntry.stop, equals (end));
  }
}

abstract class CalendarChangeEvent {

  static void buildObject () {
    final int id = 1;
    final int rid = 2;
    final int cid = 3;
    final state = Event.CalendarEntryState.CREATED;

    Event.CalendarChange testEvent =
        new Event.CalendarChange (id, cid, rid, state);

    expect(testEvent.entryID, equals (id));
    expect(testEvent.contactID, equals (cid));
    expect(testEvent.receptionID, equals (rid));
    expect(testEvent.state, equals (state));
  }

  static void serialization () {
    final int id = 1;
    final int rid = 2;
    final int cid = 3;
    final state = Event.CalendarEntryState.CREATED;

    Event.CalendarChange testEvent =
        new Event.CalendarChange (id, cid, rid, state);

    expect (testEvent.toJson, returnsNormally);
  }

  static void serializationDeserialization () {
    final int id = 1;
    final int rid = 2;
    final int cid = 3;
    final state = Event.CalendarEntryState.CREATED;

    Event.CalendarChange testEvent =
        new Event.CalendarChange (id, cid, rid, state);

    Map serialized = testEvent.toJson();

    expect (new Event.CalendarChange.fromMap(serialized).asMap, equals(serialized));
  }

}

abstract class EventMessageChange {

  static void buildObject () {
    final int mid = 1;
    final state = Event.MessageChangeState.CREATED;

    Event.MessageChange testEvent =
        new Event.MessageChange (mid, state);

    expect(testEvent.messageID, equals (mid));
    expect(testEvent.state, equals (state));
  }

  static void serialization () {
    final int mid = 1;
    final state = Event.MessageChangeState.CREATED;

    Event.MessageChange testEvent =
        new Event.MessageChange (mid, state);

    expect (testEvent.toJson, returnsNormally);
  }

  static void serializationDeserialization () {
    final int mid = 1;
    final state = Event.MessageChangeState.CREATED;

    Event.MessageChange testEvent =
        new Event.MessageChange (mid, state);

    expect(testEvent.messageID, equals (mid));
    expect(testEvent.state, equals (state));

    Map serialized = testEvent.toJson();

    expect (new Event.MessageChange.fromMap(serialized).asMap,
        equals(serialized));
  }

}


abstract class ModelCalendarEntryChange {
  static void serializationDeserialization () =>
      expect(new Model.CalendarEntryChange.fromMap
        (Test_Data.calendarEntryChange).asMap,
          equals(Test_Data.calendarEntryChange));

  /**
   * Merely asserts that no exceptions arise.
   */
  static void serialization () =>
      expect(() => JSON.encode(new Model.CalendarEntryChange.fromMap
          (Test_Data.calendarEntryChange)), returnsNormally);

  static void buildObject () {
    DateTime changedAt = new DateTime.now();
    int changedBy = 2;
    String changedByName = 'That guy';

    Model.CalendarEntryChange testChange = new Model.CalendarEntryChange()
      ..changedAt = changedAt
      ..userID    = changedBy
      ..username  = changedByName;

    expect(testChange.userID, equals(changedBy));
    expect(testChange.changedAt, equals(changedAt));
    expect(testChange.username, equals(changedByName));
  }
}


abstract class ModelContact {

  static void serializationDeserialization () =>
      expect(new Model.Contact.fromMap(Test_Data.testContact_4_1).asMap,
        equals(Test_Data.testContact_4_1));
}

abstract class ModelPhoneNumber {
  static void buildObject () {
    final String description =  'Cell Phone - work';
    final String value = '+45 44 88 1231';
    final String type = 'pstn';
    final bool confidential = false;
    final String billing_type = 'cell';
    final List<String> tags = ['work', 'official'];


    Model.PhoneNumber phoneNumber =
      new Model.PhoneNumber.empty()
        ..billing_type = billing_type
        ..confidential = confidential
        ..description = description
        ..tags = tags
        ..type = type
        ..value = value;

    expect (phoneNumber.billing_type, equals(billing_type));
    expect (phoneNumber.confidential, equals(confidential));
    expect (phoneNumber.description, equals(description));
    expect (phoneNumber.tags, equals(tags));
    expect (phoneNumber.type, equals(type));
    expect (phoneNumber.value, equals(value));
  }
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

  static void calendarEntryChanges () =>
      expect(Resource.Reception.calendarEventChanges(receptionServer, 123),
          equals(Uri.parse('${receptionServer}/calendarentry/123/change')));

  static void calendarEntryLatestChange () =>
      expect(Resource.Reception.calendarEventLatestChange(receptionServer, 123),
          equals(Uri.parse('${receptionServer}/calendarentry/123/change/latest')));

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
}

abstract class ResourceAuthentication {
  static final Uri authServer = Uri.parse('http://localhost:4050');

  static void userOf () =>
      expect(Resource.Authentication.tokenToUser(authServer, 'testtest'),
        equals(Uri.parse('${authServer}/token/testtest')));

  static void validate () =>
      expect(Resource.Authentication.validate(authServer, 'testtest'),
        equals(Uri.parse('${authServer}/token/testtest/validate')));
}

abstract class ResourceConfig {
  static final Uri configServer = Uri.parse('http://localhost:4080');

  static void get () =>
      expect(Resource.Config.get(configServer),
        equals(Uri.parse('${configServer}/configuration')));

}

abstract class ConfigObject {
  static void serializationDeserialization () =>
      expect(new Model.ClientConfiguration.fromMap(Test_Data.configMap).asMap,
        equals(Test_Data.configMap));

  /**
   * Merely asserts that no exceptions arise.
   */
  static void serialization () =>
      expect(new Model.ClientConfiguration.fromMap(Test_Data.configMap), isNotNull);
}

abstract class ResourceNotification {
  static final Uri notificationServer = Uri.parse('http://localhost:4242');
  static final Uri notificationSocket = Uri.parse('ws://localhost:4242');

  static void notifications () =>
      expect(Resource.Notification.notifications(notificationSocket),
        equals(Uri.parse('${notificationSocket}/notifications')));

  static void notificationsBadSchema () =>
      expect(() => Resource.Notification.notifications(notificationServer),
        throwsA(new isInstanceOf<ArgumentError>()));

  static void send () =>
      expect(Resource.Notification.send(notificationServer),
        equals(Uri.parse('${notificationServer}/send')));

  static void broadcast () =>
      expect(Resource.Notification.broadcast(notificationServer),
        equals(Uri.parse('${notificationServer}/broadcast')));
}

abstract class ResourceContact {
  static final Uri contactServer = Uri.parse('http://localhost:4010');

  static void single () =>
      expect(Resource.Contact.single(contactServer, 999),
        equals(Uri.parse('${contactServer}/contact/999')));

  static void list () =>
      expect(Resource.Contact.list(contactServer),
        equals(Uri.parse('${contactServer}/contact')));

  static void singleByReception () =>
      expect(Resource.Contact.singleByReception(contactServer, 999, 456),
        equals(Uri.parse('${contactServer}/contact/999/reception/456')));

  static void calendar () =>
      expect(Resource.Contact.calendar(contactServer, 999, 888),
        equals(Uri.parse('${contactServer}/contact/999/reception/888/calendar')));

  static void calendarEvent () =>
      expect(Resource.Contact.calendarEvent(contactServer, 999, 777, 123),
        equals(Uri.parse('${contactServer}/contact/999/reception/777/calendar/event/123')));

  static void endpoints () =>
      expect(Resource.Contact.endpoints(contactServer, 123, 456),
        equals(Uri.parse('${contactServer}/contact/123/reception/456/endpoints')));

  static void phones () =>
      expect(Resource.Contact.phones(contactServer, 123,456),
          equals(Uri.parse('${contactServer}/contact/123/reception/456/phones')));

  static void calendarEntryChanges () =>
      expect(Resource.Contact.calendarEventChanges(contactServer, 123),
          equals(Uri.parse('${contactServer}/calendarentry/change/123')));

  static void calendarEntryLatestChange () =>
      expect(Resource.Contact.calendarEventLatestChange(contactServer, 123),
          equals(Uri.parse('${contactServer}/calendarentry/123/change/latest')));
}