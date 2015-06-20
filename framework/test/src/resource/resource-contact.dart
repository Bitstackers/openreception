part of openreception.test;

void testResourceContact() {
  group('Resource.Contact', () {
    test('calendar', ResourceContact.calendar);
    test('calendarEvent', ResourceContact.calendarEvent);
    test('endpoints', ResourceContact.endpoints);
    test('list', ResourceContact.list);
    test('phones', ResourceContact.phones);
    test('single', ResourceContact.single);
    test('singleByReception', ResourceContact.singleByReception);
    test('calendarEntryChanges', ResourceReception.calendarEntryChanges);
    test('calendarEntryLatestChange',
        ResourceReception.calendarEntryLatestChange);
  });
}

abstract class ResourceContact {
  static final Uri contactServer = Uri.parse('http://localhost:4010');

  static void single() => expect(Resource.Contact.single(contactServer, 999),
      equals(Uri.parse('${contactServer}/contact/999')));

  static void list() => expect(Resource.Contact.list(contactServer),
      equals(Uri.parse('${contactServer}/contact')));

  static void singleByReception() => expect(
      Resource.Contact.singleByReception(contactServer, 999, 456),
      equals(Uri.parse('${contactServer}/contact/999/reception/456')));

  static void calendar() => expect(
      Resource.Contact.calendar(contactServer, 999, 888),
      equals(Uri.parse('${contactServer}/contact/999/reception/888/calendar')));

  static void calendarEvent() => expect(
      Resource.Contact.calendarEvent(contactServer, 999, 777, 123),
      equals(Uri.parse(
          '${contactServer}/contact/999/reception/777/calendar/event/123')));

  static void endpoints() => expect(
      Resource.Contact.endpoints(contactServer, 123, 456), equals(
          Uri.parse('${contactServer}/contact/123/reception/456/endpoints')));

  static void phones() => expect(
      Resource.Contact.phones(contactServer, 123, 456),
      equals(Uri.parse('${contactServer}/contact/123/reception/456/phones')));

  static void calendarEntryChanges() => expect(
      Resource.Contact.calendarEventChanges(contactServer, 123),
      equals(Uri.parse('${contactServer}/calendarentry/change/123')));

  static void calendarEntryLatestChange() => expect(
      Resource.Contact.calendarEventLatestChange(contactServer, 123),
      equals(Uri.parse('${contactServer}/calendarentry/123/change/latest')));
}
