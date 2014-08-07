part of model;

class UserGroup implements Comparable<UserGroup> {
  int    id;
  String name;

  UserGroup.fromJson(Map json) {
    id   = json['id'];
    name = json['name'];
  }

  Map toJson() {
    Map data = {
      'id': id,
      'name': name
    };

    return data;
  }

  @override
  int compareTo(UserGroup other) => this.name.compareTo(other.name);
}
