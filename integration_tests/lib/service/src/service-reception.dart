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
        .then((HttpClientRequest request) =>
            request.close().then((HttpClientResponse response) {
              if (response.headers['access-control-allow-origin'] == null &&
                  response.headers['Access-Control-Allow-Origin'] == null) {
                fail('No CORS headers on path $uri');
              }
            }))
        .then((_) {
      log.info('Checking CORS headers on an existing URL.');
      uri = Resource.Reception.single(Config.receptionStoreUri, 1);
      return client.getUrl(uri).then((HttpClientRequest request) =>
          request.close().then((HttpClientResponse response) {
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
        .then((HttpClientRequest request) =>
            request.close().then((HttpClientResponse response) {
              if (response.statusCode != 404) {
                fail('Expected to received a 404 on path $uri');
              }
            }))
        .then((_) => log.info('Got expected status code 404.'))
        .whenComplete(() => client.close(force: true));
  }

  /**
       * Test server behaviour when trying to create a new reception.
       *
       * The expected behaviour is that the server should return the created
       * Reception object and send out a ReceptionChange notification.
       */
  static Future createEvent(
      storage.Reception receptionStore, Receptionist receptionist) async {
    model.Reception reception = Randomizer.randomReception();
    reception.organizationId = 1;

    _log.info('Creating a new reception ${reception.toJson()}');

    final ref = await receptionStore.create(reception, receptionist.user);
    final model.Reception createdReception = await receptionStore.get(ref.id);
    //
    //   receptionist.waitFor(eventType: Event.Key.receptionChange)
    //   .then((Event.ReceptionChange event) {
    // expect(event.receptionID, equals(createdReception.ID));
    // expect(event.state, equals(Event.ReceptionState.CREATED));
    //
  }

  /**
       * Test server behaviour when trying to update an reception.
       *
       * The expected behaviour is that the server should return the created
       * Reception object and send out a ReceptionChange notification.
       */
  static Future updateEvent(
      storage.Reception receptionStore, Receptionist receptionist) async {
    // return receptionStore.list().then((Iterable<model.Reception> orgs) {
    //   // Update the last event in list.
    //   model.Reception reception = orgs.last;
    //
    //   _log.info('Got reception ${reception.asMap}');
    //
    //   return receptionStore.update(reception).then(
    //       (model.Reception updatedReception) => receptionist
    //               .waitFor(eventType: Event.Key.receptionChange)
    //               .then((Event.ReceptionChange event) {
    //             expect(event.receptionID, equals(updatedReception.ID));
    //             expect(event.state, equals(Event.ReceptionState.UPDATED));
    //           }));
    //});
  }

  /**
       * Test server behaviour when trying to delete an reception.
       *
       * The expected behaviour is that the server should return the created
       * Reception object and send out a ReceptionChange notification.
       */
  static Future deleteEvent(
      storage.Reception receptionStore, Receptionist receptionist) {
    model.Reception reception = Randomizer.randomReception()
      ..organizationId = 1;

    _log.info('Creating a new reception ${reception.toJson()}');

    // return receptionStore
    //     .create(reception)
    //     .then((model.Reception createdReception) {
    //   return receptionist
    //       .waitFor(eventType: Event.Key.receptionChange)
    //       .then((_) => receptionist.eventStack.clear())
    //       .then((_) => receptionStore.remove(createdReception.ID).then((_) {
    //             return receptionist
    //                 .waitFor(eventType: Event.Key.receptionChange)
    //                 .then((Event.ReceptionChange event) {
    //               expect(event.receptionID, equals(createdReception.ID));
    //               expect(event.state, equals(Event.ReceptionState.DELETED));
    //             });
    //           }));
    // });
  }
}
