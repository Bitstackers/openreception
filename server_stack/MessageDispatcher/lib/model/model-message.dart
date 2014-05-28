part of model;

abstract class Role {
  static final String TO  = 'to';
  static final String CC  = 'cc';
  static final String BCC = 'bcc';
}

class Message {
  int _ID;
  Set<Messaging_Contact> _recipients = new Set<Messaging_Contact>();
  Map _data;

  int      get ID => _ID;
  String   get contextContactName => this._data['context']['contact']['name'];
  String   get calleeName => this._data['taken_from']['name'];
  String   get calleeCompany => this._data['taken_from']['company'];
  String   get calleePhone => this._data['taken_from']['phone'];
  String   get calleeCellPhone => this._data['taken_from']['cellphone'];
  String   get agentName => this._data['taken_by_agent']['name'];
  String   get agentAddress => this._data['taken_by_agent']['address'];
  bool     get urgent       => (this._data['flags'] as List).contains('urgent');
  DateTime get receivedAt => this._data['created_at'];
  String   get body  => this._data['message'];
  Set<Messaging_Contact> get recipients => this._recipients;
  
  Message(this._ID, [Map this._data]);

  /**
   * TODO: Document.
   */
  
  bool get hasRecipients => !this.recipientMap.isEmpty;
  
  factory Message.stub(int ID) {
    return new Message(ID);
  }

  /**
   * TODO: Throw NotFound exception.
   */
  static Future<Message> loadFromDatabase(int messageID) {
    Message newMessage = new Message.stub(messageID);

    return messageSingle(messageID).then((Map values) {
      newMessage._data = values;

      return messageRecipients(newMessage.ID).then((List recipientMaps) {
        recipientMaps.forEach((Map recipientMap) {

          newMessage.addRecipient(new Messaging_Contact.fromMap(recipientMap, recipientMap['role']));
        });

        return newMessage;

      });
    });
  }

  Map get toMap {
    this._data['recipients'] = this.recipientMap;
    return this._data;
  }
  
  Map get recipientMap {
    Map newMap = {};
    this.recipients.forEach((Messaging_Contact recipient) {
      newMap[recipient.role] = recipient.toMap;
    });

    return newMap;
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
  void addRecipient(Messaging_Contact contact) {
    if (this.recipients.contains(contact)) {
      if (contact.role == "to") {
        if (this.recipients.lookup(contact).role == "cc" || this.recipients.lookup(contact).role == "bcc") {
          logger.debugContext(contact.contactString + " found with role \"" + this.recipients.lookup(contact).role + "\". Replacing with role \"" + contact.role + "\"", "Message.addRecipient");
          // Replace the contact.
          this.recipients.remove(contact);
          this.recipients.add(contact);
        }
      } else if (contact.role == "cc") {
        if (this.recipients.lookup(contact).role == "bcc") {
          logger.debugContext(contact.contactString + " found with role \"" + this.recipients.lookup(contact).role + "\". Replacing with role \"" + contact.role + "\"", "Message.addRecipient");
          // Replace the contact.
          this.recipients.remove(contact);
          this.recipients.add(contact);
        }
      } else {
        logger.debugContext(contact.contactString + " found with role \"" + this.recipients.lookup(contact).role + "\". Refusing to replace with role \"" + contact.role + "\"", "Message.addRecipient");
      }
    } else {
      logger.debugContext(contact.contactString + " not found - inserting with role \"" + contact.role + "\"", "Message.addRecipient");
      this.recipients.add(contact);
    }
  }

  Set<Messaging_Contact> currentRecipients() {
    return this.recipients;
  }

  String sqlRecipients() {
    return currentRecipients().map((Messaging_Contact contact) => "(${contact.contactID}, '${contact.contactName}', ${contact.receptionID}, '${contact.receptionName}', ${this.ID},'${contact.role}')").join(',');
  }

}

class Messaging_Contact {

  final String className = packageName + "Messaging_Contact";

  /* Private fields */
  Map _data;
  
  int _contactID;
  int _receptionID;
  String _contactName;
  String _receptionName;
  String _role;

  /* Getters */
  int    get contactID     => this._data['contact']['id'];
  String get contactName   => this._data['contact']['name'];
  int    get receptionID   => this._data['reception']['id'];
  String get receptionName => this._data['reception']['name'];
  String get role          => this._data['role'];
  String get transport     => this._data['transport'];
  String get address       => this._data['address'];

  /**
   * Constructor.
   */
  Messaging_Contact.fromMap(Map receptionContact, [String role]) {
    final String context = className + ".fromMap";
    
    this._data         = receptionContact;
    this._data['role'] = role;

    
    logger.debugContext(receptionContact.toString(), context);
    try {
      assert(['cc', 'bcc', 'to', null].contains(role.toLowerCase()));
      this._role = role;
      this._contactID = 
      this._receptionID = receptionContact['reception']['id'];
      this._receptionName = receptionContact['reception']['name'];
    } catch (error) {
      logger.errorContext("Failed to parse receptionContact map", context);
      throw error; // Reraise.
    }
  }

  Map get toMap => {
    'transport' : this.transport,
    'address'   : this.address,
    'contact': {
      'id': this.contactID,
      'name': this.contactName
    },
    'reception': {
      'id': this.receptionID,
      'name': this.receptionName
    }
  };

  @override
  int get hashCode {
    return (this.contactString).hashCode;
  }

  @override
  bool operator ==(Messaging_Contact other) {
    return this.contactString == other.contactString 
        && this.transport == other.transport
        && this.address   == other.address;
  }

  String get contactString => contactID.toString() + "@" + receptionID.toString();

  @override
  String toString() => this.contactString + " - " + this.contactName + "@" + this.receptionName;

}
