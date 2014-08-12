part of openreception.model;

class InvalidState implements Exception {
  String _state;
  InvalidState (this._state);
}

abstract class MessageState {

  static const String Saved   = 'saved';
  static const String Sent    = 'sent';
  static const String  Pending = 'pending';

  static List<String> validStates = [Saved, Sent, Pending];

}

class MessageFilter {
  String    _messageState  = null;

  int    upperMessageID = Message.noID;
  int    userID         = null;
  int    receptionID    = null;
  int    contactID      = null;

  String get messageState  => this._messageState;
  void   set messageState (String newState) {

    if (newState != null) {
      if (!MessageState.validStates.contains(newState.toLowerCase())) {
        print ('is not valid state');
        throw new InvalidState (newState.toLowerCase());
      }

      this._messageState = newState.toLowerCase();
    } else {
      this._messageState = null;
    }
  }

  bool get active => [userID, receptionID, contactID, upperMessageID]
                      .any((int field) => field != null && field != Message.noID)
                      || messageState != null;

  Map get asMap => {
    'state'         : this.messageState,
    'upperMessageID': this.upperMessageID,
    'userID'        : this.userID,
    'receptionID'   : this.receptionID,
    'contactID'     : this.contactID
  };

  List<String> get activeFields {
    List<String> retval = [];

    if (this.upperMessageID != Message.noID) {
      retval.add('message.id <= ${this.upperMessageID}');
    }

    if (userID != null) {
       retval.add('taken_by_agent = ${this.userID}');
    }

    if (receptionID != null) {
       retval.add('context_reception_id = ${this.receptionID}');
    }

    if (contactID != null) {
       retval.add('context_contact_id = ${this.contactID}');
    }

    switch (this._messageState) {
      case MessageState.Pending :
        retval.add('enqueued');
        break;

      case MessageState.Sent :
        retval.add('sent');
        break;

      case MessageState.Saved :
        retval.add('NOT enqueued AND NOT sent');
        break;
    }

    return retval;
  }

  String get asSQL => (this.active ? 'WHERE ${this.activeFields.join(' AND ')}' : '');

}