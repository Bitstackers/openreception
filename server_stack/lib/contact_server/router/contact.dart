part of contactserver.router;

abstract class Contact{

  static Future<bool> exists({int contactID, int receptionID}) => db.getContact(receptionID, contactID).then((Model.Contact contact) => contact != Model.Contact.nullContact);

}