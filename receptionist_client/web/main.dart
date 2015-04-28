import 'dart:async';
import 'dart:html';

import 'dummies.dart';

import 'enums.dart';
import 'lang.dart' as Lang;
import 'model/model.dart' as Model;
import 'view/view.dart' as View;
import 'config/configuration_url.dart';


import 'package:logging/logging.dart';
import 'package:openreception_framework/model.dart' as ORModel;
import 'package:openreception_framework/service.dart' as ORService;
import 'package:openreception_framework/service-html.dart' as ORTransport;

void main() {
  // Init logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  Model.AppClientState appState = new Model.AppClientState();

  ORService.RESTConfiguration configService =
      new ORService.RESTConfiguration(CONFIGURATION_URL,
          new ORTransport.Client ());
  ORModel.ClientConfiguration clientConfig;
  String myToken = null;

  ORService.NotificationSocket notificationSocket;
  ORService.Authentication authService;

  Future downloadClientConfig = configService.clientConfig()
    .then((ORModel.ClientConfiguration config) {
      Logger.root.info ('Loaded client config: ${config.asMap}');
      clientConfig = config;
    });

  Future<ORModel.User> loadUser () {
    myToken = getToken();
    if(myToken != null) {
      return authService.userOf(myToken);
    }

    String loginUrl = '${clientConfig.authServerUri}/token/create?returnurl=${window.location.toString()}';
    window.location.replace(loginUrl);
    return new Future.error(new StateError('This should not happen. No. REALLY!'));
  }

  void connectAuthService() {
    authService = new ORService.Authentication
        (clientConfig.authServerUri, myToken, new ORTransport.Client());
  }


  Future connectWebsocket(ORModel.ClientConfiguration config) {
    ORTransport.WebSocketClient ws = new ORTransport.WebSocketClient();
    notificationSocket = new ORService.NotificationSocket (ws);

    //FIXME: In the framework.
    ws.onMessage = print;
    Uri uri = Uri.parse('${config.notificationSocketUri}?token=${myToken}');

    return ws.connect(uri);
  }

  /// Make sure we don't steal focus from widgets with mouseclicks on non-widget
  /// elements. This is simply done by searching for the "ignoreclickfocus"
  /// attribute and ignoring mousedown events for those elements.
  document.onMouseDown.listen((MouseEvent event) {
    if((event.target as HtmlElement).attributes.keys.contains('ignoreclickfocus')) {
      event.preventDefault();
    }
  });


  /// Translate the static labels of the app.
  translate();

  final Model.UIReceptionistclientDisaster uiDisaster = new Model.UIReceptionistclientDisaster('receptionistclient-disaster');
  final Model.UIReceptionistclientLoading  uiLoading  = new Model.UIReceptionistclientLoading('receptionistclient-loading');
  final Model.UIReceptionistclientReady    uiReady    = new Model.UIReceptionistclientReady('receptionistclient-ready');

  View.ReceptionistclientDisaster appDisaster = new View.ReceptionistclientDisaster(appState, uiDisaster);
  View.ReceptionistclientLoading  appLoading  = new View.ReceptionistclientLoading(appState, uiLoading);

  /// This is where it all starts. Every single widget is instantiated in
  /// appReady.
  View.ReceptionistclientReady appReady = new View.ReceptionistclientReady(appState, uiReady);

  downloadClientConfig
    .then((_) => connectAuthService())
    .then((_) => loadUser())
    .then((_) => connectWebsocket(clientConfig))
    .then((_) {
      appState.changeState(Model.AppState.READY);
    })
    .catchError((error, stacktrace) {
      Logger.root.shout(error, stacktrace);
      appState.changeState(Model.AppState.ERROR);
  });


  /// TODO (TL): The loading context is visible by default. Switch to ready after
  /// 1 second.
//  new Future.delayed(new Duration(milliseconds: 500)).then((_) {
//    appState.state = AppState.READY;
//  });
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
    element.setAttribute('placeholder', langMap[element.dataset['lang-placeholder']]);
  });
}

String getToken() {
  Uri url = Uri.parse(window.location.href);

  return url.queryParameters['settoken'];
}
