part of openreception.model;

abstract class ClientConfigJSONKey {
  static final StandardGreeting = 'standardGreeting';
  static final CallFlowServerURI = 'callFlowServerURI';
  static final ReceptionServerURI = 'receptionServerURI';
  static final ContactServerURI = 'contactServerURI';
  static final MessageServerURI = 'messageServerURI';
  static final LogServerURI = 'logServerURI';
  static final AuthServerURI = 'authServerURI';
  static final Interface = 'interface';
}

class ClientConfiguration {

  String welcomeMessage;
  Uri callFlowServerUri;
  Uri receptionServerUri;
  Uri contactServerUri;
  Uri messageServerUri;
  Uri logServerUri;
  Uri authServerUri;
  Uri notificationSocketUri;

  Map get asMap =>
    {ClientConfigJSONKey.StandardGreeting : this.welcomeMessage,
     ClientConfigJSONKey.CallFlowServerURI : this.callFlowServerUri.toString(),
     ClientConfigJSONKey.ReceptionServerURI : this.receptionServerUri.toString(),
     ClientConfigJSONKey.ContactServerURI : this.contactServerUri.toString(),
     ClientConfigJSONKey.MessageServerURI  : this.messageServerUri.toString(),
     ClientConfigJSONKey.LogServerURI : this.logServerUri.toString(),
     ClientConfigJSONKey.AuthServerURI  : this.authServerUri.toString(),

      "notificationSocket": {
        ClientConfigJSONKey.Interface: this.notificationSocketUri.toString(),
        "reconnectInterval": 2000
      },

      "serverLog": {
          "level": "info",
          "interface": {
              "critical": "/log/critical",
              "error": "/log/error",
              "info": "/log/info"
          }
      }
  };


  ClientConfiguration.fromMap (Map map) {
    this.welcomeMessage =
        map [ClientConfigJSONKey.StandardGreeting];
    this.callFlowServerUri =
        Uri.parse(map [ClientConfigJSONKey.CallFlowServerURI]);
    this.receptionServerUri =
        Uri.parse(map [ClientConfigJSONKey.ReceptionServerURI]);
    this.contactServerUri =
        Uri.parse(map [ClientConfigJSONKey.ContactServerURI]);
    this.messageServerUri =
        Uri.parse(map [ClientConfigJSONKey.MessageServerURI]);
    this.logServerUri =
        Uri.parse(map [ClientConfigJSONKey.LogServerURI]);
    this.authServerUri =
        Uri.parse(map[ClientConfigJSONKey.AuthServerURI]);
    this.notificationSocketUri =
        Uri.parse(map ['notificationSocket'][ClientConfigJSONKey.Interface]);
  }


}