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
   * FIXME: Turn value into a Map once the auth server is using the framework
   *   models.
   */
  UserGroup.fromMap(var value) {
    if (value is String) {
      name = value;
    }
    else {
      id   = value['id'];
      name = value['name'];

    }

  }

  static UserGroup decode (var map) => new UserGroup.fromMap(map);

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

  /**
   *
   */
  @override
  operator == (UserGroup other) =>
     this.id == other.id && this.name == other.name;
}

int compareUserGroup (UserGroup g1, UserGroup g2) => g1.name.compareTo(g2.name);