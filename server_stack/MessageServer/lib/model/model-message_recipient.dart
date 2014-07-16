part of model;

class MessageRecipient extends MessageContext {

  final String className = libraryName + "MessageRecipient";

  /* Getters */
  String get role          => this._data['role'];

  /**
   * Constructor.
   */
  MessageRecipient.fromMap(Map map, {String role : null}) : super.fromMap(map) {
    final String context = className + ".fromMap";
    this._data['role'] = role;
  }

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
