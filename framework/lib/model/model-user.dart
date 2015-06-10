part of openreception.model;

/**
 * TODO: Change this to use fields instead of a map.
 */
class User {

  static const int noID = 0;
  static final String className    = '${libraryName}.User';
  static       User   _currentUser = new User.empty(); // Singleton User
  final        Bus    _idle        = new Bus();
  final        Bus    _pause       = new Bus();

  Map _map = {};
  String       get peer      => this._map['extension'];
  String       get name      => this._map['name'];
  String       get address   => this._map['address'];
  int          get ID        => this._map['id'];
  List<String> get groups    => this._map['groups'];
  List<String> get identites => this._map['identites'];

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

  /**
   * Get the current user.
   */
  static User get currentUser => _currentUser;

  /**
   * Set the current user.
   */
  static set currentUser (User newUser) => _currentUser = newUser;

  /**
   * Fires when [currentUser] goes idle.
   */
  Stream get onIdle => this._idle.stream;

  /**
   * Fires when [currentUser] pauses.
   */
  Stream get onPause => this._pause.stream;

  bool inAnyGroups(List<String> groupNames) => groupNames.any((g) => groups.contains(g));
}
