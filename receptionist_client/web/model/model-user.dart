part of model;

abstract class UserConstants {
  static final String ID   = "id"; 
  static final String NAME = "name"; 
}


/**
 * TODO: Write up documentation for this class and refer to wiki page.
 */
class User implements Comparable {
  
  static final className = '${libraryName}.User';

  int    _ID   = nullUserID;
  String _name = constant.Label.UNKNOWN_AGENT_NAME;

  /* Null definitions. */ 
  static final nullUserID = 0;
  static final nullUser   = new User._null();

  /* Singleton representing the current user. */
  static User _currentUser = nullUser;
  
  User (this._ID, this._name);
  
  Map identityMap () {
    return {UserConstants.ID : this.ID, UserConstants.NAME : this.name};
  }
  
  /*
   * Getter and setters for the singleton user object.
   */
  static User get currentUser => _currentUser;
  static      set currentUser (User newUser)=> _currentUser = newUser; 
  
  /*
   * TODO Document.
   */
  int    get ID   => this._ID;
  String get name => this._name;
  
  /**
   * Any two users with the same ID are equivalent.
   */
  int compareTo(User other) => _ID.compareTo(other._ID);
  
  /**
   * Null object constructor.
   */
  User._null();
  
  
}