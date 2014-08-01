part of model;

abstract class MessageState {
  
  static final Saved   = 'Saved';
  static final Sent    = 'Sent';
  static final Pending = 'Pending';
  
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
  
  int    userID         = null;
  int    receptionID    = null;
  int    contactID      = null;
  String state          = null;
  
  static MessageFilter current = new MessageFilter.empty();
  
  static MessageFilter get none => new MessageFilter.empty();
  
  MessageFilter.empty();
  
  Map get asMap {
    Map retval = {};
    
    if (this.userID != null) {
      retval['user_id'] = this.userID;
    }
    
    if (this.state != null) {
      retval['state'] = this.state;
    }

    if (this.receptionID != null) {
      retval['reception_id'] = this.receptionID;
    }

    if (this.contactID != null) {
      retval['contact_id'] = this.contactID;
    }
    
    return retval;
  }

  bool appliesTo (Message message) => [message.context.contact.ID, null].contains(this.contactID) &&
                                      [message.context.reception.ID, null].contains(this.receptionID) &&
                                      [message.takenByAgent, null].contains(this.userID) &&
                                      [MessageState.ofMessage(message), null].contains(this.contactID); 
  
  List<Message> filter (List<Message> messages) => messages.where((Message message) => this.appliesTo (message));
  
  @override
  operator == (MessageFilter other) =>
      this.state       == other.state &&
      this.userID      == other.userID &&
      this.receptionID == other.receptionID &&
      this.contactID   == other.contactID;

}