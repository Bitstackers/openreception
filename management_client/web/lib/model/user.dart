part of model;

class User implements Comparable<User> {
  String extension;
  int    id;
  String name;
  String sendFrom;

  User();

  User.fromJson(Map json) {
    extension = json['extension'];
    id        = json['id'];
    name      = json['name'];
    sendFrom  = json['send_from'];
  }

  Map toJson() => {
    'extension' : extension,
    'id'        : id,
    'name'      : name,
    'send_from' : sendFrom
  };

  @override
  int compareTo(User other) => this.name.compareTo(other.name);
}
