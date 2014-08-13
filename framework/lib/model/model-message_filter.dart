part of openreception.model;

class InvalidState implements Exception {
  String _state;
  InvalidState (this._state);
}


abstract class MessageState {

  static const Saved   = 'Saved';
  static const Sent    = 'Sent';
  static const Pending = 'Pending';

  static List<String> validStates = [Saved, Sent, Pending];

  static String ofMessage (Message message) {
    if (message.enqueued) {
      return Pending;
    } else if (message.sent) {
      return Sent;
    } else if (!message.sent && ! message.enqueued){
      return Saved;
    } else {
      return null;
    }
  }
}

class MessageFilter {
  String    _messageState  = null;

  int    upperMessageID = Message.noID;
  int    userID         = null;
  int    receptionID    = null;
  int    contactID      = null;

  MessageFilter.empty();

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


  bool appliesTo (Message message) => [message.context.contactID, null].contains(this.contactID) &&
                                      [message.context.receptionID, null].contains(this.receptionID) &&
                                      [message._sender.ID, null].contains(this.userID) &&
                                      [MessageState.ofMessage(message), null].contains(this.contactID);

  List<Message> filter (List<Message> messages) => messages.where((Message message) => this.appliesTo (message));

  @override
  operator == (MessageFilter other) =>
      this.messageState == other.messageState &&
      this.userID       == other.userID &&
      this.receptionID  == other.receptionID &&
      this.contactID    == other.contactID;


  Map get asMap {
    Map retval = {};

    if (this.userID != null) {
      retval['user_id'] = this.userID;
    }

    if (this.messageState != null) {
      retval['state'] = this.messageState;
    }

    if (this.receptionID != null) {
      retval['reception_id'] = this.receptionID;
    }

    if (this.contactID != null) {
      retval['contact_id'] = this.contactID;
    }

    return retval;
  }

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