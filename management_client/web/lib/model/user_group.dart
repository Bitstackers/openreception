part of model;

class UserGroup {
  int id;
  String name;

  UserGroup();

  factory UserGroup.fromJson(Map json) {
    UserGroup object = new UserGroup()
      ..id = json['id']
      ..name = json['name'];

    return object;
  }

  Map toJson() {
    Map data = {
      'id': id,
      'name': name
    };

    return data;
  }
}
