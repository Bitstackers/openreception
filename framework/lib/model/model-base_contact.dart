part of openreception.model;

abstract class Key {
  static const String contactID = 'contact_id';
  static const String fullName = 'full_name';
  static const String contactType = 'contact_type';
  static const String enabled = 'enabled';
}

class BaseContact {
  int id = Contact.noID;
  String fullName = '';
  String contactType = '';
  bool enabled = true;

  BaseContact.empty();

  BaseContact.fromMap(Map map) {
    id = map[Key.contactID];
    fullName = map[Key.fullName];
    contactType = map[Key.contactType];
    enabled = map[Key.enabled];
  }

  Map get asMap => {
    Key.contactID: id,
    Key.fullName: fullName,
    Key.contactType: contactType,
    Key.enabled: enabled
  };

  Map toJson() => this.asMap;
}
