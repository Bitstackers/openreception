part of openreception_tests.service;

abstract class RESTMessageStore {
  static const int invalidMessageID = -1;

  static final Logger _log = new Logger('$libraryName.RESTMessageStore');

  /**
   *
   */
  static Future createEvent(ServiceAgent sa) async {
    _log.info('Started createEvent test');

    final nextMessageCreateEvent = (await sa.notifications).firstWhere(
        (e) => e is event.MessageChange && e.state == event.Change.created);
    final org = await sa.createsOrganization();
    final rec = await sa.createsReception(org);
    final con = await sa.createsContact();
    await sa.addsContactToReception(con, rec);

    final context = new model.MessageContext.empty()
      ..cid = con.id
      ..rid = rec.id
      ..contactName = con.name
      ..receptionName = rec.name;

    final createdMessage =
        await sa.updatesMessage(await sa.createsMessage(context));

    final event.MessageChange createEvent =
        await nextMessageCreateEvent.timeout(new Duration(seconds: 3));

    expect(createEvent.mid, equals(createdMessage.id));
    expect(createEvent.timestamp.isBefore(new DateTime.now()), isTrue);
    expect(createEvent.modifierUid, equals(sa.user.id));
  }

  /**
   *
   */
  static Future removeEvent(ServiceAgent sa) async {
    final nextMessageRemoveEvent = (await sa.notifications).firstWhere(
        (e) => e is event.MessageChange && e.state == event.Change.deleted);
    final org = await sa.createsOrganization();
    final rec = await sa.createsReception(org);
    final con = await sa.createsContact();
    await sa.addsContactToReception(con, rec);

    final context = new model.MessageContext.empty()
      ..cid = con.id
      ..rid = rec.id
      ..contactName = con.name
      ..receptionName = rec.name;

    final created = await sa.createsMessage(context);
    await sa.removesMessage(created);

    final event.MessageChange removeEvent =
        await nextMessageRemoveEvent.timeout(new Duration(seconds: 3));

    expect(removeEvent.mid, equals(created.id));
    expect(removeEvent.timestamp.isBefore(new DateTime.now()), isTrue);
    expect(removeEvent.modifierUid, equals(sa.user.id));
  }

  /**
   *
   */
  static Future updateEvent(ServiceAgent sa) async {
    final nextMessageUpdateEvent = (await sa.notifications).firstWhere(
        (e) => e is event.MessageChange && e.state == event.Change.updated);
    final org = await sa.createsOrganization();
    final rec = await sa.createsReception(org);
    final con = await sa.createsContact();
    await sa.addsContactToReception(con, rec);

    final context = new model.MessageContext.empty()
      ..cid = con.id
      ..rid = rec.id
      ..contactName = con.name
      ..receptionName = rec.name;

    final updatedMessage =
        await sa.updatesMessage(await sa.createsMessage(context));

    final event.MessageChange updateEvent =
        await nextMessageUpdateEvent.timeout(new Duration(seconds: 3));

    expect(updateEvent.mid, equals(updatedMessage.id));
    expect(updateEvent.timestamp.isBefore(new DateTime.now()), isTrue);
    expect(updateEvent.modifierUid, equals(sa.user.id));
  }
}
