part of model;

class User {
  String extension;
  String name;
  int id;
  String sendFrom;

  User();

  factory User.fromJson(Map json) {
    User object = new User();
    object.extension = json['extension'];
    object.name = json['name'];
    object.id = json['id'];
    object.sendFrom = json['send_from'];

    return object;
  }

  Map toJson() {
    Map data = {
      'extension': extension,
      'name': name,
      'id': id,
      'send_from': sendFrom
    };

    return data;
  }
}
