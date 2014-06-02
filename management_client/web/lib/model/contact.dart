part of model;

class Contact {
  int id;
  String full_name;
  bool enabled;
  String type;

  Contact();

  factory Contact.fromJson(Map json) {
    Contact object = new Contact();
    object.id = json['id'];
    object.full_name = json['full_name'];
    object.enabled = json['enabled'];
    object.type = json['contact_type'];

    return object;
  }

  String toJson() {
    Map data = {
      'id': id,
      'full_name': full_name,
      'enabled': enabled,
      'contact_type': type
    };

    return JSON.encode(data);
  }
}
