part of model;

class Organization {
  int id;
  String full_name;
  String bill_type;
  String flag;

  Organization();

  factory Organization.fromJson(Map json) {
    Organization object = new Organization();
    object.id = json['id'];
    object.full_name = json['full_name'];
    object.bill_type = json['bill_type'];
    object.flag = json['flag'];

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
}
