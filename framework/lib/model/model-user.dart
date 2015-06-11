part of openreception.model;

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
    address    = userMap['address'];
    groups     = userMap['groups'];
    ID         = userMap['id'];
    identities = userMap['identites'];
    name       = userMap['name'];
    peer       = userMap['extension'];

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
  bool inAnyGroups(List<String> groupNames) => groupNames.any(groups.contains);
}
