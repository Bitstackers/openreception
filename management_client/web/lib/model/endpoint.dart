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
    address      = json['address'];
    addressType  = json['address_type'];
    contactId    = json['contact_id'];
    confidential = json['confidential'];
    description  = json['description'];
    enabled      = json['enabled'];
    priority     = json['priority'];
    receptionId  = json['reception_id'];
  }

  Map toJson() => {
    'address'     : address,
    'address_type': addressType,
    'contact_id'  : contactId,
    'confidential': confidential,
    'description' : description,
    'enabled'     : enabled,
    'priority'    : priority,
    'reception_id': receptionId
  };

  @override
  int compareTo(Endpoint other) => this.priority.compareTo(other.priority);
}
