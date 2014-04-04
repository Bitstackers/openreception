part of messageserver.database;

class Message {
  int _ID;
  Set<Messaging_Contact> recipients = new Set<Messaging_Contact>();
  
  int get ID => _ID;
  
  Message (int ID) {
    this._ID = ID;
  }
  
  /**
   * Adds a new recipient for the message. The recipient is subject to the following policy:
   *  - Contacts with both the same contact_id and reception_id are considered equal - regardless of their role.
   *  - CC roles _replace_ BCC roles
   *  - To roles _replace_ both BCC roles _and_ CC roles.
   *  The point of this is to avoid sending out the same email twice to the same recipient.
   *  
   * [contact] The new contact to add. See method documentation for adding policy.  
   */
  void addRecipient (Messaging_Contact contact) {
    if (this.recipients.contains(contact)) {
      if (contact.role == "to") {
        if (this.recipients.lookup(contact).role == "cc" || this.recipients.lookup(contact).role == "bcc") {
          logger.debugContext (contact.ContactString() + " found with role \""  + this.recipients.lookup(contact).role + 
              "\". Replacing with role \"" + contact.role + "\"", "Message.addRecipient");
          // Replace the contact.
          this.recipients.remove(contact);
          this.recipients.add(contact);
        }
      }

      else if (contact.role == "cc") {
        if (this.recipients.lookup(contact).role == "bcc") {
          logger.debugContext (contact.ContactString() + " found with role \""  + this.recipients.lookup(contact).role + 
              "\". Replacing with role \"" + contact.role + "\"", "Message.addRecipient");
            // Replace the contact.
            this.recipients.remove(contact);
            this.recipients.add(contact);
        }
      }
      else {
        logger.debugContext (contact.ContactString() + " found with role \""  + this.recipients.lookup(contact).role + 
            "\". Refusing to replace with role \"" + contact.role + "\"", "Message.addRecipient");
      }
    } else {
      logger.debugContext (contact.ContactString() + " not found - inserting with role \"" + contact.role + "\"", "Message.addRecipient");
     this.recipients.add(contact); 
    }
  }
  
  Set<Messaging_Contact> currentRecipients () {
    return this.recipients;
  }
  
  String sqlRecipients() {
    return currentRecipients ().map((Messaging_Contact contact) => "(${contact.contact_ID},${contact.reception_ID},${this.ID},'${contact.role}')").join(','); 
  }

}

class Messaging_Contact {
  int contact_ID;
  int reception_ID;
  String role;
  
  Messaging_Contact (String contact_reception, String role) {
    List<String> split = contact_reception.split('@');
    this.contact_ID = int.parse(split[0]);
    this.reception_ID = int.parse(split[1]);
    this.role = role;
  }
  
  int get hashCode {
    return (this.ContactString()).hashCode;
  }
  
  bool operator == (Messaging_Contact other) {
    return this.ContactString() == other.ContactString();
  }
  
  String ContactString() {
    return contact_ID.toString() + "@" + reception_ID.toString(); 
  }
}
