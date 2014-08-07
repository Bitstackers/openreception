part of model;

class Contact implements Comparable<Contact> {
  bool   enabled;
  int    id;
  String fullName;
  String type;
  Map<int, ContactAttribute> attributes = new Map<int, ContactAttribute>();

  Contact();

  Contact.fromJson(Map json) {
    id        = json['id'];
    fullName  = json['full_name'];
    enabled   = json['enabled'];
    type      = json['contact_type'];

    List attributes = json['attributes'] as List;
    if(attributes != null) {
      attributes.forEach((Map attributeMap) {
        ContactAttribute attribute = new ContactAttribute.fromJson(attributeMap);
        attributes[attribute.receptionId] = attribute;
      });
    }
  }

  Map toJson() => {
    'id': id,
    'full_name': fullName,
    'enabled': enabled,
    'contact_type': type
  };

  @override
  int compareTo(Contact other) => this.fullName.compareTo(other.fullName);
}
