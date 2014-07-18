part of model;

class Endpoint {
  int contactId;
  int receptionId;
  String address;
  String addressType;
  bool confidential;
  bool enabled;
  int priority;

  Endpoint();

  factory Endpoint.fromJson(Map json) {
    Endpoint object = new Endpoint();
    object.contactId = json['contact_id'];
    object.receptionId = json['reception_id'];
    object.address = json['address'];
    object.addressType = json['address_type'];
    object.confidential = json['confidential'];
    object.enabled = json['enabled'];
    object.priority = json['priority'];

    return object;
  }

  String toJson() {
    Map data = {
      'contact_id': contactId,
      'reception_id': receptionId,
      'address': address,
      'address_type': addressType,
      'confidential': confidential,
      'enabled': enabled,
      'priority': priority
    };

    return JSON.encode(data);
  }
}
