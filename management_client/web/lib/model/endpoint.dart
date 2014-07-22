part of model;

class Endpoint {
  int contactId;
  int receptionId;
  String address;
  String addressType;
  bool confidential;
  bool enabled;
  int priority;
  String description;

  Endpoint();

  factory Endpoint.fromJson(Map json) {
    Endpoint object = new Endpoint()
      ..contactId = json['contact_id']
      ..receptionId = json['reception_id']
      ..address = json['address']
      ..addressType = json['address_type']
      ..confidential = json['confidential']
      ..enabled = json['enabled']
      ..priority = json['priority']
      ..description = json['description'];

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
      'priority': priority,
      'description': description
    };

    return JSON.encode(data);
  }
}
