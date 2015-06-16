part of openreception.model;

/**
 *
 */
class UserGroup {
  int    id;
  String name;

  /**
   *
   */
  UserGroup.fromJson(Map json) {
    id   = json['id'];
    name = json['name'];
  }

  /**
   *
   */
  Map toJson() {
    Map data = {
      'id': id,
      'name': name
    };

    return data;
  }
}

int compareUserGroup (UserGroup g1, UserGroup g2) => g1.name.compareTo(g2.name);