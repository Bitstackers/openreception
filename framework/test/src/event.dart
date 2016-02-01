/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.test;

void testEvent() {
  group('Event.parse', () {
    test('contactChangeState', EventTests.contactChangeState);
    test('endpointChange', EventTests.endpointChange);
    test('organizationChangeState', EventTests.organizationChangeState);
    test('receptionChangeState', EventTests.receptionChangeState);
    test('receptionContactChangeState', EventTests.receptionContactChangeState);
    test('messageChangeState', EventTests.messageChangeState);
    test('calendarEntryState', EventTests.calendarEntryState);
    test('userChange', EventTests.userChange);
    test('callStateReload', EventTests.callStateReload);
    test('callHangup', EventTests.callHangup);
  });
}

abstract class EventTests {
  static void endpointChange() {
    final int cid = 1;
    final int rid = 2;
    final state = Event.EndpointState.CREATED;
    final address = 'someone@somewhere';
    final addressType = 'email';

    Event.EndpointChange testEvent =
        new Event.EndpointChange(cid, rid, state, address, addressType);

    Event.EndpointChange builtEvent =
        new Event.Event.parse(testEvent.asMap) as Event.EndpointChange;

    expect(builtEvent.contactID, equals(cid));
    expect(builtEvent.receptionID, equals(rid));
    expect(builtEvent.state, equals(state));
    expect(builtEvent.address, equals(address));
    expect(builtEvent.addressType, equals(addressType));
  }

  static void contactChangeState() {
    final int cid = 1;
    final state = Event.ContactState.CREATED;

    Event.ContactChange testEvent = new Event.ContactChange(cid, state);

    Event.ContactChange builtEvent =
        new Event.Event.parse(testEvent.asMap) as Event.ContactChange;

    expect(builtEvent.contactID, equals(cid));
    expect(builtEvent.state, equals(state));
  }

  static void organizationChangeState() {
    final int oid = 1;
    final state = Event.OrganizationState.CREATED;

    Event.OrganizationChange testEvent =
        new Event.OrganizationChange(oid, state);

    Event.OrganizationChange builtEvent =
        new Event.Event.parse(testEvent.asMap) as Event.OrganizationChange;

    expect(builtEvent.orgID, equals(oid));
    expect(builtEvent.state, equals(state));
  }

  static void receptionChangeState() {
    final int rid = 1;
    final state = Event.ReceptionState.CREATED;

    Event.ReceptionChange testEvent = new Event.ReceptionChange(rid, state);

    Event.ReceptionChange builtEvent =
        new Event.Event.parse(testEvent.asMap) as Event.ReceptionChange;

    expect(builtEvent.receptionID, equals(rid));
    expect(builtEvent.state, equals(state));
  }

  static void receptionContactChangeState() {
    final int cid = 1;
    final int rid = 2;
    final state = Event.ReceptionContactState.CREATED;

    Event.ReceptionContactChange testEvent =
        new Event.ReceptionContactChange(cid, rid, state);

    Event.ReceptionContactChange builtEvent =
        new Event.Event.parse(testEvent.asMap) as Event.ReceptionContactChange;

    expect(builtEvent.contactID, equals(cid));
    expect(builtEvent.receptionID, equals(rid));
    expect(builtEvent.state, equals(state));
  }

  static void messageChangeState() {
    final int mid = 1;
    final int uid = 2;

    Event.MessageChange testEvent = new Event.MessageChange.created(mid, uid);

    Event.MessageChange builtEvent =
        new Event.Event.parse(testEvent.asMap) as Event.MessageChange;

    expect(builtEvent.messageID, equals(mid));
    expect(builtEvent.userID, equals(uid));
    expect(builtEvent.state, equals(Event.MessageChangeState.CREATED));
  }

  static void calendarEntryState() {
    final int id = 1;
    final int rid = 2;
    final int cid = 3;
    final state = Event.CalendarEntryState.CREATED;

    Event.CalendarChange testEvent =
        new Event.CalendarChange(id, cid, rid, state);

    Event.CalendarChange builtEvent =
        new Event.Event.parse(testEvent.asMap) as Event.CalendarChange;

    expect(builtEvent.contactID, equals(cid));
    expect(builtEvent.receptionID, equals(rid));
    expect(builtEvent.entryID, equals(id));
    expect(builtEvent.state, equals(state));
  }

  static void userChange() {
    final int userID = 1234;

    Event.UserChange createEvent = new Event.UserChange.created(userID);
    Event.UserChange updateEvent = new Event.UserChange.updated(userID);
    Event.UserChange removeEvent = new Event.UserChange.deleted(userID);

    Event.UserChange builtEvent =
        new Event.Event.parse(createEvent.asMap) as Event.UserChange;

    expect(builtEvent.userID, equals(userID));
    expect(builtEvent.state, equals(Event.UserObjectState.CREATED));

    builtEvent = new Event.Event.parse(updateEvent.asMap) as Event.UserChange;

    expect(builtEvent.userID, equals(userID));
    expect(builtEvent.state, equals(Event.UserObjectState.UPDATED));

    builtEvent = new Event.Event.parse(removeEvent.asMap) as Event.UserChange;

    expect(builtEvent.userID, equals(userID));
    expect(builtEvent.state, equals(Event.UserObjectState.DELETED));
  }

  static void callStateReload() {
    Event.CallStateReload testEvent = new Event.CallStateReload();

    Event.CallStateReload builtEvent =
        new Event.Event.parse(testEvent.asMap) as Event.CallStateReload;

    expect(
        builtEvent.timestamp
            .difference(testEvent.timestamp)
            .inMilliseconds
            .abs(),
        lessThan(1000));
    expect(builtEvent.eventName, equals(Event.Key.callStateReload));
    expect(builtEvent.eventName, testEvent.eventName);
  }

  static void callHangup() {
    Model.Call testCall = new Model.Call.empty('test-id');

    Event.CallHangup testEvent =
        new Event.CallHangup(testCall, hangupCause: 'no-reason');

    Event.CallHangup builtEvent =
        new Event.Event.parse(testEvent.toJson()) as Event.CallHangup;

    expect(
        builtEvent.timestamp
            .difference(testEvent.timestamp)
            .abs()
            .inMilliseconds,
        lessThan(1));
    expect(builtEvent.eventName, equals(Event.Key.callHangup));
    expect(builtEvent.hangupCause, equals(testEvent.hangupCause));
    expect(builtEvent.eventName, testEvent.eventName);
  }
}
