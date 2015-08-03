part of openreception.model;

/**
 *
 */
class UserIdentity {
  String identity;
  int    userId;

  /**
   *
   */
  UserIdentity.empty();

  /**
   *
   */
  UserIdentity.fromMap(Map map) {
    identity = map['identity'];
    userId   = map['user_id'];
  }

  static UserIdentity decode (Map map) => new UserIdentity.fromMap(map);

  /**
   *
   */
  Map toJson() => {
    'user_id': userId,
    'identity': identity
  };

  /**
   *
   */
  @override
  operator == (UserIdentity other) =>
     this.identity == other.identity && this.userId == other.userId;

}
