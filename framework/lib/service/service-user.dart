part of openreception.service;

abstract class userProtocol {
  static userResource(int userID) => '/user/${userID}';
}

abstract class User {

  static final String className = '${libraryName}.User';

  static HTML.HttpClient client = new HttpClient();

}

