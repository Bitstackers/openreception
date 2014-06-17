part of adaheads_server_model;

class UserIdentity {
  String identity;
  bool send_from;
  int user_id;

  UserIdentity(String this.identity, bool this.send_from, int this.user_id);
}
