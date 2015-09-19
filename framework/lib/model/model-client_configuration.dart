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
  Uri userServerUri;

  /**
   * Returns a map reflection of the object suitable for data transfer.
   */
  Map get asMap =>
    {Key.callFlowServerURI : this.callFlowServerUri.toString(),
     Key.receptionServerURI : this.receptionServerUri.toString(),
     Key.contactServerURI : this.contactServerUri.toString(),
     Key.messageServerURI  : this.messageServerUri.toString(),
     Key.authServerURI  : this.authServerUri.toString(),
     Key.userServerURI  : this.userServerUri.toString(),
     Key.systemLanguage : this.systemLanguage,
     Key.notificationServerUri : this.notificationServerUri.toString(),

      "notificationSocket": {
        Key.interface: this.notificationSocketUri.toString(),
        "reconnectInterval": 2000
      },
  };

  /**
   *
   */
  Map toJson() => this.asMap;

  /**
   * Build an uninitialized object
   */
  ClientConfiguration.empty();

  /**
   * Build an object from a serialized map.
   */
  ClientConfiguration.fromMap (Map map) {
    this.systemLanguage =
        map [Key.systemLanguage];
    this.callFlowServerUri =
        Uri.parse(map [Key.callFlowServerURI]);
    this.receptionServerUri =
        Uri.parse(map [Key.receptionServerURI]);
    this.contactServerUri =
        Uri.parse(map [Key.contactServerURI]);
    this.messageServerUri =
        Uri.parse(map [Key.messageServerURI]);
    this.authServerUri =
        Uri.parse(map[Key.authServerURI]);
    this.userServerUri = Uri.parse(map[Key.userServerURI]);
    this.notificationServerUri =
        Uri.parse(map [Key.notificationServerUri]);
    this.notificationSocketUri =
        Uri.parse(map ['notificationSocket'][Key.interface]);  }

}