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
  UserIdentity.fromMap(Map json) {
    identity = json['identity'];
    userId   = json['user_id'];
  }

  /**
   *
   */
  Map toJson() => {
    'user_id': userId,
    'identity': identity
  };
}
