part of model;

class CustomReceptionContact {
  int contactId;
  String fullName;
  String contactType;
  bool contactEnabled;
  int receptionId;
  bool wantsMessages;
  Map attributes;
  bool receptionEnabled;

  CustomReceptionContact();

  factory CustomReceptionContact.fromJson(Map json) {
    CustomReceptionContact object = new CustomReceptionContact();
    object.contactId = json['contact_id'];
    object.fullName = json['full_name'];
    object.contactType = json['contact_type'];
    object.contactEnabled = json['contact_enabled'];
    object.receptionId = json['reception_id'];
    object.wantsMessages = json['wants_messages'];
    object.attributes = json['attributes'];
    object.receptionEnabled = json['reception_enabled'];

    return object;
  }

  String toJson() {
    Map data = {
      'contact_id': contactId,
      'full_name': fullName,
      'contact_type': contactType,
      'contact_enabled': contactEnabled,
      'reception_id': receptionId,
      'wants_messages': wantsMessages,
      'attributes': attributes,
      'reception_enabled': receptionEnabled
    };

    return JSON.encode(data);
  }
}
