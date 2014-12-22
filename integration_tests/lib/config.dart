part of or_test_fw;

abstract class Default {

  static final Uri receptionStoreURI = Uri.parse('http://localhost:4000');
}

abstract class Configuration {
   static Uri receptionStoreURI = Default.receptionStoreURI;
}