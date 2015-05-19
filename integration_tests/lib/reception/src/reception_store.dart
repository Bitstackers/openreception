part of or_test_fw;

abstract class Reception_Store {

  static Logger log = new Logger('Test.Reception_Store');

  /**
   * Test for the presence of CORS headers.
   */
  static Future isCORSHeadersPresent(HttpClient client) {

    Uri uri = Uri.parse ('${Config.receptionStoreUri}/nonexistingpath');

    log.info('Checking CORS headers on a non-existing URL.');
    return client.getUrl(uri)
      .then((HttpClientRequest request) => request.close()
      .then((HttpClientResponse response) {
        if (response.headers['access-control-allow-origin'] == null &&
            response.headers['Access-Control-Allow-Origin'] == null) {
          fail ('No CORS headers on path $uri');
        }
      }))
      .then ((_) {
        log.info('Checking CORS headers on an existing URL.');
        uri = Resource.Reception.single (Config.receptionStoreUri, 1);
        return client.getUrl(uri)
          .then((HttpClientRequest request) => request.close()
          .then((HttpClientResponse response) {
          if (response.headers['access-control-allow-origin'] == null &&
              response.headers['Access-Control-Allow-Origin'] == null) {
            fail ('No CORS headers on path $uri');
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
  static Future nonExistingPath (HttpClient client) {

    Uri uri = Uri.parse ('${Config.receptionStoreUri}/nonexistingpath?token=${Config.serverToken}');

    log.info('Checking server behaviour on a non-existing path.');

    return client.getUrl(uri)
      .then((HttpClientRequest request) => request.close()
      .then((HttpClientResponse response) {
        if (response.statusCode != 404) {
          fail ('Expected to received a 404 on path $uri');
        }
      }))
      .then((_) => log.info('Got expected status code 404.'))
      .whenComplete(() => client.close(force : true));
  }

  /**
   * Test server behaviour when trying to aquire a reception event object that
   * does not exist.
   *
   * The expected behaviour is that the server should return a Not Found error.
   */
  static void nonExistingReception (Storage.Reception receptionStore) {

    log.info('Checking server behaviour on a non-existing reception.');

    return expect(receptionStore.get(-1),
            throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  /**
   * Test server behaviour when trying to aquire a reception event object that
   * exists.
   *
   * The expected behaviour is that the server should return the
   * Reception object.
   */
  static void existingReception (Storage.Reception receptionStore) {
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
  static Future listReceptions (Storage.Reception receptionStore) {
    log.info('Checking server behaviour on list of receptions.');

    return receptionStore.list().then((List<Model.Reception> receptions) {
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
  static void existingReceptionCalendar (Storage.Reception receptionStore) {
    int receptionID = 1;

    log.info('Looking up calendar list for reception $receptionID.');

    return expect(receptionStore.calendar (receptionID), isNotNull);
  }

  /**
   * Test server behaviour when trying to create a new calendar event object.
   *
   * The expected behaviour is that the server should return the created
   * CalendarEvent object.
   */
  static Future calendarEventCreate (Storage.Reception receptionStore) {

    int receptionID = 1;

    Model.CalendarEntry entry =
        new Model.CalendarEntry.forReception(receptionID)
         ..beginsAt    = new DateTime.now()
         ..until       = new DateTime.now().add(new Duration(hours: 2))
         ..content     = Randomizer.randomEvent();

    log.info('Creating a calendar event for reception $receptionID.');

    return receptionStore.calendarEventCreate (entry)
        .then((Model.CalendarEntry createdEvent) {
          expect(entry.content, equals(createdEvent.content));

          // We round to the nearest second, and have to compensate for skew.
          expect(entry.start.difference(createdEvent.start),
              lessThan(new Duration(seconds : 1)));
          expect(entry.stop.difference(createdEvent.stop),
              lessThan(new Duration(seconds : 1)));
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
  static Future calendarEventUpdate (Storage.Reception receptionStore) {

    int receptionID = 1;

    return receptionStore.calendar(receptionID)
      .then((List <Model.CalendarEntry> entries) {

      // Update the last event in list.
      Model.CalendarEntry event = entries.last
          ..beginsAt    = new DateTime.now()
          ..until       = new DateTime.now().add(new Duration(hours: 2))
          ..content     = Randomizer.randomEvent();

      log.info('Updating a calendar event for reception $receptionID.');

      return receptionStore.calendarEventUpdate (event)
          .then((Model.CalendarEntry updatedEvent) {
            expect(event.content, equals(updatedEvent.content));
            expect(event.ID, equals(updatedEvent.ID));

            // We round to the nearest second, and have to compensate for skew.
            expect(event.start.difference(updatedEvent.start),
                lessThan(new Duration(seconds : 1)));
            expect(event.stop.difference(updatedEvent.stop),
                lessThan(new Duration(seconds : 1)));
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
  static Future calendarEventExisting (Storage.Reception receptionStore) {

    int receptionID = 1;

    log.info('Checking server behaviour on an existing calendar event.');

    log.info('Listing all events');
    return receptionStore.calendar(receptionID)
        .then ((List<Model.CalendarEntry> events) {
      log.info('Selecting last event in list');
      int eventID = events.last.ID;

      log.info('Fetching last event in list.');
      return receptionStore.calendarEvent(receptionID, eventID)
        .then((Model.CalendarEntry receivedEvent) {
          expect (receivedEvent.ID, equals(eventID));
      });
    });
  }

  /**
   * Test server behaviour when trying to aquire a calendar event object that
   * is not existing - or not referenced by the reception passed by parameter.
   *
   * The expected behaviour is that the server should return "Not Found".
   */
  static void calendarEventNonExisting (Storage.Reception receptionStore) {

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
  static Future calendarEventDelete (Storage.Reception receptionStore) {

    int receptionID = 1;

    return receptionStore.calendar(receptionID)
      .then((List <Model.CalendarEntry> events) {

      // Update the last event in list.
      Model.CalendarEntry event = events.last;

      log.info
        ('Got event ${event.asMap} - ${event.contactID}@${event.receptionID}');

      log.info
        ('Deleting last calendar event for reception $receptionID.');

      return receptionStore.calendarEventRemove(event);
    });
  }

  /**
   * Test server behaviour when trying to create a new calendar event object.
   *
   * The expected behaviour is that the server should return the created
   * CalendarEntry object and send out a CalendarEvent notification.
   */
  static Future calendarEntryCreateEvent (Storage.Reception receptionStore,
                                          Receptionist receptionist) {

    int receptionID = 1;

    Model.CalendarEntry event =
        new Model.CalendarEntry.forReception(receptionID)
         ..beginsAt    = new DateTime.now()
         ..until       = new DateTime.now().add(new Duration(hours: 2))
         ..content     = Randomizer.randomEvent();

    log.info('Creating a calendar event for reception $receptionID.');

    return receptionStore.calendarEventCreate(event)
        .then((Model.CalendarEntry createdEvent) {
          expect(event.content, equals(createdEvent.content));

          // We round to the nearest second, and have to compensate for skew.
          expect(event.start.difference(createdEvent.start),
              lessThan(new Duration(seconds : 1)));
          expect(event.stop.difference(createdEvent.stop),
              lessThan(new Duration(seconds : 1)));
          expect(event.receptionID, equals(createdEvent.receptionID));
          expect(event.contactID, equals(createdEvent.contactID));

          return receptionist.waitFor(eventType: Event.Key.CalendarChange)
            .then((Event.CalendarChange event) {
              expect (event.contactID, equals(Model.Contact.noID));
              expect (event.receptionID, equals(receptionID));
              expect (event.entryID, greaterThan(Model.CalendarEntry.noID));
              expect (event.state, equals(Event.CalendarEntryState.CREATED));
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
  static Future calendarEntryUpdateEvent (Storage.Reception receptionStore,
                                          Receptionist receptionist) {

    int receptionID = 1;

    return receptionStore.calendar(receptionID)
      .then((List <Model.CalendarEntry> events) {

      // Update the last event in list.
      Model.CalendarEntry event = events.last
          ..beginsAt    = new DateTime.now()
          ..until       = new DateTime.now().add(new Duration(hours: 2))
          ..content     = Randomizer.randomEvent();

      log.info
        ('Got event ${event.asMap} - ${event.receptionID}');

      log.info
        ('Updating a calendar event for reception $receptionID.');

      return receptionStore.calendarEventUpdate(event)
          .then((Model.CalendarEntry updatedEvent) {
            expect(event.content, equals(updatedEvent.content));
            expect(event.ID, equals(updatedEvent.ID));

            // We round to the nearest second, and have to compensate for skew.
            expect(event.start.difference(updatedEvent.start),
                lessThan(new Duration(seconds : 1)));
            expect(event.stop.difference(updatedEvent.stop),
                lessThan(new Duration(seconds : 1)));
            expect(event.receptionID, equals(updatedEvent.receptionID));
            expect(event.contactID, equals(updatedEvent.contactID));

            return receptionist.waitFor(eventType: Event.Key.CalendarChange)
              .then((Event.CalendarChange event) {
                expect (event.contactID, equals(Model.Contact.noID));
                expect (event.receptionID, equals(receptionID));
                expect (event.entryID, greaterThan(Model.CalendarEntry.noID));
                expect (event.state, equals(Event.CalendarEntryState.UPDATED));
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
  static Future calendarEntryDeleteEvent (Storage.Reception receptionStore,
                                          Receptionist receptionist) {

    int receptionID = 1;

    return receptionStore.calendar(receptionID)
      .then((Iterable <Model.CalendarEntry> events) {

      // Update the last event in list.
      Model.CalendarEntry event = events.last;

      log.info
        ('Got event ${event.asMap} - ${event.receptionID}');

      log.info
        ('Deleting last calendar entry for reception $receptionID.');

      return receptionStore.calendarEventRemove(event).then((_) {
        return receptionist.waitFor(eventType: Event.Key.CalendarChange)
          .then((Event.CalendarChange event) {
            expect (event.contactID, equals(Model.Contact.noID));
            expect (event.receptionID, equals(receptionID));
            expect (event.entryID, greaterThan(Model.CalendarEntry.noID));
            expect (event.state, equals(Event.CalendarEntryState.DELETED));
         });
      });
    });

  }
}