part of model;

abstract class Role {
  static final String TO             = "to";
  static final String CC             = "cc";
  static final String BCC            = "bcc";
  static final String RECIPIENTS     = "recipients";
  static final String TAKEN_BY_AGENT = "taken_by_agent";

  static final List<String> RECIPIENT_ROLES = [TO,CC,BCC];

}

/**
 *
 */
class Message extends ORModel.Message {

  static final String className = libraryName + ".Message";

  static const int noID = 0;

  static Set<int> selectedMessages = new Set<int>();

  static final EventType<Message> stateChange = new EventType<Message>();

  void clearRecipients() => this.recipients.recipients.clear();

  Message.fromMap(Map map) : super.fromMap(map) {

    this.createdAt = map['created_at'] != null
                     ? new DateTime.fromMillisecondsSinceEpoch(map['created_at']*1000)
                     : null;
  }

  Future saveTMP() => Service.Message.save(this);

  Future sendTMP() => Service.Message.send(this);

}
