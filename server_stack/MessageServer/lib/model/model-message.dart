part of model;

abstract class Role {
  static final String TO  = 'to';
  static final String CC  = 'cc';
  static final String BCC = 'bcc';
}

class Message {
  int _ID;
  Set<MessageRecipient> _recipients = new Set<MessageRecipient>();
  Map _data;

  int      get ID => _ID;
  String   get contextContactName => this._data['context']['contact']['name'];
  String   get calleeName => this._data['taken_from']['name'];
  String   get calleeCompany => this._data['taken_from']['company'];
  String   get calleePhone => this._data['taken_from']['phone'];
  String   get calleeCellPhone => this._data['taken_from']['cellphone'];
  String   get agentName => this._data['taken_by_agent']['name'];
  String   get agentAddress => this._data['taken_by_agent']['address'];
  bool     get urgent       => this._data['urgent'];
  DateTime get receivedAt => this._data['created_at'];
  String   get body  => this._data['message'];
  Set<MessageRecipient> get recipients => this._recipients;
  
  Message(this._ID, [Map this._data]);

  /**
   * TODO: Document.
   */
  
  bool get hasRecpients => !this.recipientMap.isEmpty;
  
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

          newMessage.addRecipient(new MessageRecipient.fromMap(recipientMap, recipientMap['role']));
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
    this.recipients.forEach((MessageRecipient recipient) {
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
  void addRecipient(MessageRecipient contact) {
    print ('addRecipient $contact');
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

  Set<MessageRecipient> currentRecipients() {
    return this.recipients;
  }

  String sqlRecipients() {
    return currentRecipients().map((MessageRecipient contact) => "(${contact.contactID}, '${contact.contactName}', ${contact.receptionID}, '${contact.receptionName}', ${this.ID},'${contact.role}')").join(',');
  }

}
