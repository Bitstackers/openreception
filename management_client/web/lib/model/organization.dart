part of model;

class Organization {
  int id;
  String full_name;
  String bill_type;
  String flag;

  Organization();

  factory Organization.fromJson(Map json) {
    Organization object = new Organization()
      ..id = json['id']
      ..full_name = json['full_name']
      ..bill_type = json['bill_type']
      ..flag = json['flag'];

    return object;
  }

  Map toJson() {
    Map data = {
      'id': id,
      'full_name': full_name,
      'bill_type': bill_type,
      'flag': flag
    };

    return data;
  }

  static final sortByName = (Organization a, Organization b) => a.full_name.compareTo(b.full_name);
}
