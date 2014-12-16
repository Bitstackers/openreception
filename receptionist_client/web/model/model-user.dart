part of model;

abstract class UserConstants {
  static final String ID   = "id";
  static final String NAME = "name";
}


/**
 * TODO: Write up documentation for this class and refer to wiki page.
 */
abstract class User extends ORModel.User {

  static final className = '${libraryName}.User';

  /* Singleton representing the current user. */
  static ORModel.User _currentUser = null;
  //static User _currentUser = ORModel.User.noUser;

  Map identityMap () {
    return {UserConstants.ID : this.ID, UserConstants.NAME : this.name};
  }

  /*
   * Getter and setters for the singleton user object.
   */
  static ORModel.User get currentUser => _currentUser;
  static              set currentUser (ORModel.User newUser) => _currentUser = newUser;

  /**
   * Null object constructor.
   */
  User._null() : super.fromMap({});

}