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

library openreceptionclient;

import 'dart:async';
import 'dart:html';

import 'controller/controller.dart' as Controller;
import 'lang.dart' as Lang;
import 'model/model.dart' as Model;
import 'view/view.dart' as View;

import 'package:logging/logging.dart';
import 'package:openreception_framework/model.dart' as ORModel;
import 'package:openreception_framework/service.dart' as ORService;
import 'package:openreception_framework/service-html.dart' as ORTransport;

part 'configuration_url.dart';

const String libraryName = 'openreceptionclient';
final Logger log         = new Logger(libraryName);

main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  final Model.AppClientState   appState = new Model.AppClientState();
  ORModel.ClientConfiguration  clientConfig;

  clientConfig = await getClientConfiguration();

  if(token == null) {
    String loginUrl = '${clientConfig.authServerUri}/token/create?returnurl=${window.location.toString()}';
    log.info('No token detected, redirecting user to $loginUrl');
    window.location.replace(loginUrl);
  } else {
    try {
      ORService.RESTContactStore   contactStore;
      ORService.NotificationSocket notificationSocket;
      ORService.RESTReceptionStore receptionStore;
      ORService.WebSocket          webSocket;
      ORTransport.WebSocketClient  ws;

      // Translate the static labels of the app.
      translate();

      final Model.UIReceptionistclientDisaster uiDisaster =
          new Model.UIReceptionistclientDisaster('receptionistclient-disaster');
      final Model.UIReceptionistclientLoading uiLoading =
          new Model.UIReceptionistclientLoading('receptionistclient-loading');
      final Model.UIReceptionistclientReady uiReady =
          new Model.UIReceptionistclientReady('receptionistclient-ready');

      View.ReceptionistclientDisaster appDisaster =
          new View.ReceptionistclientDisaster(appState, uiDisaster);
      View.ReceptionistclientLoading appLoading =
          new View.ReceptionistclientLoading(appState, uiLoading);

      Model.User.currentUser = await getUser(clientConfig.authServerUri);

      ws = new ORTransport.WebSocketClient();
      notificationSocket = new ORService.NotificationSocket(ws);
      ws.onMessage = print; //FIXME (KRC): In the framework.
      Uri uri = Uri.parse('${clientConfig.notificationSocketUri}?token=${token}');
      ws.connect(uri).then((_) {
        log.info('NotificationSocket up');
      });

      contactStore = new ORService.RESTContactStore
          (clientConfig.contactServerUri, token, new ORTransport.Client());

      receptionStore = new ORService.RESTReceptionStore
          (clientConfig.receptionServerUri, token, new ORTransport.Client());

      /// Make sure we don't steal focus from widgets with mouseclicks on non-widget
      /// elements. This is simply done by searching for the "ignoreclickfocus"
      /// attribute and ignoring mousedown events for those elements.
      document.onMouseDown.listen((MouseEvent event) {
        if ((event.target as HtmlElement).attributes.keys
            .contains('ignoreclickfocus')) {
          event.preventDefault();
        }
      });

      /// This is where it all starts. Every single widget is instantiated in
      /// appReady.
      View.ReceptionistclientReady appReady = new View.ReceptionistclientReady(
          appState, uiReady, new Controller.Contact(contactStore),
          new Controller.Reception(receptionStore));

      appState.changeState(Model.AppState.READY);
    } catch(error, stackTrace) {
      log.shout(error, stackTrace);
      appState.changeState(Model.AppState.ERROR);
      /// TODO (TL): Do something sensible here. Redirect in 10 seconds or so?
    }
  }
}

/**
 *
 */
Future<ORModel.ClientConfiguration> getClientConfiguration() async {
  ORService.RESTConfiguration configService =
      new ORService.RESTConfiguration(CONFIGURATION_URL, new ORTransport.Client());

  return configService.clientConfig().then((ORModel.ClientConfiguration config) {
      log.info('Loaded client config: ${config.asMap}');
      return config;
  });
}

/**
 *
 */
Future<ORModel.User> getUser(Uri authServerUri) async {
  ORService.Authentication authService =
      new ORService.Authentication(authServerUri, token, new ORTransport.Client());

  return authService.userOf(token).then((ORModel.User user) {
    return new Model.User.fromORModel(user);
  });
}

/**
 * Return the value of the URL path parameter 'settoken'
 */
String get token {
  Uri url = Uri.parse(window.location.href);

  return url.queryParameters['settoken'];
}

/**
 * Worlds most simple method to translate widget labels to supported languages.
 */
void translate() {
  Map<String, String> langMap = Lang.da;

  querySelectorAll('[data-lang-text]').forEach((HtmlElement element) {
    element.text = langMap[element.dataset['lang-text']];
  });

  querySelectorAll('[data-lang-placeholder]').forEach((HtmlElement element) {
    element.setAttribute(
        'placeholder', langMap[element.dataset['lang-placeholder']]);
  });
}
