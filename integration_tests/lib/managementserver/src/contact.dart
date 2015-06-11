part of or_test_fw;

class Contact {
  static Transport.Client client;
  static Storage.Contact contactStore;

  static Future getContact() {
    const int contactId = 1;

    return contactStore.get(contactId).then((Model.BaseContact contact) {
      expect(contact.id, equals(contactId));
      expect(contact.fullName, isNotEmpty);
    });
  }

  static Future getNonExistingContact() {
    const int organizationId = 999999999;
    return contactStore.get(organizationId).then((Model.BaseContact contact) {
      fail('This should have returned a NOT FOUND');
    }).catchError((error) {
      expect(error, new isInstanceOf<Storage.NotFound>());
    });
  }

  static Future getContactList() {
    return contactStore.list().then((Iterable<Model.BaseContact> contacts) {
      expect(contacts, isNotNull);
      contacts.forEach((c) => expect(c.id, greaterThanOrEqualTo(1)));
    });
  }

  static Future updateContact() {
    const String full_name = '..Test-Create Mandela A/S';
    const String contactType = 'human';

    Model.BaseContact contact = new Model.BaseContact.empty()
      ..fullName = full_name
      ..contactType = contactType
      ..enabled = false;

    return contactStore.create(contact).then((Model.BaseContact newContact) {
      expect(newContact, isNotNull);
      String originale_full_name = newContact.fullName;
      String new_full_name = 'Test-Update ${originale_full_name}';
      newContact.fullName = new_full_name;

      return contactStore.update(newContact).then((Model.BaseContact updatedContact) {
        expect(updatedContact.fullName, equals(new_full_name));
        return contactStore.remove(updatedContact);
      });
    });
  }

  static Future createContact() {
    const String full_name = '..Test-Create Mandela A/S';
    const String contactType = 'human';

    Model.BaseContact contact = new Model.BaseContact.empty()
      ..fullName = full_name
      ..contactType = contactType
      ..enabled = false;

    return contactStore.create(contact).then((Model.BaseContact newContact) {
      expect(newContact.id, greaterThanOrEqualTo(1));
      expect(newContact.fullName, equals(full_name));

      //Clean up.
      return contactStore.remove(newContact).then((Model.BaseContact removeContact) {
        expect(removeContact.id, greaterThanOrEqualTo(1));
        expect(removeContact.fullName, equals(full_name));
      });
    });
  }
}