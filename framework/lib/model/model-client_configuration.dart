/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.model;

/**
 * Serialization/deserialization keys.
 */
abstract class ClientConfigJSONKey {
  static final CallFlowServerURI = 'callFlowServerURI';
  static final ReceptionServerURI = 'receptionServerURI';
  static final ContactServerURI = 'contactServerURI';
  static final MessageServerURI = 'messageServerURI';
  static final AuthServerURI = 'authServerURI';
  static final Interface = 'interface';
  static const SystemLanguage = 'systemLanguage';
  static const notificationServerUri = 'notificationServerUri';
}

/**
 * Configuration for clients. Is provided by the config server and contains
 * information about where to locate the various services provided by the
 * server stack.
 */
class ClientConfiguration {

  /// Global system language.
  String systemLanguage;
  Uri callFlowServerUri;
  Uri receptionServerUri;
  Uri contactServerUri;
  Uri messageServerUri;
  Uri authServerUri;
  Uri notificationSocketUri;
  Uri notificationServerUri;

  /**
   * Returns a map reflection of the object suitable for data transfer.
   */
  Map get asMap =>
    {ClientConfigJSONKey.CallFlowServerURI : this.callFlowServerUri.toString(),
     ClientConfigJSONKey.ReceptionServerURI : this.receptionServerUri.toString(),
     ClientConfigJSONKey.ContactServerURI : this.contactServerUri.toString(),
     ClientConfigJSONKey.MessageServerURI  : this.messageServerUri.toString(),
     ClientConfigJSONKey.AuthServerURI  : this.authServerUri.toString(),
     ClientConfigJSONKey.SystemLanguage : this.systemLanguage,
     ClientConfigJSONKey.notificationServerUri : this.notificationServerUri.toString(),

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

  /**
   * Build an uninitialized object
   */
  ClientConfiguration.empty();

  /**
   * Build an object from a serialized map.
   */
  ClientConfiguration.fromMap (Map map) {
    this.systemLanguage =
        map [ClientConfigJSONKey.SystemLanguage];
    this.callFlowServerUri =
        Uri.parse(map [ClientConfigJSONKey.CallFlowServerURI]);
    this.receptionServerUri =
        Uri.parse(map [ClientConfigJSONKey.ReceptionServerURI]);
    this.contactServerUri =
        Uri.parse(map [ClientConfigJSONKey.ContactServerURI]);
    this.messageServerUri =
        Uri.parse(map [ClientConfigJSONKey.MessageServerURI]);
    this.authServerUri =
        Uri.parse(map[ClientConfigJSONKey.AuthServerURI]);
    this.notificationServerUri =
        Uri.parse(map [ClientConfigJSONKey.notificationServerUri]);
    this.notificationSocketUri =
        Uri.parse(map ['notificationSocket'][ClientConfigJSONKey.Interface]);  }

}