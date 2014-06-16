part of model;

class UserIdentity {
  String identity;
  int userId;

  UserIdentity();

  factory UserIdentity.fromJson(Map json) {
    UserIdentity object = new UserIdentity();
    object.identity = json['identity'];
    object.userId = json['user_id'];

    return object;
  }

  Map toJson() {
    Map data = {
      'user_id': userId,
      'identity': identity
    };

    return data;
  }
}
