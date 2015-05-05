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
import 'service/service.dart' as Service;
import 'view/view.dart' as View;

import 'package:logging/logging.dart';
import 'package:openreception_framework/model.dart' as ORModel;
import 'package:openreception_framework/service.dart' as ORService;
import 'package:openreception_framework/service-html.dart' as ORTransport;

part 'configuration_url.dart';

const String libraryName = 'openreceptionclient';

final Model.AppClientState appState = new Model.AppClientState();
final Logger               log      = new Logger(libraryName);

View.ReceptionistclientDisaster appDisaster;
View.ReceptionistclientLoading  appLoading;
View.ReceptionistclientReady    appReady;
Uri                             appUri;
ORModel.ClientConfiguration     clientConfig;
ORService.NotificationSocket    notificationSocket;
String                          token;
ORTransport.WebSocketClient     webSocketClient;

main() async {
  try {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen(print);

    appUri = Uri.parse(window.location.href);

    /// This is the 'settoken' URL path parameter.
    token = getToken();

    /// Translate the static labels of the app. We do this early to have correct
    /// labels set while loading.
    translate();

    /// Get the app Disaster and Loading views up and running.
    registerDisasterAndLoadingViews();

    /// Hang here until the client configuration has been loaded from the server.
    clientConfig = await getClientConfiguration();

    /// Make sure we don't steal focus from widgets with mouseclicks on non-widget
    /// elements. This is simply done by searching for the "ignoreclickfocus"
    /// attribute and ignoring mousedown events for those elements.
    document.onMouseDown.listen((MouseEvent event) {
      if((event.target as HtmlElement).attributes.keys.contains('ignoreclickfocus')) {
        event.preventDefault();
      }
    });

    if(token != null) {
      Model.User.currentUser = await getUser(clientConfig.authServerUri);

      webSocketClient    = new ORTransport.WebSocketClient();
      notificationSocket = new ORService.NotificationSocket(webSocketClient);

      Uri uri = Uri.parse('${clientConfig.notificationSocketUri}?token=${token}');
      webSocketClient.connect(uri).then((_) {
        log.info('WebSocketClient connect succeeded - NotificationSocket up');

        /// Get the app Ready view up and running.
        registerReadyView();
        appState.changeState(Model.AppState.READY);
      });
    } else {
      String loginUrl = '${clientConfig.authServerUri}/token/create?returnurl=${window.location.toString()}';
      log.info('No token detected, redirecting user to $loginUrl');
      window.location.replace(loginUrl);
    }
  } catch(error, stackTrace) {
    log.shout('Could not fully initialize application. Trying again in 2 seconds');
    log.shout(error, stackTrace);
    appState.changeState(Model.AppState.ERROR);

    new Future.delayed(new Duration(seconds: 10)).then((_) {
      window.location.replace('${appUri.origin}${appUri.path}');
    });
  }
}

/**
 * Return the configuration object for the client.
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
 * Return the value of the URL path parameter 'settoken'
 */
String getToken() => appUri.queryParameters['settoken'];

/**
 * Return the current user.
 */
Future<ORModel.User> getUser(Uri authServerUri) async {
  ORService.Authentication authService =
      new ORService.Authentication(authServerUri, token, new ORTransport.Client());

  return authService.userOf(token).then((ORModel.User user) {
    return new Model.User.fromORModel(user);
  });
}

/**
 * Register the [View.ReceptionistclientDisaster] and [View.ReceptionistclientLoading]
 * app view objects.
 *
 * NOTE: This depends on [clientConfig] being set.
 */
void registerDisasterAndLoadingViews() {
  Model.UIReceptionistclientDisaster uiDisaster =
      new Model.UIReceptionistclientDisaster('receptionistclient-disaster');
  Model.UIReceptionistclientLoading  uiLoading =
      new Model.UIReceptionistclientLoading('receptionistclient-loading');

  appDisaster = new View.ReceptionistclientDisaster(appState, uiDisaster);
  appLoading  = new View.ReceptionistclientLoading(appState, uiLoading);
}

/**
 * Register the [View.ReceptionistclientReady] app view object.
 *
 * This also registers the [window.onBeforeUnload] and [window.onUnload]
 * listeners that is responsible for logging out the user when she exits.
 *
 * NOTE: This depends on [clientConfig] being set.
 */
void registerReadyView() {
  Model.UIReceptionistclientReady    uiReady =
      new Model.UIReceptionistclientReady('receptionistclient-ready');
  ORService.RESTContactStore   contactStore = new ORService.RESTContactStore
      (clientConfig.contactServerUri, token, new ORTransport.Client());
  ORService.RESTReceptionStore receptionStore = new ORService.RESTReceptionStore
      (clientConfig.receptionServerUri, token, new ORTransport.Client());
  ORService.CallFlowControl callFlowControl = new ORService.CallFlowControl
      (clientConfig.callFlowServerUri, token, new ORTransport.Client());

  Controller.User _controllerUser = new Controller.User(callFlowControl);

  window.onBeforeUnload.listen((BeforeUnloadEvent event) {
    event.returnValue = '';
  });

  window.onUnload.listen((_) {
    _controllerUser.setLoggedOut(Model.User.currentUser);
  });

  setupUserKeepAlive(_controllerUser);

  _controllerUser.userStateKeepAlive(Model.User.currentUser);

  /// This is where it all starts. Every single widget is instantiated in
  /// appReady.
  appReady = new View.ReceptionistclientReady
      (appState,
       uiReady,
       new Controller.Contact(contactStore),
       new Controller.Reception(receptionStore),
       _controllerUser,
       new Controller.Call(callFlowControl),
       notificationSocket);
}

/**
 * Start a periodic timer that phones home on regular intervals.
 */
void setupUserKeepAlive(Controller.User _controllerUser) {
  new Timer.periodic(new Duration(seconds: 5), (Timer timer) {
    _controllerUser.userStateKeepAlive(Model.User.currentUser)
      .then((_) => log.info('User id ${Model.User.currentUser.ID} kept alive'))
      .catchError((error) {
        timer.cancel();
        log.warning('User id ${Model.User.currentUser.ID} failed keep alive call');
        setupUserKeepAlive(_controllerUser);
      });
  });
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
