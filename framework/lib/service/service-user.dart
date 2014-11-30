part of utilities.service;

abstract class userProtocol {
  static userResource(int userID) => '/user/${userID}';
}

abstract class User {

  static final String className = '${libraryName}.User';

  static HttpClient client = new HttpClient();

}

