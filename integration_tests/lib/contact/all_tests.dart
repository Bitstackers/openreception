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
    test ('List contacts by reception',
        () => ContactStore.listContactsByExistingReception(contactStore));
    test ('List contacts by Non-existing reception',
        () => ContactStore.listContactsByNonExistingReception(contactStore));

    test ('Calendar event listing',
        () => ContactStore.existingContactCalendar(contactStore));
    test ('Calendar event creation',
        () => ContactStore.calendarEntryCreate(contactStore));
    test ('Calendar event update',
        () => ContactStore.calendarEntryUpdate(contactStore));
    test ('Calendar event',
        () => ContactStore.calendarEntryExisting(contactStore));
    test ('Calendar event (non-existing)',
        () => ContactStore.calendarEntryNonExisting(contactStore));
    test ('Calendar event removal',
        () => ContactStore.calendarEntryDelete(contactStore));

    test ('Endpoint listing',
        () => ContactStore.endpoints(contactStore));

    test ('Phone listing',
        () => ContactStore.phones(contactStore));
});
}