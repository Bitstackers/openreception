/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.model;

/**
 *
 */

class DistributionList extends IterableBase<MessageRecipient>{

  static const String className = '${libraryName}.RecipientList';
  static final Logger log = new Logger(className);

  Iterator get iterator => this.asSet.iterator;

  Map<String, List<MessageRecipient>> recipients = {};

  Set<MessageRecipient> get to => recipients[Role.TO].toSet();
  Set<MessageRecipient> get cc => recipients[Role.CC].toSet();
  Set<MessageRecipient> get bcc => recipients[Role.BCC].toSet();

  Set<MessageRecipient> get allRecipients =>
      new Set()
        .union(to)
        .union(cc)
        .union(bcc);

  Map<String, List<Map>> get asMap =>
      {
        Role.TO  : recipients[Role.TO].map((MessageRecipient recipient) => recipient.asMap).toList(),
        Role.CC  : recipients[Role.CC].map((MessageRecipient recipient) => recipient.asMap).toList(),
        Role.BCC : recipients[Role.BCC].map((MessageRecipient recipient) => recipient.asMap).toList()
      };

  Set<MessageRecipient> get asSet {
    Set<MessageRecipient> set = new Set<MessageRecipient>();

    this.recipients.values.forEach((List<MessageRecipient> list) {
      set.addAll(list);
    });

    return set;
  }

  Map toJson() => this.asMap;

  bool get hasRecipients => this.recipients[Role.TO].isNotEmpty ||
                            this.recipients[Role.CC].isNotEmpty ||
                            this.recipients[Role.BCC].isNotEmpty;

  factory DistributionList.empty() {
    return new DistributionList._internal()..recipients = {
          Role.BCC: [],
          Role.CC: [],
          Role.TO: []
        };
  }

  DistributionList._internal();

  /**
   * Initializes a new object using a list of the form :
   *
   *     [{String role, int contact_id,   String contact_name,
   *                    int reception_id, String reception_name,
   *         (optional) endpoint[] } ... ]
   */
  DistributionList.fromlist(List<Map> list) {

    /// Initialize the internal object.
    this.recipients = {
      Role.BCC: [],
      Role.CC: [],
      Role.TO: []
    };

    list.forEach((Map map) {
      Map tmp = {'contact'  : {'id'   : map['contact_id'],
                               'name' : map['contact_name']},
                 'reception': {'id'   : map['reception_id'],
                               'name' : map['reception_name']}};

      MessageRecipient newRecipient;
      newRecipient= new MessageRecipient.fromMap(tmp, role : map['recipient_role']);

      if (map.containsKey('endpoints') && map['endpoints'] != null) {
        newRecipient.endpoints.addAll(map['endpoints'].map((Map endpointsMap) =>
           new MessageEndpoint.fromMap(endpointsMap)..recipient = newRecipient));
      }

      this.add(newRecipient);
    });
  }

  /**
   * Initializes a new object using a map of the form :
   *
   *  { List<Recipients> toRecipients,
   *    List<Recipients> ccRecipients,
   *    List<Recipients> bccRecipients}
   */
  DistributionList.fromMap(Map map) {

    /// Initialize the internal object.
    this.recipients = {
      Role.BCC: [],
      Role.CC: [],
      Role.TO: []
    };

    // Harvest each field for recipients.
    [Role.BCC, Role.CC, Role.TO].forEach((String role) {
      if (map[role] is List && map[role] != null) {
        map[role].forEach((Map contact) => this.add(new MessageRecipient.fromMap(contact, role : role)));
      }
    });
  }

  static DistributionList decode (Map map) =>
    new DistributionList.fromMap(map);

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

    /// Skip adding duplicated recipients.
    if (!(contact.role is String)) {
      log.warning('Skipping bad contact $contact');
      return;
    }

    /// Skip adding duplicated recipients.
    if (this.recipients[contact.role].contains(contact)) {
      log.fine('Skipping duplicated contact $contact (${contact.role}) ');
      return;
    }

    if (contact.role.toLowerCase() == Role.TO) {
      if (this.recipients[Role.CC].contains(contact)) {
        this.replaceRole(Role.CC, Role.TO, contact);
      } else if (this.recipients[Role.BCC].contains(contact)) {
        this.replaceRole(Role.BCC, Role.TO, contact);
      } else {
        this.recipients[contact.role].add(contact);
      }
    } else if (contact.role.toLowerCase() == Role.CC) {
      if (this.recipients[Role.BCC].contains(contact)) {
        this.replaceRole(Role.BCC, Role.CC, contact);
      } else {
        this.recipients[contact.role].add(contact);
      }
    } else if (contact.role.toLowerCase() == Role.BCC) {
      this.recipients[contact.role].add(contact);
    }
  }

  void replaceRole(String oldRole, String newRole, contact) {
    log.finest('Replacing role $oldRole with $newRole in contact $contact');
    this.recipients[oldRole].remove(contact);
    this.recipients[newRole].add(contact);
  }
}
