part of model;

abstract class MessageConstants {
  static final String TO             = "to";
  static final String CC             = "cc";
  static final String BCC            = "bcc";
  static final String RECIPIENTS     = "recipients";
  static final String TAKEN_BY_AGENT = "taken_by_agent";
  
  static final List<String> RECIPIENT_ROLES = [TO,CC,BCC];
  
}

class Message {
  
  static final String className = libraryName + ".Message";
  
  Map   _map;
  
  Set<Recipient> _recipients = new Set<Recipient>();
  
  Set<Recipient> get recipients => _recipients;
  Map            get takenByAgent {
    if (!this._map.containsKey(MessageConstants.TAKEN_BY_AGENT)) {
      return User.currentUser.identityMap();
    } else {
      this._map[MessageConstants.TAKEN_BY_AGENT];
    }
  }
  
  /**
   * Adds a free-form field to the message object.
   */
  addValue(String key, newField) {
    this._map[key] = newField;
  }
  
  Message.fromMap (Map map) {
    this._map = map;

    _map[MessageConstants.TAKEN_BY_AGENT] = this.takenByAgent;
    
  }
  
  Map get toMap {
    List<Map> toList = new List<Map>();
    List<Map> ccList = new List<Map>();
    List<Map> bccList = new List<Map>();
    
    this.recipients.forEach((recipient) {
      if (recipient.role == MessageConstants.TO) {
        toList.add(recipient.toMap());
      }
      else if (recipient.role == MessageConstants.CC) {
        ccList.add(recipient.toMap());
      }
      else if (recipient.role == MessageConstants.BCC) {
        bccList.add(recipient.toMap());
      }
      else {
        throw new StateError("Bad role for recipient: ${recipient}.");
      }
    });

    this._map[MessageConstants.TO]  = toList;    
    this._map[MessageConstants.CC]  = ccList;    
    this._map[MessageConstants.BCC] = bccList;    
    
    return this._map;
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
  void addRecipient (Recipient contact) {
    if (this._recipients.contains(contact)) {
      if (contact.role == MessageConstants.TO) {
        if (this.recipients.lookup(contact).role == MessageConstants.CC || this.recipients.lookup(contact).role == MessageConstants.BCC) {
          //log.debugContext (contact.ContactString() + " found with role \""  + this.recipients.lookup(contact).role + 
          //  "\". Replacing with role \"" + contact.role + "\"", "Message.addRecipient");
          // Replace the contact.
          this.recipients.remove(contact);
          this.recipients.add(contact);
        }
      }

      else if (contact.role == MessageConstants.CC) {
        if (this.recipients.lookup(contact).role == MessageConstants.BCC) {
          //logger.debugContext (contact.ContactString() + " found with role \""  + this.recipients.lookup(contact).role + 
          //    "\". Replacing with role \"" + contact.role + "\"", "Message.addRecipient");
            // Replace the contact.
            this.recipients.remove(contact);
            this.recipients.add(contact);
        }
      }
      else {
        //logger.debugContext (contact.ContactString() + " found with role \""  + this.recipients.lookup(contact).role + 
        //    "\". Refusing to replace with role \"" + contact.role + "\"", "Message.addRecipient");
      }
    } else {
      //logger.debugContext (contact.ContactString() + " not found - inserting with role \"" + contact.role + "\"", "Message.addRecipient");
     this.recipients.add(contact); 
    }
  }
  
  String recipientListAsString() {
    return this.recipients.map((Recipient contact) => "(${contact.contactID},${contact.receptionID},${this._map['id']},'${contact.role}')").join(','); 
  }

}
