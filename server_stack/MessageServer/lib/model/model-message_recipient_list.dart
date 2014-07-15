part of model;

class MessageRecipientList {

  static const String className = '${libraryName}.RecipientList';

  Map<String, List<MessageRecipient>> recipients = {};

  Map get asMap => this.recipients;
  
  Set<MessageRecipient> get asSet {
    Set<MessageRecipient> set = new Set<MessageRecipient>();
    
    this.recipients.values.forEach((List<MessageRecipient> list) {
      set.addAll(list);  
    });
    
    return set;
  }

  Map toJson() => this.asMap;

  bool get hasRecipients => this.recipients[Role.TO].isNotEmpty && this.recipients[Role.CC].isNotEmpty && this.recipients[Role.BCC].isNotEmpty;

  factory MessageRecipientList.empty() {
    return new MessageRecipientList._internal()..recipients = {
          Role.BCC: [],
          Role.CC: [],
          Role.TO: []
        };
  }

  MessageRecipientList._internal();

  MessageRecipientList.fromMap(Map map) {
    const String context = '${className}.fromJson';

    logger.debugContext(map.toString(), context);
    
    /// Initialize the internal object.
    this.recipients = {
      Role.BCC: [],
      Role.CC: [],
      Role.TO: []
    };

    // Harvest each field for recipients.
    [Role.BCC, Role.CC, Role.TO].forEach((String role) {
      logger.debugContext("Adding for role $role", context);
      if (map[role] is List && map[role] != null) {
        map[role].forEach((Map contact) => this.add(new MessageRecipient.fromMap(contact, role : role)));
      }
    });
  }

  /**
   * Adds a new recipient for the message. The recipient is subject to the following policy:
   *  - Contacts with both the same contact_id and reception_id are considered equal - regardless of their role.
   *  - CC roles _replace_ BCC roles
   *  - To roles _replace_ both BCC roles _and_ CC roles.
   *  The point of this is to avoid sending out the same email twice to the same recipient.
   *  
   * [contact] The new contact to add. See method documentation for adding policy.  
   */
  void add(MessageRecipient contact) {

    const String context = '${className}.add';

    /// Skip adding duplicated recipients.
    if (!(contact.role is String)) {
      logger.debugContext('Skipping bad contact $contact', context);
      return;
    }

    /// Skip adding duplicated recipients.
    if (this.recipients[contact.role].contains(contact)) {
      logger.debugContext('Skipping duplicated contact $contact', context);
      return;
    }

    if (contact.role.toLowerCase() == Role.TO) {
      if (this.recipients[Role.CC].contains(contact)) {
        this.replaceRole(Role.CC, Role.TO, contact);
      } else if (this.recipients[Role.BCC].contains(contact)) {
        this.replaceRole(Role.BCC, Role.TO, contact);
      } else {
        logger.debugContext('Adding contact $contact', context);
        this.recipients[contact.role].add(contact);
      }
    } else if (contact.role.toLowerCase() == Role.CC) {
      if (this.recipients[Role.BCC].contains(contact)) {
        this.replaceRole(Role.BCC, Role.CC, contact);
      } else {
        logger.debugContext('Adding contact $contact', context);
        this.recipients[contact.role].add(contact);
      }
    }
  }

  void replaceRole(String oldRole, String newRole, contact) {
    const String context = '${className}.replaceRole';

    logger.debugContext('Replacing contact $contact', context);
    this.recipients[oldRole].remove(contact);
    this.recipients[newRole].add(contact);
  }
}
