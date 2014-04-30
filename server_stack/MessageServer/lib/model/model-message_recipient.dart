part of model;

class MessageRecipient {

  final String className = libraryName + "MessageRecipient";

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
  MessageRecipient.fromMap(Map receptionContact, [String role]) {
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
    'contact'   : {
      'id'  : this.contactID,
      'name': this.contactName
    },
    'reception' : {
      'id'  : this.receptionID,
      'name': this.receptionName
    }
  };

  @override
  int get hashCode {
    return (this.contactString).hashCode;
  }

  @override
  bool operator ==(MessageRecipient other) {
    return this.contactString == other.contactString 
        && this.transport == other.transport
        && this.address   == other.address;
  }

  String get contactString => contactID.toString() + "@" + receptionID.toString();

  @override
  String toString() => this.contactString + " - " + this.contactName + "@" + this.receptionName;

}
