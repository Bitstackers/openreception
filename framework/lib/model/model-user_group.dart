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
  UserGroup.empty();

  /**
   *
   */
  UserGroup.fromMap(Map map) {
    id   = map['id'];
    name = map['name'];
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