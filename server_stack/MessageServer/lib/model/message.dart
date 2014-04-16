part of model;

class Message {
  int _ID;
  Set<Messaging_Contact> recipients = new Set<Messaging_Contact>();
  Map _data;
  
  int get ID => _ID;
  
  Message (this._ID, [Map this._data]);
  
  factory Message.stub (int ID) {
    return new Message(ID);
  }
  
  Future<Message> loadFromDatabase() {
    return messageSingle(this.ID).then((Map values) {
      this._data = values;
      
      return messageRecipients(this.ID).then((List recipientMaps) {
        recipientMaps.forEach((Map recipientMap) {
          this.addRecipient(new Messaging_Contact.fromMap(recipientMap, recipientMap['role']));
        });

        return this;
        
      });
    });
  }
  
  Map get toMap {
    this._data['recipients'] = new Map();
    this.recipients.forEach((Messaging_Contact recipient) {
      this._data['recipients'][recipient.role] = recipient.toMap;
    });
    
    return this._data;
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
          logger.debugContext (contact.contactString + " found with role \""  + this.recipients.lookup(contact).role + 
              "\". Replacing with role \"" + contact.role + "\"", "Message.addRecipient");
          // Replace the contact.
          this.recipients.remove(contact);
          this.recipients.add(contact);
        }
      }

      else if (contact.role == "cc") {
        if (this.recipients.lookup(contact).role == "bcc") {
          logger.debugContext (contact.contactString + " found with role \""  + this.recipients.lookup(contact).role + 
              "\". Replacing with role \"" + contact.role + "\"", "Message.addRecipient");
            // Replace the contact.
            this.recipients.remove(contact);
            this.recipients.add(contact);
        }
      }
      else {
        logger.debugContext (contact.contactString + " found with role \""  + this.recipients.lookup(contact).role + 
            "\". Refusing to replace with role \"" + contact.role + "\"", "Message.addRecipient");
      }
    } else {
      logger.debugContext (contact.contactString + " not found - inserting with role \"" + contact.role + "\"", "Message.addRecipient");
     this.recipients.add(contact); 
    }
  }
  
  Set<Messaging_Contact> currentRecipients () {
    return this.recipients;
  }
  
  String sqlRecipients() {
    return currentRecipients ().map((Messaging_Contact contact) => "(${contact.contactID}, '${contact.contactName}', ${contact.receptionID}, '${contact.receptionName}', ${this.ID},'${contact.role}')").join(','); 
  }

}

class Messaging_Contact {
  
  final String className = packageName + "Messaging_Contact"; 
  
  /* Private fields */
  int    _contactID;
  int    _receptionID;
  String _contactName;
  String _receptionName;
  String _role;
  
  /* Getters */
  int    get contactID     => _contactID;
  String get contactName   => _contactName;
  int    get receptionID   => _receptionID;
  String get receptionName => _receptionName;
  String get role          => _role;
  
  /**
   * Constructor.
   */
  Messaging_Contact.fromMap (Map receptionContact, [String role]) {
    
    final String context = className + ".fromMap"; 
    
    logger.debugContext(receptionContact.toString(), context);
    try {
      assert (['cc', 'bcc', 'to', null].contains(role.toLowerCase()));
      this._role          = role;
      this._contactID     = receptionContact['contact']['id'];
      this._contactName   = receptionContact['contact']['name'];
      this._receptionID   = receptionContact['reception']['id'];
      this._receptionName = receptionContact['reception']['name'];
    } catch (error) {
      logger.errorContext("Failed to parse receptionContact map", context);
      throw error; // Reraise.
    }
  }
  
  Map get toMap => {'contact'   : { 'id'   : this.contactID, 
                                    'name' : this.contactName},
                    'reception' : { 'id'   : this.receptionID,
                                    'name' : this.receptionName}};
                                    

  
  @override
  int get hashCode {
    return (this.contactString).hashCode;
  }
  
  @override
  bool operator == (Messaging_Contact other) {
    return this.contactString == other.contactString;
  }
  
  String get contactString => contactID.toString() + "@" + receptionID.toString(); 
  
  @override
  String toString() => this.contactString + " - " + this.contactName + "@" + this.receptionName;
  
}
