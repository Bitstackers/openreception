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

part of openreception.framework.test;

void testEvent() {
  group('Event.parse', () {
    test('contactChangeState', EventTests.contactChangeState);
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
  static void contactChangeState() {
    final int cid = 1;

    Event.ContactChange testEvent = new Event.ContactChange.create(cid);

    Event.ContactChange builtEvent =
        new Event.Event.parse(testEvent.toJson()) as Event.ContactChange;

    expect(builtEvent.cid, equals(cid));
    expect(builtEvent.state, equals(Event.Change.created));
  }

  static void organizationChangeState() {
    final int oid = 1;
    final int uid = 3;

    Event.OrganizationChange testEvent =
        new Event.OrganizationChange.create(oid, uid);

    Event.OrganizationChange builtEvent =
        new Event.Event.parse(JSON.decode(JSON.encode(testEvent)));

    expect(builtEvent.oid, equals(oid));
    expect(builtEvent.modifierUid, equals(uid));
    expect(builtEvent.state, equals(Event.Change.created));
  }

  static void receptionChangeState() {
    final int rid = 1;
    final int uid = 3;

    Event.ReceptionChange testEvent =
        new Event.ReceptionChange.create(rid, uid);

    Event.ReceptionChange builtEvent =
        new Event.Event.parse(testEvent.toJson()) as Event.ReceptionChange;

    expect(builtEvent.rid, equals(rid));
    expect(builtEvent.modifierUid, equals(uid));
    expect(builtEvent.state, equals(Event.Change.created));
  }

  static void receptionContactChangeState() {
    final int cid = 1;
    final int rid = 2;
    final int uid = 3;

    Event.ReceptionData testEvent =
        new Event.ReceptionData.create(cid, rid, uid);

    Event.ReceptionData builtEvent =
        new Event.Event.parse(testEvent.toJson()) as Event.ReceptionData;

    expect(builtEvent.cid, equals(cid));
    expect(builtEvent.rid, equals(rid));
    expect(builtEvent.modifierUid, equals(uid));
    expect(builtEvent.state, equals(Event.Change.created));
  }

  static void messageChangeState() {
    final int mid = 1;
    final int uid = 2;
    final DateTime now = new DateTime.now();
    final Model.MessageState state = Model.MessageState.values.last;

    Event.MessageChange testEvent =
        new Event.MessageChange.create(mid, uid, state, now);

    Event.MessageChange builtEvent =
        new Event.Event.parse(testEvent.asMap) as Event.MessageChange;

    expect(builtEvent.mid, equals(mid));
    expect(builtEvent.modifierUid, equals(uid));
    expect(builtEvent.state, equals(Event.Change.created));
    expect(builtEvent.messageState, equals(state));
    expect(builtEvent.timestamp.difference(now).inMilliseconds, equals(0));
  }

  static void calendarEntryState() {
    final int eid = 1;
    final owner = new Model.OwningReception(3);
    final uid = 3;

    Event.CalendarChange testEvent =
        new Event.CalendarChange.create(eid, owner, uid);

    Event.CalendarChange builtEvent =
        new Event.Event.parse(testEvent.toJson()) as Event.CalendarChange;

    expect(builtEvent.owner.toJson(), equals(owner.toJson()));
    expect(builtEvent.eid, equals(eid));
    expect(builtEvent.modifierUid, equals(uid));
    expect(builtEvent.state, equals(Event.Change.created));
  }

  static void userChange() {
    final int userId = 1234;
    final int modifier = 4312;

    Event.UserChange createEvent =
        new Event.UserChange.create(userId, modifier);
    Event.UserChange updateEvent =
        new Event.UserChange.update(userId, modifier);
    Event.UserChange removeEvent =
        new Event.UserChange.delete(userId, modifier);

    Event.UserChange builtEvent =
        new Event.Event.parse(createEvent.toJson()) as Event.UserChange;

    expect(builtEvent.uid, equals(userId));
    expect(builtEvent.modifierUid, equals(modifier));
    expect(builtEvent.state, equals(Event.Change.created));

    builtEvent =
        new Event.Event.parse(updateEvent.toJson()) as Event.UserChange;

    expect(builtEvent.uid, equals(userId));
    expect(builtEvent.modifierUid, equals(modifier));
    expect(builtEvent.state, equals(Event.Change.updated));

    builtEvent =
        new Event.Event.parse(removeEvent.toJson()) as Event.UserChange;

    expect(builtEvent.uid, equals(userId));
    expect(builtEvent.modifierUid, equals(modifier));
    expect(builtEvent.state, equals(Event.Change.deleted));
  }

  static void callStateReload() {
    Event.CallStateReload testEvent = new Event.CallStateReload();

    Event.Event builtEvent =
        new Event.Event.parse(JSON.decode(JSON.encode(testEvent)));

    expect(
        builtEvent.timestamp
            .difference(testEvent.timestamp)
            .inMilliseconds
            .abs(),
        lessThan(1000));
    expect(builtEvent, new isInstanceOf<Event.CallStateReload>());
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
    expect(builtEvent, new isInstanceOf<Event.CallHangup>());
    expect(builtEvent.hangupCause, equals(testEvent.hangupCause));
    expect(builtEvent.eventName, testEvent.eventName);
  }
}
