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
    CustomReceptionContact object = new CustomReceptionContact()
      ..contactId = json['contact_id']
      ..fullName = json['full_name']
      ..contactType = json['contact_type']
      ..contactEnabled = json['contact_enabled']
      ..receptionId = json['reception_id']
      ..wantsMessages = json['wants_messages']
      ..attributes = json['attributes']
      ..receptionEnabled = json['reception_enabled'];

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
