part of model;

abstract class MessageState {
  
  static final Saved   = 'Saved';
  static final Sent    = 'Sent';
  static final Pending = 'Pending';
  
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

  @override
  operator == (MessageFilter other) =>
      this.state       == other.state &&
      this.userID      == other.userID &&
      this.receptionID == other.receptionID &&
      this.contactID   == other.contactID;

}