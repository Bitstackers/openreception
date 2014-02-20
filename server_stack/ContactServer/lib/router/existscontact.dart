part of contactserver.router;

Future<bool> existsContact(int contactId, int receptionId) {  
  return db.getContact(receptionId, contactId).then((Map value) => !value.isEmpty);
}