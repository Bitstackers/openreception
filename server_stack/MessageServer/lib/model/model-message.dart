part of model;

abstract class Role {
  static final String TO = 'to';
  static final String CC = 'cc';
  static final String BCC = 'bcc';
}

class Message {

  static const String className = '${libraryName}.Message';
  static const int noID = 0;

  int                  _ID              = noID;
  MessageRecipientList _recipients      = new MessageRecipientList.empty();
  MessageContext        _messageContext = null;
  List<String>          _flags          = [];
  Map                   _callerInfo     = {};
  DateTime              _createdAt      = null;
  String                _body           = '';
  SharedModel.User      _sender         = null;

  int                  get ID         => _ID;
  SharedModel.User     get sender     => this._sender;
  bool                 get urgent     => this._flags.contains('urgent');
  DateTime             get receivedAt => this._createdAt;
  String               get body       => this._body;
  MessageRecipientList get recipients => this._recipients;
  MessageContext       get context    => this._messageContext;
  List<String>         get flags      => this._flags;
  Map                  get caller     => this._callerInfo;
  
  void set sender (SharedModel.User user) { this._sender = user;}
  
  Message.stub(this._ID); 

  bool get hasRecpients => !this.recipients.hasRecipients;

  Map toJson() => this.asMap;

  /**
   * TODO: Document.
   */
  factory Message.fromMap(Map map) {

    const String context = '${className}.fromMap';

    int ID = (map.containsKey('id') ? map['id'] : noID);
    
    logger.debugContext(map.toString(), context);

    return new Message.stub(ID)
        .._recipients     = new MessageRecipientList.fromMap(map.containsKey('recipients') ? map['recipients'] : new MessageRecipientList.empty())
        .._messageContext = new MessageContext.fromMap(map['context'])
        .._flags          = map['flags']
        .._callerInfo     = map['caller']
        .._body           = map['message']
        ..validate();
  }

  Map get asMap => 
      { 'id'             : this.ID,
        'message'        : this.body,
        'context'        : this._messageContext,
        'taken_by_agent' : this.sender.asSender,
        'caller'         : this._callerInfo,
        'flags'          : this._flags,
        'created_at'     : dateTimeToUnixTimestamp(this._createdAt),
        'recipients'     : this.recipients
      };
  
  /**
   * 
   */
  void validate() => this.body.isEmpty ? throw new StateError("Empty messages field not allowed") : null;

  Future send() => Database.Message.enqueue(this);

  Future save() => Database.Message.save(this).then((Map result) => this._ID = result['id']);

  /**
   * 
   */
  Future<Message> load() {
    return Database.Message.get(this.ID).then((Map map) {
      return Database.Message.recipients(this).then((MessageRecipientList recipients) {
        return this
            //.._recipients = recipients
            .._messageContext = new MessageContext.fromMap(map['context'])
            .._recipients     = recipients
            .._callerInfo     = map['caller']
            .._flags          = map['flags']
            .._body           = map['message']
            .._createdAt      = map['created_at']
            .._sender         = new SharedModel.User.fromMap (map['taken_by_agent'])
            ..validate();

      });
    });
  }


  Set<MessageRecipient> currentRecipients() {
    return this.recipients.asSet;
  }

  String sqlRecipients() {
    return currentRecipients().map((MessageRecipient contact) => "(${contact.contactID}, '${contact.contactName}', ${contact.receptionID}, '${contact.receptionName}', ${this.ID},'${contact.role}')").join(',');
  }
}
