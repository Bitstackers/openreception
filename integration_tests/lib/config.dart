part of or_test_fw;

abstract class Default {
  static final Uri receptionStoreURI = Uri.parse('http://localhost:4000');
  static final Uri messageStoreURI = Uri.parse('http://localhost:4040');
  static const String authToken = 'feedabbadeadbeef0';
}

abstract class Config {
   static Uri receptionStoreURI = Default.receptionStoreURI;
   static Uri messageServerUri  = Default.messageStoreURI;
   static String authToken = Default.authToken;
   static final Uri CallFlowControlUri = Uri.parse('http://localhost:4242');
   static final Uri NotificationSocketUri =
       Uri.parse('ws://localhost:4200/notifications');
}
