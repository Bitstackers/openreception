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
//import 'simulation.dart';

import 'package:logging/logging.dart';
import 'package:openreception.framework/event.dart' as event;
import 'package:openreception.framework/model.dart' as ORModel;
import 'package:openreception.framework/service.dart' as ORService;
import 'package:openreception.framework/service-html.dart' as ORTransport;

part 'configuration_url.dart';

const String libraryName = 'orc';

Model.UIORCDisaster uiDisaster = new Model.UIORCDisaster('orc-disaster');
Model.UIORCLoading uiLoading = new Model.UIORCLoading('orc-loading');

View.ORCDisaster appDisaster;
View.ORCLoading appLoading;
View.ORCReady appReady;
final Logger log = new Logger(libraryName);
StreamSubscription<Event> windowOnBeforeUnload;
StreamSubscription<Event> windowOnUnload;

Uri get _appUri => Uri.parse(window.location.href);

main() async {
  Uri configUri;
  if (_appUri.queryParameters.containsKey('config_server')) {
    configUri = Uri.parse(_appUri.queryParameters['config_server']);
  } else {
    configUri = defaultConfigUri;
  }

  /// Hang here until the client configuration has been loaded from the server.
  final ORModel.ClientConfiguration clientConfig =
      await getClientConfiguration(configUri);
  uiLoading.addLoadingMessage('Configuration fetched OK');

  Map<String, String> language;

  /// This is the 'settoken' URL path parameter.
  final String token = getToken(_appUri);

  final ORTransport.WebSocketClient webSocketClient =
      new ORTransport.WebSocketClient();

  final ORService.NotificationService notificationService =
      new ORService.NotificationService(
          clientConfig.notificationServerUri, token, new ORTransport.Client());
  final Controller.Notification notificationController =
      new Controller.Notification(
          new ORService.NotificationSocket(webSocketClient),
          notificationService);
  final Model.AppClientState appState =
      new Model.AppClientState(notificationController);

  try {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen(print);

    /// Verify that we support HTMl5 notifications
    if (Notification.supported) {
      uiLoading.addLoadingMessage('HTMl5 notification support OK');
      Notification
          .requestPermission()
          .then((String perm) => log.info('HTML5 permission ${perm}'));
    } else {
      log.shout('HTML5 notifications not supported.');
    }

    /// Set the app language
    language = getLanguageMap(clientConfig.systemLanguage);

    /// Translate the static labels of the app. We do this early to have correct
    /// labels set while loading.
    translate(language);

    /// Get the app Disaster and Loading views up and running.
    registerDisasterAndLoadingViews(appState);

    if (token != null) {
      uiLoading.addLoadingMessage('Found token OK');
      appState.currentUser = await getUser(clientConfig.authServerUri, token);
      uiLoading
          .addLoadingMessage('User ${appState.currentUser.name} detected OK');

      webSocketClient.onClose = () {
        log.shout('Websocket connection died. Trying reload in 10 seconds');
        appState.changeState(Model.AppState.error);
        restartAppInTenSeconds(_appUri);
      };

      Uri uri =
          Uri.parse('${clientConfig.notificationSocketUri}?token=${token}');

      await webSocketClient.connect(uri).then((_) {
        log.info('WebSocketClient connect succeeded - NotificationSocket up');
        uiLoading.addLoadingMessage('Websocket connected OK');

        final ORService.CallFlowControl callFlowControl =
            new ORService.CallFlowControl(clientConfig.callFlowServerUri, token,
                new ORTransport.Client());
        final ORService.NotificationService notificationService =
            new ORService.NotificationService(
                clientConfig.notificationServerUri,
                token,
                new ORTransport.Client());
        final ORService.RESTUserStore userService = new ORService.RESTUserStore(
            clientConfig.userServerUri, token, new ORTransport.Client());

        final Controller.User userController = new Controller.User(
            callFlowControl, notificationService, userService);

        Future rRV = registerReadyView(
            appState,
            clientConfig,
            userController,
            callFlowControl,
            notificationController,
            language,
            token,
            webSocketClient);

        Future lCS = loadCallState(callFlowControl, appState);

        Future.wait([rRV, lCS]).then((_) async {
          await new Future.delayed(new Duration(seconds: 1));
          appState.changeState(Model.AppState.ready);
        }).catchError((error) {
          log.shout('Loading of app failed with ${error}');
          appState.changeState(Model.AppState.error);
        });
      });
    } else {
      String loginUrl =
          '${clientConfig.authServerUri}/token/create?returnurl=${window.location.toString()}';
      log.info('No token detected, redirecting user to $loginUrl');
      window.location.replace(loginUrl);
    }
  } catch (error, stackTrace) {
    log.shout(
        'Could not fully initialize application. Trying again in 10 seconds');
    log.shout(error, stackTrace);
    appState.changeState(Model.AppState.error);
    restartAppInTenSeconds(_appUri);
  }
}

/**
 * Return the configuration object for the client.
 */
Future<ORModel.ClientConfiguration> getClientConfiguration(
    Uri configUri) async {
  ORService.RESTConfiguration configService =
      new ORService.RESTConfiguration(configUri, new ORTransport.Client());

  try {
    return await configService
        .clientConfig()
        .then((ORModel.ClientConfiguration config) {
      log.info('Loaded client config: ${config.toJson()}');
      return config;
    });
  } catch (error, stackTrace) {
    final String msg =
        'Could not fully initialize application. Trying again in 10 seconds';
    log.shout(msg);
    log.shout(error, stackTrace);
    uiLoading.addLoadingMessage(msg);
    uiLoading.addLoadingMessage('Error: $error');
    await restartAppInTenSeconds(_appUri);
  }
}

/**
 * Return the language map that corresponds to [language]. If [language] doesn't
 * exist, then return the english language map.
 */
Map<String, String> getLanguageMap(String language) {
  Map<String, String> map;

  switch (language) {
    case 'da':
      map = Lang.da;
      break;
    case 'en':
      map = Lang.en;
      break;
    default:
      map = Lang.en;
      break;
  }

  return map;
}

/**
 * Return the value of the URL path parameter 'settoken'
 */
String getToken(Uri appUri) => appUri.queryParameters['settoken'];

/**
 * Return the current user.
 */
Future<ORModel.User> getUser(Uri authServerUri, String token) {
  ORService.Authentication authService = new ORService.Authentication(
      authServerUri, token, new ORTransport.Client());

  return authService.userOf(token);
}

/**
 * Load call state for current user.
 */
Future loadCallState(
    ORService.CallFlowControl callFlowControl, Model.AppClientState appState) {
  return callFlowControl.callList().then((Iterable<ORModel.Call> calls) {
    ORModel.Call myActiveCall = calls.firstWhere(
        (ORModel.Call call) =>
            call.assignedTo == appState.currentUser.id &&
            call.state == ORModel.CallState.speaking,
        orElse: () => null);

    if (myActiveCall != null) {
      appState.activeCall = myActiveCall;
    }
  });
}

/**
 * Observers.
 */
void observers(
    Controller.User userController,
    Model.AppClientState appState,
    ORTransport.WebSocketClient webSocketClient,
    Controller.Notification notification) {
  /// Make sure we don't steal focus from widgets with mouseclicks on
  /// non-widget elements. This is simply done by searching for the
  /// "ignoreclickfocus" attribute and ignoring mousedown events for those
  /// elements.
  document.onMouseDown.listen((MouseEvent event) {
    if ((event.target as HtmlElement)
        .attributes
        .keys
        .contains('ignoreclickfocus')) {
      event.preventDefault();
    }
  });

  windowOnBeforeUnload = window.onBeforeUnload.listen((Event event) {
    (event as BeforeUnloadEvent).returnValue = '';
  });

  windowOnUnload = window.onUnload.listen((_) {
    webSocketClient.close();
  });

  Controller.Navigate navigate = new Controller.Navigate();
  navigate.onGo.listen((Controller.Destination destination) {
    final event.WidgetSelect destinationEvent =
        new event.WidgetSelect(appState.currentUser.id, destination.toString());
    log.info(destinationEvent);
    notification.notifySystem(destinationEvent);
  });

  window.onFocus.listen((e) {
    final event.FocusChange focusEvent =
        new event.FocusChange.focus(appState.currentUser.id);
    log.info(focusEvent);
    notification.notifySystem(focusEvent);
  });

  window.onBlur.listen((e) {
    final event.FocusChange focusEvent =
        new event.FocusChange.blur(appState.currentUser.id);
    log.info(focusEvent);
    notification.notifySystem(focusEvent);
  });
}

/**
 * Register the [View.ReceptionistclientDisaster] and
 * [View.ReceptionistclientLoading] app view objects.
 *
 * NOTE: This depends on [clientConfig] being set.
 */
void registerDisasterAndLoadingViews(Model.AppClientState appState) {
  appDisaster = new View.ORCDisaster(appState, uiDisaster);
  appLoading = new View.ORCLoading(appState, uiLoading);
}

/**
 * Register the [View.ReceptionistclientReady] app view object.
 * NOTE: This depends on [clientConfig] being set.
 */
Future registerReadyView(
    Model.AppClientState appState,
    ORModel.ClientConfiguration clientConfig,
    Controller.User controllerUser,
    ORService.CallFlowControl callFlowControl,
    Controller.Notification notification,
    Map<String, String> langMap,
    String token,
    ORTransport.WebSocketClient webSocketClient) {
  Model.UIORCReady uiReady = new Model.UIORCReady('orc-ready');

  ORService.RESTCalendarStore calendarStore = new ORService.RESTCalendarStore(
      clientConfig.calendarServerUri, token, new ORTransport.Client());
  ORService.RESTContactStore contactStore = new ORService.RESTContactStore(
      clientConfig.contactServerUri, token, new ORTransport.Client());
  ORService.RESTMessageStore messageStore = new ORService.RESTMessageStore(
      clientConfig.messageServerUri, token, new ORTransport.Client());
  Controller.Message messageController =
      new Controller.Message(messageStore, appState.currentUser);
  ORService.RESTReceptionStore receptionStore =
      new ORService.RESTReceptionStore(
          clientConfig.receptionServerUri, token, new ORTransport.Client());
  Controller.Reception receptionController =
      new Controller.Reception(receptionStore);
  Controller.Calendar calendarController =
      new Controller.Calendar(calendarStore, appState.currentUser);
  Controller.Call callController =
      new Controller.Call(callFlowControl, appState);

  Controller.Popup popup = new Controller.Popup(
      new Uri.file('/images/popup_error.png'),
      new Uri.file('/images/popup_info.png'),
      new Uri.file('/images/popup_success.png'));

  Controller.Sound sound =
      new Controller.Sound(querySelector('audio.sound-pling'));

  observers(controllerUser, appState, webSocketClient, notification);

  return receptionController
      .list()
      .then((Iterable<ORModel.ReceptionReference> receptions) {
    Iterable<ORModel.ReceptionReference> sortedReceptions = receptions.toList()
      ..sort((x, y) => x.name.toLowerCase().compareTo(y.name.toLowerCase()));

    appReady = new View.ORCReady(
        appState,
        uiReady,
        calendarController,
        clientConfig,
        new Controller.Contact(contactStore, notification),
        receptionController,
        sortedReceptions,
        controllerUser,
        callController,
        notification,
        messageController,
        popup,
        sound,
        langMap);

    //simulation.start(callController, appState);
  });
}

/**
 * Tries to reload the application at [appUri] in 10 seconds.
 */
Future restartAppInTenSeconds(Uri appUri) async {
  if (windowOnBeforeUnload != null) {
    windowOnBeforeUnload.cancel();
  }

  if (windowOnUnload != null) {
    windowOnUnload.cancel();
  }

  await new Future.delayed(new Duration(seconds: 10)).then((_) {
    appUri = Uri.parse(window.location.href);
    window.location.replace('${appUri.origin}${appUri.path}');
  });
}

/**
 * Worlds most simple method to translate widget labels to supported languages.
 */
void translate(Map<String, String> langMap) {
  querySelectorAll('[data-lang-text]').forEach((Element element) {
    element.text = langMap[element.dataset['lang-text']];
  });

  querySelectorAll('[data-lang-placeholder]').forEach((Element element) {
    element.setAttribute(
        'placeholder', langMap[element.dataset['lang-placeholder']]);
  });
}
