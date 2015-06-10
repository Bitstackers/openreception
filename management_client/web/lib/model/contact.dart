part of model;

class Contact implements Comparable<Contact> {
  bool   enabled;
  int    id;
  String fullName;
  String type;
  Map<int, ContactAttribute> attributes = new Map<int, ContactAttribute>();

  Contact();

  Contact.fromJson(Map json) {
    id        = json[ORF.ContactJSONKey.contactID];
    fullName  = json[ORF.ContactJSONKey.fullName];
    enabled   = json[ORF.ContactJSONKey.enabled];
    type      = json[ORF.ContactJSONKey.contactType];

    List attributes = json['attributes'] as List;
    if(attributes != null) {
      attributes.forEach((Map attributeMap) {
        ContactAttribute attribute = new ContactAttribute.fromJson(attributeMap);
        attributes[attribute.receptionId] = attribute;
      });
    }
  }

  Map toJson() => {
    ORF.ContactJSONKey.contactID: id,
    ORF.ContactJSONKey.fullName: fullName,
    ORF.ContactJSONKey.enabled: enabled,
    ORF.ContactJSONKey.contactType: type
  };

  @override
  int compareTo(Contact other) => this.fullName.compareTo(other.fullName);
}
