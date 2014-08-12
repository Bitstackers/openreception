part of openreception.model;

abstract class Role {
  static const String TO  = 'to';
  static const String CC  = 'cc';
  static const String BCC = 'bcc';

  static final List<String> RECIPIENT_ROLES = [TO,CC,BCC];
}

class InvalidMessage implements Exception {
  final String message;

  const InvalidMessage(this.message);

  String toString() => message;
}


class Message {

  static const String className = '${libraryName}.Message';
  static const int noID = 0;

  static final Logger log = new Logger(className);

  int                  ID              = noID;
  MessageRecipientList recipients      = new MessageRecipientList.empty();
  MessageContext       _messageContext = null;
  List<String>         _flags          = [];
  Map                  _callerInfo     = {};
  DateTime             _createdAt      = null;
  String               _body           = '';
  User                 _sender         = null;
  bool                 enqueued        = null;
  bool                 sent            = null;

  User                 get sender     => this._sender;
  bool                 get urgent     => this._flags.contains('urgent');
  DateTime             get receivedAt => this._createdAt;
  String               get body       => this._body;
  MessageContext       get context    => this._messageContext;
  List<String>         get flags      => this._flags;
  Map                  get caller     => this._callerInfo;

  List<MessageRecipient> get toRecipients  => this.recipients.where((MessageRecipient recipient) => recipient.role == Role.TO).toList();
  List<MessageRecipient> get ccRecipients  => this.recipients.where((MessageRecipient recipient) => recipient.role == Role.CC).toList();
  List<MessageRecipient> get bccRecipients => this.recipients.where((MessageRecipient recipient) => recipient.role == Role.BCC).toList();

  void set sender (User user) { this._sender = user;}

  Message.stub(this.ID);

  bool hasFlag (String flag) => this.flags.contains(flag);

  bool get hasRecpients => !this.recipients.hasRecipients;

  Map toJson() => this.asMap;

  /**
   * Appends a message flag to the message.
   */
  void addFlag (String newFlag) {
    if (!(this._flags.contains(newFlag))) {
      this._flags.add(newFlag);
    }
  }

  /**
   * TODO: Document.
   */
  factory Message.fromMap(Map map) {

    const String context = '${className}.fromMap';

    int ID = (map.containsKey('id') ? map['id'] : noID);

    /// TODO: figure out a more generic way of decoding different recipient formats.
    MessageRecipientList recipients = null;
    if (!map.containsKey('recipients')) {
      recipients = new MessageRecipientList.empty();
    } else if (map['recipients'] is List) { //This is the format from the database.
      recipients = new MessageRecipientList.fromlist(map['recipients']);
    } else if (map['recipients'] is Map) {
      recipients = new MessageRecipientList.fromMap(map['recipients']);
    } else {
      throw new InvalidMessage('Bad recipient format: ${map['recipients']}');
    }

    return new Message.stub(ID)
        ..recipients      = recipients
        .._messageContext = new MessageContext.fromMap(map['context'])
        .._flags          = map['flags']
        .._createdAt      = map['created_at']
        .._callerInfo     = map['caller']
        .._body           = map['message']
        ..sent            = map['sent']
        ..enqueued        = map['enqueued']
        .._sender         = new User.fromMap(map['taken_by_agent'])
        ..validate();
  }

  Map get asMap =>
      { 'id'             : this.ID,
        'message'        : this.body,
        'context'        : this.context,
        'taken_by_agent' : this.sender.asSender,
        'caller'         : this._callerInfo,
        'flags'          : this._flags,
        'sent'           : this.sent,
        'enqueued'       : this.enqueued,
        'created_at'     : Common.dateTimeToUnixTimestamp(this._createdAt),
        'recipients'     : this.recipients
      };

  /**
   *
   */
  void validate() => this.body.isEmpty
                     ? throw new InvalidMessage("Empty messages field not allowed")
                     : null;

  Future enqueue(Storage.Message messageStore) => messageStore.enqueue(this);

  /**
   * Saves the message in the [messageStore] supplied. Update the [ID] of the message object
   * if it previously had none.
   */
  Future<Message> save(Storage.Message messageStore) => messageStore.save(this);

  /**
   *
   */
  static Future<Message> load(int messageID, Storage.Message messageStore) => messageStore.get(messageID);

  Set<MessageRecipient> currentRecipients() => this.recipients.asSet;

  String sqlRecipients()
    => this.currentRecipients().map((MessageRecipient contact)
        => "(${contact.contactID}, '${contact.contactName}', ${contact.receptionID}, '${contact.receptionName}', ${this.ID},'${contact.role}')").join(',');
}
