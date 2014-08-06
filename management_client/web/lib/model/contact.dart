part of model;

class Contact {
  int id;
  String full_name;
  bool enabled;
  String type;

  Contact();

  factory Contact.fromJson(Map json) {
    Contact object = new Contact()
      ..id = json['id']
      ..full_name = json['full_name']
      ..enabled = json['enabled']
      ..type = json['contact_type'];

    return object;
  }

  Map toJson() {
    Map data = {
      'id': id,
      'full_name': full_name,
      'enabled': enabled,
      'contact_type': type
    };

    return data;
  }

  static int sortByName(Contact a, Contact b) => a.full_name.compareTo(b.full_name);
}
