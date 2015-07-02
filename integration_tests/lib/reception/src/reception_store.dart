part of or_test_fw;

abstract class Reception {
  static Logger log = new Logger('Test.Reception_Store');

  /**
   * Test for the presence of CORS headers.
   */
  static Future isCORSHeadersPresent(HttpClient client) {
    Uri uri = Uri.parse('${Config.receptionStoreUri}/nonexistingpath');

    log.info('Checking CORS headers on a non-existing URL.');
    return client
        .getUrl(uri)
        .then((HttpClientRequest request) => request
            .close()
            .then((HttpClientResponse response) {
      if (response.headers['access-control-allow-origin'] == null &&
          response.headers['Access-Control-Allow-Origin'] == null) {
        fail('No CORS headers on path $uri');
      }
    })).then((_) {
      log.info('Checking CORS headers on an existing URL.');
      uri = Resource.Reception.single(Config.receptionStoreUri, 1);
      return client.getUrl(uri).then((HttpClientRequest request) => request
          .close()
          .then((HttpClientResponse response) {
        if (response.headers['access-control-allow-origin'] == null &&
            response.headers['Access-Control-Allow-Origin'] == null) {
          fail('No CORS headers on path $uri');
        }
      }));
    });
  }

  /**
   * Test server behaviour when trying to access a resource not associated with
   * a handler.
   *
   * The expected behaviour is that the server should return a Not Found error.
   */
  static Future nonExistingPath(HttpClient client) {
    Uri uri = Uri.parse(
        '${Config.receptionStoreUri}/nonexistingpath?token=${Config.serverToken}');

    log.info('Checking server behaviour on a non-existing path.');

    return client
        .getUrl(uri)
        .then((HttpClientRequest request) => request
            .close()
            .then((HttpClientResponse response) {
      if (response.statusCode != 404) {
        fail('Expected to received a 404 on path $uri');
      }
    }))
        .then((_) => log.info('Got expected status code 404.'))
        .whenComplete(() => client.close(force: true));
  }

  /**
   * Test server behaviour when trying to aquire a reception event object that
   * does not exist.
   *
   * The expected behaviour is that the server should return a Not Found error.
   */
  static void nonExistingReception(Storage.Reception receptionStore) {
    log.info('Checking server behaviour on a non-existing reception.');

    return expect(
        receptionStore.get(-1), throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  /**
   * Test server behaviour when trying to aquire a reception event object that
   * exists.
   *
   * The expected behaviour is that the server should return the
   * Reception object.
   */
  static void existingReception(Storage.Reception receptionStore) {
    const int receptionID = 1;
    log.info('Checking server behaviour on an existing reception.');

    return expect(receptionStore.get(receptionID), isNotNull);
  }

  /**
   * Test server behaviour when trying to aquire a list of reception objects
   *
   * The expected behaviour is that the server should return a list of
   * Reception objects.
   */
  static Future listReceptions(Storage.Reception receptionStore) {
    log.info('Checking server behaviour on list of receptions.');

    return receptionStore.list().then((Iterable<Model.Reception> receptions) {
      expect(receptions, isNotNull);
      expect(receptions, isNotEmpty);
    });
  }

  /**
   * Test server behaviour when trying to list calendar events associated with
   * a given reception.
   *
   * The expected behaviour is that the server should return a list of
   * CalendarEvent objects.
   */
  static void existingReceptionCalendar(Service.RESTReceptionStore receptionStore) {
    int receptionID = 1;

    log.info('Looking up calendar list for reception $receptionID.');

    return expect(receptionStore.calendar(receptionID), isNotNull);
  }

  /**
   * Test server behaviour when trying to create a new calendar event object.
   *
   * The expected behaviour is that the server should return the created
   * CalendarEvent object.
   */
  static Future calendarEventCreate(Service.RESTReceptionStore receptionStore) {
    int receptionID = 1;

    Model.CalendarEntry entry = new Model.CalendarEntry.reception(receptionID)
      ..beginsAt = new DateTime.now()
      ..until = new DateTime.now().add(new Duration(hours: 2))
      ..content = Randomizer.randomEvent();

    log.info('Creating a calendar event for reception $receptionID.');

    return receptionStore
        .calendarEventCreate(entry)
        .then((Model.CalendarEntry createdEvent) {
      expect(entry.content, equals(createdEvent.content));

      // We round to the nearest second, and have to compensate for skew.
      expect(entry.start.difference(createdEvent.start),
          lessThan(new Duration(seconds: 1)));
      expect(entry.stop.difference(createdEvent.stop),
          lessThan(new Duration(seconds: 1)));
      expect(entry.receptionID, equals(createdEvent.receptionID));
      expect(createdEvent.ID, greaterThan(Model.CalendarEntry.noID));
    });
  }

  /**
   * Test server behaviour when trying to update a calendar event object that
   * exists.
   *
   * The expected behaviour is that the server should return the updated
   * CalendarEvent object.
   */
  static Future calendarEventUpdate(Service.RESTReceptionStore receptionStore) {
    int receptionID = 1;

    return receptionStore
        .calendar(receptionID)
        .then((Iterable<Model.CalendarEntry> entries) {

      // Update the last event in list.
      Model.CalendarEntry event = entries.last
        ..beginsAt = new DateTime.now()
        ..until = new DateTime.now().add(new Duration(hours: 2))
        ..content = Randomizer.randomEvent();

      log.info('Updating a calendar event for reception $receptionID.');

      return receptionStore
          .calendarEventUpdate(event)
          .then((Model.CalendarEntry updatedEvent) {
        expect(event.content, equals(updatedEvent.content));
        expect(event.ID, equals(updatedEvent.ID));

        // We round to the nearest second, and have to compensate for skew.
        expect(event.start.difference(updatedEvent.start),
            lessThan(new Duration(seconds: 1)));
        expect(event.stop.difference(updatedEvent.stop),
            lessThan(new Duration(seconds: 1)));
        expect(event.receptionID, equals(updatedEvent.receptionID));
      });
    });
  }

  /**
   * Test server behaviour when trying to aquire a calendar event object that
   * exists.
   *
   * The expected behaviour is that the server should return the
   * CalendarEvent object.
   */
  static Future calendarEventExisting(Service.RESTReceptionStore receptionStore) {
    int receptionID = 1;

    log.info('Checking server behaviour on an existing calendar event.');

    log.info('Listing all events');
    return receptionStore
        .calendar(receptionID)
        .then((Iterable<Model.CalendarEntry> events) {
      log.info('Selecting last event in list');
      int eventID = events.last.ID;

      log.info('Fetching last event in list.');
      return receptionStore
          .calendarEvent(receptionID, eventID)
          .then((Model.CalendarEntry receivedEvent) {
        expect(receivedEvent.ID, equals(eventID));
      });
    });
  }

  /**
   * Test server behaviour when trying to aquire a calendar event object that
   * is not existing - or not referenced by the reception passed by parameter.
   *
   * The expected behaviour is that the server should return "Not Found".
   */
  static void calendarEventNonExisting(Service.RESTReceptionStore receptionStore) {
    int receptionID = 1;
    int eventID = 0;

    log.info('Checking server behaviour on a non-existing calendar event.');

    return expect(receptionStore.calendarEvent(receptionID, eventID),
        throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  /**
   * Test server behaviour when trying to delete a calendar event object that
   * exists.
   *
   * The expected behaviour is that the server should succeed.
   */
  static Future calendarEventDelete(Service.RESTReceptionStore receptionStore) {
    int receptionID = 1;

    return receptionStore
        .calendar(receptionID)
        .then((Iterable<Model.CalendarEntry> events) {

      // Update the last event in list.
      Model.CalendarEntry event = events.last;

      log.info('Got event ${event.asMap} - ${event.receptionID}');

      log.info('Deleting last calendar event for reception $receptionID.');

      return receptionStore.calendarEventRemove(event).then((_) {
        return expect(receptionStore.calendarEvent(receptionID, event.ID),
            throwsA(new isInstanceOf<Storage.NotFound>()));
      });
    });
  }

  /**
   * Test server behaviour when trying to create a new calendar event object.
   *
   * The expected behaviour is that the server should return the created
   * CalendarEntry object and send out a CalendarEvent notification.
   */
  static Future calendarEntryCreateEvent(
      Service.RESTReceptionStore receptionStore, Receptionist receptionist) {
    int receptionID = 1;

    Model.CalendarEntry event = new Model.CalendarEntry.reception(receptionID)
      ..beginsAt = new DateTime.now()
      ..until = new DateTime.now().add(new Duration(hours: 2))
      ..content = Randomizer.randomEvent();

    log.info('Creating a calendar event for reception $receptionID.');

    return receptionStore
        .calendarEventCreate(event)
        .then((Model.CalendarEntry createdEvent) {
      expect(event.content, equals(createdEvent.content));

      // We round to the nearest second, and have to compensate for skew.
      expect(event.start.difference(createdEvent.start),
          lessThan(new Duration(seconds: 1)));
      expect(event.stop.difference(createdEvent.stop),
          lessThan(new Duration(seconds: 1)));
      expect(event.receptionID, equals(createdEvent.receptionID));
      expect(event.contactID, equals(createdEvent.contactID));

      return receptionist
          .waitFor(eventType: Event.Key.calendarChange)
          .then((Event.CalendarChange event) {
        expect(event.contactID, equals(Model.Contact.noID));
        expect(event.receptionID, equals(receptionID));
        expect(event.entryID, greaterThan(Model.CalendarEntry.noID));
        expect(event.state, equals(Event.CalendarEntryState.CREATED));
      });
    });
  }

  /**
   * Test server behaviour when trying to update a calendar event object that
   * exists.
   *
   * The expected behaviour is that the server should return the updated
   * CalendarEntry object and send out a CalendarEvent notification.
   */
  static Future calendarEntryUpdateEvent(
      Service.RESTReceptionStore receptionStore, Receptionist receptionist) {
    int receptionID = 1;

    return receptionStore
        .calendar(receptionID)
        .then((Iterable<Model.CalendarEntry> events) {

      // Update the last event in list.
      Model.CalendarEntry event = events.last
        ..beginsAt = new DateTime.now()
        ..until = new DateTime.now().add(new Duration(hours: 2))
        ..content = Randomizer.randomEvent();

      log.info('Got event ${event.asMap} - ${event.receptionID}');

      log.info('Updating a calendar event for reception $receptionID.');

      return receptionStore
          .calendarEventUpdate(event)
          .then((Model.CalendarEntry updatedEvent) {
        expect(event.content, equals(updatedEvent.content));
        expect(event.ID, equals(updatedEvent.ID));

        // We round to the nearest second, and have to compensate for skew.
        expect(event.start.difference(updatedEvent.start),
            lessThan(new Duration(seconds: 1)));
        expect(event.stop.difference(updatedEvent.stop),
            lessThan(new Duration(seconds: 1)));
        expect(event.receptionID, equals(updatedEvent.receptionID));
        expect(event.contactID, equals(updatedEvent.contactID));

        return receptionist
            .waitFor(eventType: Event.Key.calendarChange)
            .then((Event.CalendarChange event) {
          expect(event.contactID, equals(Model.Contact.noID));
          expect(event.receptionID, equals(receptionID));
          expect(event.entryID, greaterThan(Model.CalendarEntry.noID));
          expect(event.state, equals(Event.CalendarEntryState.UPDATED));
        });
      });
    });
  }

  /**
   * Test server behaviour when trying to delete a calendar event object that
   * exists.
   *
   * The expected behaviour is that the server should succeed and send out a
   * CalendarChange Notification.
   */
  static Future calendarEntryDeleteEvent(
      Service.RESTReceptionStore receptionStore, Receptionist receptionist) {
    int receptionID = 1;

    return receptionStore
        .calendar(receptionID)
        .then((Iterable<Model.CalendarEntry> events) {

      // Update the last event in list.
      Model.CalendarEntry event = events.last;

      log.info('Got event ${event.asMap} - ${event.receptionID}');

      log.info('Deleting last calendar entry for reception $receptionID.');

      return receptionStore.calendarEventRemove(event).then((_) {
        return receptionist
            .waitFor(eventType: Event.Key.calendarChange)
            .then((Event.CalendarChange event) {
          expect(event.contactID, equals(Model.Contact.noID));
          expect(event.receptionID, equals(receptionID));
          expect(event.entryID, greaterThan(Model.CalendarEntry.noID));
          expect(event.state, equals(Event.CalendarEntryState.DELETED));
        });
      });
    });
  }

  /**
   * Test server behaviour with regards to calendar changes.
   * This function creates an entry and asserts that a change is also present.
   */
  static Future calendarEntryChangeCreate(
      Service.RESTReceptionStore receptionStore) {
    int receptionID = 1;

    Model.CalendarEntry entry = new Model.CalendarEntry.reception(receptionID)
      ..beginsAt = new DateTime.now()
      ..until = new DateTime.now().add(new Duration(hours: 2))
      ..content = Randomizer.randomEvent();

    log.info('Creating a calendar event for reception $receptionID.');

    return receptionStore
        .calendarEventCreate(entry)
        .then((Model.CalendarEntry createdEvent) {
      return receptionStore
          .calendarEntryChanges(createdEvent.ID)
          .then((Iterable<Model.CalendarEntryChange> changes) {
        expect(changes.length, equals(1));
        expect(changes.first.changedAt.millisecondsSinceEpoch,
            lessThan(new DateTime.now().millisecondsSinceEpoch));
        expect(changes.first.userID, isNot(Model.User.noID));
      });
    });
  }

  /**
   * Test server behaviour with regards to calendar changes.
   * This function update an entry and asserts that another change is present.
   */
  static Future calendarEntryChangeUpdate(
      Service.RESTReceptionStore receptionStore) {
    int receptionID = 1;

    return receptionStore
        .calendar(receptionID)
        .then((Iterable<Model.CalendarEntry> entries) {

      // Update the last event in list.
      Model.CalendarEntry entry = entries.last
        ..beginsAt = new DateTime.now()
        ..until = new DateTime.now().add(new Duration(hours: 2))
        ..content = Randomizer.randomEvent();

      int updateCount = -1;

      log.info('Updating a calendar event for reception $receptionID.');

      return receptionStore
          .calendarEntryChanges(entry.ID)
          .then((Iterable<Model.CalendarEntryChange> changes) =>
              updateCount = changes.length)
          .then((_) => receptionStore
              .calendarEventUpdate(entry)
              .then((Model.CalendarEntry updatedEvent) {
        return receptionStore
            .calendarEntryChanges(updatedEvent.ID)
            .then((Iterable<Model.CalendarEntryChange> changes) {
          expect(changes.length, equals(updateCount + 1));
          expect(changes.first.changedAt.millisecondsSinceEpoch,
              lessThan(new DateTime.now().millisecondsSinceEpoch));
          expect(changes.first.userID, isNot(Model.User.noID));
        });
      }));
    });
  }

  /**
   * Test server behaviour with regards to calendar changes.
   * This function removes an entry and asserts that no changes are present.
   */
  static Future calendarEntryChangeDelete(
      Service.RESTReceptionStore receptionStore) {
    int receptionID = 1;

    return receptionStore
        .calendar(receptionID)
        .then((Iterable<Model.CalendarEntry> events) {

      // Update the last event in list.
      Model.CalendarEntry event = events.last;

      log.info(
          'Got event ${event.asMap} - ${event.contactID}@${event.receptionID}');

      log.info(
          'Deleting last (in list) calendar event for reception $receptionID.');

      return receptionStore.calendarEventRemove(event).then((_) {
        return receptionStore
            .calendarEntryChanges(event.ID)
            .then((Iterable<Model.CalendarEntryChange> changes) {
          expect(changes.length, equals(0));

          return expect(receptionStore.calendarEntryLatestChange(event.ID),
              throwsA(new isInstanceOf<Storage.NotFound>()));
        });
      });
    });
  }

  /**
   * Test server behaviour when trying to create a new reception.
   *
   * The expected behaviour is that the server should return the created
   * Reception object.
   *
   * TODO: Cleanup and check creation time is after now().
   */
  static Future create(Storage.Reception receptionStore) {
    Model.Reception reception = Randomizer.randomReception();

    reception.organizationId = 1;

    log.info('Creating a new reception ${reception.asMap}');

    return receptionStore
        .create(reception)
        .then((Model.Reception createdReception) {
      expect(createdReception.ID, greaterThan(Model.Reception.noID));
      expect(reception.addresses, createdReception.addresses);
      expect(reception.alternateNames, createdReception.alternateNames);
      expect(reception.attributes, createdReception.attributes);
      expect(reception.bankingInformation, createdReception.bankingInformation);
      expect(reception.customerTypes, createdReception.customerTypes);
      expect(reception.emailAddresses, createdReception.emailAddresses);
      expect(reception.extension, createdReception.extension);
      expect(reception.extraData, createdReception.extraData);
      expect(reception.fullName, createdReception.fullName);
      expect(reception.greeting, createdReception.greeting);
      expect(reception.handlingInstructions,
          createdReception.handlingInstructions);
      expect(reception.openingHours, createdReception.openingHours);
      expect(reception.otherData, createdReception.otherData);
      expect(reception.product, createdReception.product);
      expect(reception.salesMarketingHandling,
          createdReception.salesMarketingHandling);
      expect(reception.shortGreeting, createdReception.shortGreeting);
      expect(reception.telephoneNumbers, createdReception.telephoneNumbers);
      expect(reception.vatNumbers, createdReception.vatNumbers);
      expect(reception.websites, createdReception.websites);
      expect(reception.fullName, createdReception.fullName);

      return receptionStore.remove(createdReception.ID);
    });
  }

  /**
   * Test server behaviour when trying to update a reception object that
   * do not exists.
   *
   * The expected behaviour is that the server should return Not Found error
   */
  static Future updateNonExisting(Storage.Reception receptionStore) {
    return receptionStore.list().then((Iterable<Model.Reception> orgs) {

      // Update the last event in list.
      Model.Reception reception = orgs.last;
      reception.ID = -1;

      return expect(receptionStore.update(reception),
          throwsA(new isInstanceOf<Storage.NotFound>()));
    });
  }

  /**
   * Test server behaviour when trying to update a reception object that
   * exists but with invalid data.
   *
   * The expected behaviour is that the server should return Server Error
   */
  static Future updateInvalid(Storage.Reception receptionStore) {
    return receptionStore.list().then((Iterable<Model.Reception> orgs) {

      // Update the last event in list.
      Model.Reception reception = orgs.last;
      reception.fullName = null;

      return expect(receptionStore.update(reception),
          throwsA(new isInstanceOf<Storage.ServerError>()));
    });
  }

  /**
   * Test server behaviour when trying to update a reception event object that
   * exists.
   *
   * The expected behaviour is that the server should return the updated
   * Reception object.
   */
  static Future update(Storage.Reception receptionStore) {

    return receptionStore
            .create(Randomizer.randomReception())
            .then((Model.Reception createdReception) {

      log.info('Created reception ${createdReception.asMap}');
      {
        Model.Reception randOrg = Randomizer.randomReception();
        log.info('Updating with info ${randOrg.asMap}');

        randOrg.ID = createdReception.ID;
        randOrg.organizationId = createdReception.organizationId;
        randOrg.lastChecked = createdReception.lastChecked;
        createdReception = randOrg;
      }
      return receptionStore
          .update(createdReception)
          .then((Model.Reception updatedReception) {
        expect(updatedReception.ID, greaterThan(Model.Reception.noID));
        expect(updatedReception.ID, equals(createdReception.ID));
        expect(createdReception.addresses, updatedReception.addresses);
        expect(createdReception.alternateNames, updatedReception.alternateNames);
        expect(createdReception.attributes, updatedReception.attributes);
        expect(
createdReception.bankingInformation, updatedReception.bankingInformation);
        expect(createdReception.customerTypes, updatedReception.customerTypes);
        expect(createdReception.emailAddresses, updatedReception.emailAddresses);
        expect(createdReception.extension, updatedReception.extension);
        expect(createdReception.extraData, updatedReception.extraData);
        expect(createdReception.fullName, updatedReception.fullName);
        expect(createdReception.greeting, updatedReception.greeting);
        expect(createdReception.handlingInstructions,
            updatedReception.handlingInstructions);
        //TODO: Update this one to greaterThan when the resolution of timestamps in the system has increased.
        expect(updatedReception.lastChecked.millisecondsSinceEpoch,
            greaterThanOrEqualTo(createdReception.lastChecked.millisecondsSinceEpoch));
        expect(createdReception.openingHours, updatedReception.openingHours);
        expect(createdReception.otherData, updatedReception.otherData);
        expect(createdReception.product, updatedReception.product);
        expect(createdReception.salesMarketingHandling,
            updatedReception.salesMarketingHandling);
        expect(createdReception.shortGreeting, updatedReception.shortGreeting);
        expect(createdReception.telephoneNumbers, updatedReception.telephoneNumbers);
        expect(createdReception.vatNumbers, updatedReception.vatNumbers);
        expect(createdReception.websites, updatedReception.websites);
        expect(createdReception.fullName, updatedReception.fullName);

        return receptionStore.remove(createdReception.ID);
      });
    });
  }

  /**
   * Test server behaviour when trying to delete an reception that exists.
   *
   * The expected behaviour is that the server should succeed.
   */
  static Future remove(Storage.Reception receptionStore) {
    Model.Reception reception = Randomizer.randomReception()
      ..organizationId = 1;

    log.info('Creating a new reception ${reception.asMap}');

    return receptionStore.create(reception).then(
        (Model.Reception createdReception) => receptionStore
            .remove(createdReception.ID)
            .then((_) {
      return expect(receptionStore.get(reception.ID),
          throwsA(new isInstanceOf<Storage.NotFound>()));
    }));
  }

  /**
   * Test server behaviour when trying to create a new reception.
   *
   * The expected behaviour is that the server should return the created
   * Reception object and send out a ReceptionChange notification.
   */
  static Future createEvent(
      Storage.Reception receptionStore, Receptionist receptionist) {
    Model.Reception reception = Randomizer.randomReception();
    reception.organizationId = 1;

    log.info('Creating a new reception ${reception.asMap}');

    return receptionStore.create(reception).then(
        (Model.Reception createdReception) => receptionist
            .waitFor(eventType: Event.Key.receptionChange)
            .then((Event.ReceptionChange event) {
      expect(event.receptionID, equals(createdReception.ID));
      expect(event.state, equals(Event.ReceptionState.CREATED));
    }));
  }

  /**
   * Test server behaviour when trying to update an reception.
   *
   * The expected behaviour is that the server should return the created
   * Reception object and send out a ReceptionChange notification.
   */
  static Future updateEvent(
      Storage.Reception receptionStore, Receptionist receptionist) {
    return receptionStore.list().then((Iterable<Model.Reception> orgs) {

      // Update the last event in list.
      Model.Reception reception = orgs.last;

      log.info('Got reception ${reception.asMap}');

      return receptionStore.update(reception).then(
          (Model.Reception updatedReception) => receptionist
              .waitFor(eventType: Event.Key.receptionChange)
              .then((Event.ReceptionChange event) {
        expect(event.receptionID, equals(updatedReception.ID));
        expect(event.state, equals(Event.ReceptionState.UPDATED));
      }));
    });
  }

  /**
   * Test server behaviour when trying to delete an reception.
   *
   * The expected behaviour is that the server should return the created
   * Reception object and send out a ReceptionChange notification.
   */
  static Future deleteEvent(
      Storage.Reception receptionStore, Receptionist receptionist) {
    Model.Reception reception = Randomizer.randomReception()
      ..organizationId = 1;

    log.info('Creating a new reception ${reception.asMap}');

    return receptionStore
        .create(reception)
        .then((Model.Reception createdReception) {
      return receptionist
          .waitFor(eventType: Event.Key.receptionChange)
          .then((_) => receptionist.eventStack.clear())
          .then((_) => receptionStore.remove(createdReception.ID).then((_) {
        return receptionist
            .waitFor(eventType: Event.Key.receptionChange)
            .then((Event.ReceptionChange event) {
          expect(event.receptionID, equals(createdReception.ID));
          expect(event.state, equals(Event.ReceptionState.DELETED));
        });
      }));
    });
  }
}
