part of model;

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


  Map get toMap => {
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
   * TODO: Write up a proper validation function.
   */
  void validate() => null;
  
  Map toJson () => this.toMap;
  
  @override
  int get hashCode {
    return (this.contactString).hashCode;
  }

  @override
  bool operator ==(MessageRecipient other) => this.contactString == other.contactString;

  String get contactString => contactID.toString() + "@" + receptionID.toString();

  @override
  String toString() => this.contactString + " - " + this.contactName + "@" + this.receptionName;

}
