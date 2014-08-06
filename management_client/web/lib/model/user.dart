part of model;

class User {
  String extension;
  String name;
  int id;
  String sendFrom;

  User();

  factory User.fromJson(Map json) {
    User object = new User()
      ..extension = json['extension']
      ..name = json['name']
      ..id = json['id']
      ..sendFrom = json['send_from'];

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

  static int sortByName(User a, User b) => a.name.compareTo(b.name);
}
