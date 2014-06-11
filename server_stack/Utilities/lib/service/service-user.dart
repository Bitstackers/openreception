part of utilitiesservice;

abstract class userProtocol {
  static final User_RESOURCE = "/broadcast";
}

abstract class User {
  
  static final String className = '${libraryName}.User'; 

  static HttpClient client = new HttpClient();
  
}

