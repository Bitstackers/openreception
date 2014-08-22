part of openreception.model;

class User {

  static int nullID = 0;


  Map _map = {};
  String       get peer    => this._map['extension'];
  String       get name    => this._map['name'];
  String       get address => this._map['address'];
  int          get ID      => this._map['id'];
  List<String> get groups  => this._map['groups'];

  static Future<User> load (String identity, Storage.User userStore) => userStore.get (identity);

  Map get asSender =>
      { 'name'    : this.name,
        'id'      : this.ID,
        'address' : this.address
      };

  User.fromMap (Map userMap) {
    this._map = userMap;
  }

  Map toJson() {
    return this._map;
  }

  bool inAnyGroups(List<String> groupNames) => groupNames.any((g) => groups.contains(g));
}
