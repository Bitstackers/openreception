part of controller;

abstract class call  {
  
  static void dial (DiablePhoneNumber number) {
    protocol.originateCallFromPhoneId(number.contactID, number.receptionID, number.phoneID)
      .then((protocol.Response response) {

      event.bus.fire(event.originateCallRequest, number);

      if (response.status == protocol.Response.OK) {
         event.bus.fire(event.originateCallRequestSuccess, true);
      } else {
        event.bus.fire(event.originateCallRequestSuccess, false);
      }
      
    }).catchError((error) {
      event.bus.fire(event.originateCallRequestSuccess, false);
    });
  }
  
  static dialContact (Contact contact, int phoneID) {
    
    //TODO: Check if the contact's phone list contains the phoneID supplied. Or cast to DialablePhoneNumber later on.
    // Perhaps we should also find a way to store the reception id with the contact.
    
    //TODO: Put into the event stream that a new call was originated.
  }
}