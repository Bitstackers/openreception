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

abstract class ContactDefault {
  static get phones => new List<String>();
}

class Contact {
  static const int noID = 0;
  static final Contact noContact = new Contact.empty();
  static const String className = '${libraryName}.Contact';
  static final Logger log = new Logger(Contact.className);

  final StreamController<Event.Event> _streamController =
      new StreamController.broadcast();

  Stream get event => this._streamController.stream;

  static Contact _selectedContact = Contact.noContact;

  static Bus<Contact> _contactChange = new Bus<Contact>();
  static Stream<Contact> get onContactChange => _contactChange.stream;

  static Contact get selectedContact => _selectedContact;
  static set selectedContact(Contact contact) {
    _selectedContact = contact;
    _contactChange.fire(_selectedContact);
  }

  int ID = noID;
  int receptionID = Reception.noID;

  @deprecated
  bool wantsMessage = true;
  bool enabled = true;

  /**
   * Imported flag from old system. Signifies that a user wishes to recieve
   * status emails from us.
   */

  bool statusEmail = true;

  String fullName = '';
  String contactType = '';

  List<PhoneNumber> phones = [];
  List<String> backupContacts = [];
  List<String> messagePrerequisites = [];

  List<String> tags = new List<String>();
  List<String> emailaddresses = new List<String>();
  List<String> handling = new List<String>();
  List<String> workhours = new List<String>();
  List<String> titles = [];
  List<String> responsibilities = [];
  List<String> relations = [];
  List<String> departments = [];
  List<String> infos = [];

  Map get attributes => {
        Key.departments: departments,
        Key.backup: backupContacts,
        Key.emailaddresses: emailaddresses,
        Key.handling: handling,
        Key.workhours: workhours,
        Key.tags: tags,
        Key.infos: infos,
        Key.titles: titles,
        Key.relations: relations,
        Key.responsibilities: responsibilities,
        Key.messagePrerequisites: messagePrerequisites,
        Key.statusEmail: statusEmail
      };

  Map toJson() => this.asMap;

  Map get asMap => {
        Key.contactID: this.ID,
        Key.receptionID: this.receptionID,
        Key.departments: this.departments,
        Key.wantsMessages: this.wantsMessage,
        Key.enabled: this.enabled,
        Key.fullName: this.fullName,
        Key.contactType: this.contactType,
        Key.phones:
            this.phones.map((PhoneNumber p) => p.asMap).toList(growable: false),
        Key.backup: this.backupContacts,
        Key.emailaddresses: this.emailaddresses,
        Key.handling: this.handling,
        Key.workhours: this.workhours,
        Key.tags: this.tags,
        Key.infos: this.infos,
        Key.titles: this.titles,
        Key.relations: this.relations,
        Key.responsibilities: this.responsibilities,
        Key.messagePrerequisites: messagePrerequisites,
        Key.statusEmail: statusEmail
      };

  Contact.fromMap(Map map) {
    /// PhoneNumber deserializing.
    Iterable<Map> phoneMaps = map[Key.phones];
    Iterable<PhoneNumber> phones = phoneMaps.map((Map phoneMap) {
      return new PhoneNumber.fromMap(phoneMap);
    });

    this.phones.addAll(phones.toList());

    this.ID = mapValue(Key.contactID, map);
    this.receptionID = mapValue(Key.receptionID, map);
    this.departments = mapValue(Key.departments, map);
    this.wantsMessage = mapValue(Key.wantsMessages, map);
    this.enabled = mapValue(Key.enabled, map);
    this.fullName = mapValue(Key.fullName, map);
    this.contactType = mapValue(Key.contactType, map);

    this.messagePrerequisites =
        mapValue(Key.messagePrerequisites, map, defaultValue: []);

    this.backupContacts = mapValue(Key.backup, map);
    this.emailaddresses = mapValue(Key.emailaddresses, map);
    this.handling = mapValue(Key.handling, map);
    this.workhours = mapValue(Key.workhours, map);
    this.handling = mapValue(Key.handling, map);
    this.tags = mapValue(Key.tags, map);
    this.infos = mapValue(Key.infos, map);
    this.titles = mapValue(Key.titles, map);
    this.relations = mapValue(Key.relations, map);
    this.responsibilities = mapValue(Key.responsibilities, map);
    this.statusEmail = mapValue(Key.statusEmail, map);
  }

  static dynamic mapValue(String key, Map map, {dynamic defaultValue: null}) {
    if (!map.containsKey(key) && defaultValue == null) {
      throw new StateError('No value for required key "$key"');
    }

    return map.containsKey(key) ? map[key] : defaultValue;
  }

  /**
   * [Contact] as String, for debug/log purposes.
   */
  String toString() => '${this.fullName}-${this.ID}-${this.contactType}';

  /**
   * [Contact] null constructor.
   */
  Contact.empty();

  bool get isEmpty => this.ID == noContact.ID;
  bool get isNotEmpty => this.ID != noContact.ID;
}
