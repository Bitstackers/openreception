part of controller;

abstract class call  {
  
  static dialContact (Contact contact, int phoneID) {
    //TODO: Check if the contact's phone list contains the phoneID supplied. Or cast to DialablePhoneNumber later on.
    // Perhaps we should also find a way to store the reception id with the contact.
    
    protocol.originateCallFromPhoneId(contact.id, contact.receptionID, phoneID);
    
    
    //TODO: Put into the event stream that a new call was originated.
  }
}