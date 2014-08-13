part of openreception.model;

class MessageContext {

  final String className = libraryName + "MessageContext";

  /* Private fields */
  Map _data;

  /* Getters */
  int    get contactID     => this._data['contact']['id'];
  String get contactName   => this._data['contact']['name'];
  int    get receptionID   => this._data['reception']['id'];
  String get receptionName => this._data['reception']['name'];

  /**
   * Constructor.
   */
  MessageContext.fromMap(Map map) {
    final String context = className + ".fromMap";

    this.._data = map
        ..validate();
  }


  Map get asMap => {
    'contact'   : {
      'id'  : this.contactID,
      'name': this.contactName
    },
    'reception' : {
      'id'  : this.receptionID,
      'name': this.receptionName
    }
  };

  /**
   * TODO: Change contactID and receptionID to use the constants from shared model classes.
   */
  void validate() {
    if (this.contactID   == null || this.contactID   == 0 ||
        this.receptionID == null || this.receptionID == 0) {
      throw new InvalidMessage ('Badly formatted message: ${this.asMap}');
    }
  }

  Map toJson () => this.asMap;

  @override
  int get hashCode {
    return (this.contactString).hashCode;
  }

  @override
  bool operator ==(MessageRecipient other) => this.contactString == other.contactString;

  String get contactString => contactID.toString() + "@" + receptionID.toString();

  @override
  String toString() => '${this.contactString} - ${this.contactName}@${this.receptionName}';

}
