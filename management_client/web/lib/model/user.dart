part of model;

class User {
  String extension;
  String name;
  int id;

  User();

  factory User.fromJson(Map json) {
    User object = new User();
    object.extension = json['extension'];
    object.name = json['name'];
    object.id = json['id'];

    return object;
  }

  Map toJson() {
    Map data = {
      'extension': extension,
      'name': name,
      'id': id
    };

    return data;
  }
}
