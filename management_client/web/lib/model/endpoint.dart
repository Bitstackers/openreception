part of model;

class Endpoint implements Comparable<Endpoint> {
  String address;
  String addressType;
  bool   confidential;
  int    contactId;
  String description;
  bool   enabled;
  int    priority;
  int    receptionId;

  Endpoint();

  Endpoint.fromJson(Map json) {
    contactId    = json['contact_id'];
    receptionId  = json['reception_id'];
    address      = json['address'];
    addressType  = json['address_type'];
    confidential = json['confidential'];
    enabled      = json['enabled'];
    priority     = json['priority'];
    description  = json['description'];
  }

  Map toJson() => {
    'contact_id': contactId,
    'reception_id': receptionId,
    'address': address,
    'address_type': addressType,
    'confidential': confidential,
    'enabled': enabled,
    'priority': priority,
    'description': description
  };

  @override
  int compareTo(Endpoint other) => this.priority.compareTo(other.priority);
}
