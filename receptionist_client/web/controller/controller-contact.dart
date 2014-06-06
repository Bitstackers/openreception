part of controller;

abstract class Contact {
  
  static void change (Model.Contact newContact) {
    Model.Contact.selectedContact = newContact;    
  }
  
}