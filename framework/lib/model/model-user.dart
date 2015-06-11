part of openreception.model;

abstract class UserKey {
  static const String address = 'address';
  static const String groups = 'groups';
  static const String id = 'id';
  static const String identites = 'identites';
  static const String name = 'name';
  static const String extension = 'extension';
}

/**
 *
 */
class User {
  String           address;
  List<String>     groups;
  int              ID;
  List<String>     identities;
  String           name;
  static const int noID      = 0;
  String           peer;
  String           portrait = '';

  /**
   * Constructor for creating an empty object.
   */
  User.empty();

  /**
   * Constructor.
   */
  User.fromMap(Map userMap) {
    address    = userMap[UserKey.address];
    groups     = userMap[UserKey.groups];
    ID         = userMap[UserKey.id];
    identities = userMap[UserKey.identites];
    name       = userMap[UserKey.name];
    peer       = userMap[UserKey.extension];

    if(userMap.containsKey('remote_attributes')) {
      if((userMap['remote_attributes'] as Map).containsKey('picture')) {
        portrait = userMap['remote_attributes']['picture'];
      }
    }
  }

  /**
   *
   */
  Map get asSender => {'name'   : name,
                       'id'     : ID,
                       'address': address};

  /**
   *
   */
  Map get asMap => {
    UserKey.id        : ID,
    UserKey.name      : name,
    UserKey.address   : address,
    UserKey.groups    : groups,
    UserKey.identites : identities,
    UserKey.extension : peer

  };

  Map toJson() => this.asMap;

  /**
   *
   */
  bool inAnyGroups(List<String> groupNames) => groupNames.any(groups.contains);
}
