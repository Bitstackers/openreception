part of openreception_tests.storage;

abstract class Message {
  static final Logger log = new Logger('$_libraryName.MessageStore');

  /**
   * Test server behaviour when trying to retrieve a non-filtered list of
   * message objects.
   *
   * The expected behaviour is that the server should return a list
   * of message objects.
   */
  static Future list(ServiceAgent sa) async {
    log.info('Listing messages non-filtered.');

    final org = await sa.createsOrganization();
    final rec = await sa.createsReception(org);
    final con = await sa.createsContact();
    await sa.addsContactToReception(con, rec);

    final context = new model.MessageContext.empty()
      ..cid = con.id
      ..rid = rec.id
      ..contactName = con.name
      ..receptionName = rec.name;

    final msg1 = await sa.createsMessage(context);

    {
      final lst = await sa.messageStore.list();
      expect(lst.length, equals(1));

      final fetchedMsg = lst.firstWhere((m) => m.id == msg1.id);

      expect(msg1.toJson(), equals(fetchedMsg.toJson()));
    }
  }

  /**
   * Test server behaviour when trying to retrieve a filtered list of
   * message objects.
   *
   * The expected behaviour is that the server should return a list
   * of message objects - excluding the ones that does not apply to filter.
   */
  static Future listFiltered(ServiceAgent sa) async {
    log.info('Listing messages filtered.');

    final org = await sa.createsOrganization();
    final rec1 = await sa.createsReception(org);
    final rec2 = await sa.createsReception(org);
    final con1 = await sa.createsContact();
    final con2 = await sa.createsContact();
    await sa.addsContactToReception(con1, rec1);
    await sa.addsContactToReception(con2, rec2);

    final context1 = new model.MessageContext.empty()
      ..cid = con1.id
      ..rid = rec1.id
      ..contactName = con1.name
      ..receptionName = rec1.name;

    final context2 = new model.MessageContext.empty()
      ..cid = con2.id
      ..rid = rec2.id
      ..contactName = con2.name
      ..receptionName = rec2.name;

    final msg1 = await sa.createsMessage(context1);
    {
      final lst = await sa.messageStore.list();
      expect(lst.length, equals(1));

      final fetchedMsg = lst.firstWhere((m) => m.id == msg1.id);

      expect(msg1.toJson(), equals(fetchedMsg.toJson()));
    }

    {
      final filter = new model.MessageFilter.empty()..contactId = con1.id;
      log.info('Listing with contactFilter $filter');
      final lst = await sa.messageStore.list(filter: filter);
      expect(lst.length, equals(1));

      final fetchedMsg = lst.firstWhere((m) => m.id == msg1.id);

      expect(msg1.toJson(), equals(fetchedMsg.toJson()));
    }

    final msg2 = await sa.createsMessage(context2);

    {
      final filter = new model.MessageFilter.empty()..contactId = con2.id;
      log.info('Listing with contactFilter $filter');
      final lst = await sa.messageStore.list(filter: filter);
      expect(lst.length, equals(1));
      final fetchedMsg = lst.firstWhere((m) => m.id == msg2.id);

      expect(msg2.toJson(), equals(fetchedMsg.toJson()));
    }

    {
      final filter = new model.MessageFilter.empty()..receptionId = rec1.id;
      log.info('Listing with filter $filter');
      final lst = await sa.messageStore.list(filter: filter);
      expect(lst.length, equals(1));
      final fetchedMsg = lst.firstWhere((m) => m.id == msg1.id);

      expect(msg1.toJson(), equals(fetchedMsg.toJson()));
    }

    {
      final filter = new model.MessageFilter.empty()..receptionId = rec2.id;
      log.info('Listing with filter $filter');
      final lst = await sa.messageStore.list(filter: filter);
      expect(lst.length, equals(1));
      final fetchedMsg = lst.firstWhere((m) => m.id == msg2.id);

      expect(msg2.toJson(), equals(fetchedMsg.toJson()));
    }
  }

  /**
   *
   */
  static Future create(ServiceAgent sa) async {
    log.info('Creating message');

    final org = await sa.createsOrganization();
    final rec = await sa.createsReception(org);
    final con = await sa.createsContact();
    await sa.addsContactToReception(con, rec);

    final context = new model.MessageContext.empty()
      ..cid = con.id
      ..rid = rec.id
      ..contactName = con.name
      ..receptionName = rec.name;

    final created = Randomizer.randomMessage();
    final mRef = await sa.createsMessage(context, msg: created);
    await sa.messageStore.get(mRef.id);
  }

  /**
   *
   */
  static Future remove(ServiceAgent sa) async {
    final org = await sa.createsOrganization();
    final rec = await sa.createsReception(org);
    final con = await sa.createsContact();
    await sa.addsContactToReception(con, rec);

    final context = new model.MessageContext.empty()
      ..cid = con.id
      ..rid = rec.id
      ..contactName = con.name
      ..receptionName = rec.name;

    final msg = await sa.createsMessage(context);
    await sa.messageStore.remove(msg.id, sa.user);

    await expect(sa.messageStore.get(msg.id),
        throwsA(new isInstanceOf<storage.NotFound>()));
  }

  /**
   * Test server behaviour when trying to aquire a message object that
   * exists.
   *
   * The expected behaviour is that the server should return the
   * Reception object.
   */
  static Future get(ServiceAgent sa) async {
    log.info('Getting single message');

    final org = await sa.createsOrganization();
    final rec = await sa.createsReception(org);
    final con = await sa.createsContact();
    await sa.addsContactToReception(con, rec);

    final context = new model.MessageContext.empty()
      ..cid = con.id
      ..rid = rec.id
      ..contactName = con.name
      ..receptionName = rec.name;

    final created = Randomizer.randomMessage();
    final mRef = await sa.createsMessage(context, msg: created);
    final fetched = await sa.messageStore.get(mRef.id);

    expect(fetched.id, greaterThan(model.Message.noId));
    expect(fetched.body, equals(created.body));
    expect(fetched.callerInfo.toJson(), equals(created.callerInfo.toJson()));
    expect(fetched.callId, equals(created.callId));
    expect(fetched.manuallyClosed, equals(created.manuallyClosed));
    expect(fetched.context.toJson(), equals(context.toJson()));
    expect(fetched.createdAt.isBefore(new DateTime.now()), isTrue);
    expect(fetched.createdAt.difference(new DateTime.now()),
        greaterThan(new Duration(seconds: -1)));
    expect(fetched.flag.toJson(), equals(created.flag.toJson()));

    /// TODO: Elaborate this check.
    expect(fetched.recipients, isNotEmpty);
    expect(fetched.sender.toJson(), equals(sa.user.toJson()));
  }

  /**
     * Test server behaviour when trying to aquire a message object that
     * does not exist.
     *
     * The expected behaviour is that the server should return a Not Found error.
     */
  static Future getNotFound(ServiceAgent sa) async {
    log.info('Checking server behaviour on a non-existing message.');

    await expect(
        sa.messageStore.get(-1), throwsA(new isInstanceOf<storage.NotFound>()));
  }

  /**
   *
   */
  static Future update(ServiceAgent sa) async {
    final org = await sa.createsOrganization();
    final rec = await sa.createsReception(org);
    final con = await sa.createsContact();
    await sa.addsContactToReception(con, rec);

    final context = new model.MessageContext.empty()
      ..cid = con.id
      ..rid = rec.id
      ..contactName = con.name
      ..receptionName = rec.name;

    final mRef = await sa.createsMessage(context);

    final newRcps = [
      Randomizer.randomMessageEndpoint(),
      Randomizer.randomMessageEndpoint()
    ].toSet();

    final updated = Randomizer.randomMessage()
      ..id = mRef.id
      ..context = context
      ..sender = sa.user
      ..recipients = newRcps;
    await sa.messageStore.update(updated, sa.user);

    final fetched = await sa.messageStore.get(mRef.id);

    expect(fetched.id, greaterThan(model.Message.noId));
    expect(fetched.body, equals(updated.body));
    expect(fetched.callerInfo.toJson(), equals(updated.callerInfo.toJson()));
    expect(fetched.callId, equals(updated.callId));
    expect(fetched.manuallyClosed, equals(updated.manuallyClosed));
    expect(fetched.context.toJson(), equals(context.toJson()));
    expect(fetched.createdAt.isBefore(new DateTime.now()), isTrue);
    expect(fetched.createdAt.difference(new DateTime.now()),
        greaterThan(new Duration(seconds: -1)));
    expect(fetched.flag.toJson(), equals(updated.flag.toJson()));

    /// TODO: Elaborate this check.
    expect(fetched.recipients, equals(newRcps));
    expect(fetched.sender.toJson(), equals(sa.user.toJson()));
  }
}
