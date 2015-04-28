part of controller;

class Contact {

  final ORService.RESTContactStore _store;

  Contact (this._store);

  Future<Iterable<Model.ContactCalendarEntry>>
  getCalendar(Model.Contact contact) =>
    this._store.calendarMap(contact.ID, contact.receptionID)
      .then((Iterable<Map> collection) =>
        collection.map((Map map) =>
            new Model.ContactCalendarEntry.fromMap(map)));

  Future<Iterable<Model.Contact>> list(Model.Reception reception) =>
    this._store.listByReception(reception.ID)
      .then((Iterable<ORModel.Contact> contacts) =>
        contacts.map((ORModel.Contact contact) =>
          new Model.Contact.fromMap(contact.asMap)));
}
