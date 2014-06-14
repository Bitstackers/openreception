part of model;

class UserGroup {
  int id;
  String name;

  UserGroup();

  factory UserGroup.fromJson(Map json) {
    UserGroup object = new UserGroup();
    object.id = json['id'];
    object.name = json['name'];

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
