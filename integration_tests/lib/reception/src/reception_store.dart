part of or_test_fw;

abstract class Reception_Store {

  static Logger log = new Logger('Test.Reception_Store');

  /**
   * Test for the presence of CORS headers.
   */
  static Future isCORSHeadersPresent(HttpClient client) {

    Uri uri = Uri.parse ('${Config.receptionStoreURI}/nonexistingpath');

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
        uri = Resource.Reception.single (Config.receptionStoreURI, 1);
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

    Uri uri = Uri.parse ('${Config.receptionStoreURI}/nonexistingpath');

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

    log.info('Checking server behaviour on an existing reception.');

    return expect(receptionStore.get(1), isNotNull);
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

    Model.CalendarEvent event =
        new Model.CalendarEvent.forReception(receptionID)
         ..beginsAt    = new DateTime.now()
         ..until       = new DateTime.now().add(new Duration(hours: 2))
         ..content     = Randomizer.randomEvent();

    log.info('Creating a calendar event for reception $receptionID.');

    return receptionStore.calendarEventCreate (event)
        .then((Model.CalendarEvent createdEvent) {
          expect(event.content, equals(createdEvent.content));

          // We round to the nearest second, and have to compensate for skew.
          expect(event.startTime.difference(createdEvent.startTime),
              lessThan(new Duration(seconds : 1)));
          expect(event.stopTime.difference(createdEvent.stopTime),
              lessThan(new Duration(seconds : 1)));
          expect(event.receptionID, equals(createdEvent.receptionID));

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
      .then((List <Model.CalendarEvent> events) {

      // Update the last event in list.
      Model.CalendarEvent event = events.last
          ..beginsAt    = new DateTime.now()
          ..until       = new DateTime.now().add(new Duration(hours: 2))
          ..content     = Randomizer.randomEvent();

      log.info('Updating a calendar event for reception $receptionID.');

      return receptionStore.calendarEventUpdate (event)
          .then((Model.CalendarEvent updatedEvent) {
            expect(event.content, equals(updatedEvent.content));
            expect(event.ID, equals(updatedEvent.ID));

            // We round to the nearest second, and have to compensate for skew.
            expect(event.startTime.difference(updatedEvent.startTime),
                lessThan(new Duration(seconds : 1)));
            expect(event.stopTime.difference(updatedEvent.stopTime),
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
        .then ((List<Model.CalendarEvent> events) {
      log.info('Selecting last event in list');
      int eventID = events.last.ID;

      log.info('Fetching last event in list.');
      return receptionStore.calendarEvent(receptionID, eventID)
        .then((Model.CalendarEvent receivedEvent) {
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
}