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
  Uri authServerUri;
  Uri calendarServerUri;
  Uri callFlowServerUri;
  Uri cdrServerUri;
  Uri contactServerUri;
  Uri dialplanServerUri;
  bool hideInboundCallerId;
  Uri messageServerUri;
  List<String> myIdentifiers;
  Uri notificationServerUri;
  Uri notificationSocketUri;
  Uri receptionServerUri;
  String systemLanguage;
  Uri userServerUri;

  /**
   * Returns a map reflection of the object suitable for data transfer.
   */
  Map get asMap => {
        Key.authServerURI: authServerUri.toString(),
        Key.calendarServerUri: calendarServerUri.toString(),
        Key.callFlowServerURI: callFlowServerUri.toString(),
        Key.cdrServerUri: cdrServerUri.toString(),
        Key.contactServerURI: contactServerUri.toString(),
        Key.dialplanServerURI: dialplanServerUri.toString(),
        Key.hideInboundCallerId: hideInboundCallerId,
        Key.messageServerURI: messageServerUri.toString(),
        Key.myIdentifiers: myIdentifiers,
        Key.notificationServerUri: notificationServerUri.toString(),
        Key.notificationSocket: notificationSocketUri.toString(),
        Key.receptionServerURI: receptionServerUri.toString(),
        Key.systemLanguage: systemLanguage,
        Key.userServerURI: userServerUri.toString(),
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
  ClientConfiguration.fromMap(Map map)
      : authServerUri = Uri.parse(map[Key.authServerURI]),
        calendarServerUri = Uri.parse(map[Key.calendarServerUri]),
        callFlowServerUri = Uri.parse(map[Key.callFlowServerURI]),
        cdrServerUri = Uri.parse(map[Key.cdrServerUri]),
        contactServerUri = Uri.parse(map[Key.contactServerURI]),
        dialplanServerUri = Uri.parse(map[Key.dialplanServerURI]),
        hideInboundCallerId = map[Key.hideInboundCallerId],
        messageServerUri = Uri.parse(map[Key.messageServerURI]),
        myIdentifiers = map[Key.myIdentifiers],
        notificationServerUri = Uri.parse(map[Key.notificationServerUri]),
        notificationSocketUri = Uri.parse(map[Key.notificationSocket]),
        receptionServerUri = Uri.parse(map[Key.receptionServerURI]),
        systemLanguage = map[Key.systemLanguage],
        userServerUri = Uri.parse(map[Key.userServerURI]);
}
