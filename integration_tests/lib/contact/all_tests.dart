part of or_test_fw;

runContactTests () {

  group ('RESTContactStore', () {
    Transport.Client transport = null;
    Service.RESTContactStore contactStore = null;

    setUp (() {
      transport = new Transport.Client();
    });

    tearDown (() {
      transport.client.close(force : true);
    });

    test ('CORS headers present',
        () => ContactStore.isCORSHeadersPresent(transport.client));

    test ('Non-existing path',
        () => ContactStore.nonExistingPath(transport.client));

    setUp (() {
      transport = new Transport.Client();
      contactStore = new Service.RESTContactStore
         (Config.contactStoreUri, Config.serverToken, transport);

    });

    tearDown (() {
      contactStore = null;
      transport.client.close(force : true);
    });

    test ('Non-existing contact',
        () => ContactStore.nonExistingContact(contactStore));
    test ('Existing contact',
        () => ContactStore.existingContact(contactStore));
    test ('List contact',
        () => ContactStore.listContacts(contactStore));
    test ('List contacts by reception',
        () => ContactStore.listContactsByExistingReception(contactStore));
    test ('List contacts by Non-existing reception',
        () => ContactStore.listContactsByNonExistingReception(contactStore));

    test ('Calendar event listing',
        () => ContactStore.existingContactCalendar(contactStore));
    test ('Calendar event creation',
        () => ContactStore.calendarEventCreate(contactStore));
    test ('Calendar event update',
        () => ContactStore.calendarEventUpdate(contactStore));
    test ('Calendar event',
        () => ContactStore.calendarEventExisting(contactStore));
    test ('Calendar event (non-existing)',
        () => ContactStore.calendarEventNonExisting(contactStore));
    test ('Calendar event removal',
        () => ContactStore.calendarEventDelete(contactStore));

  });
}