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

import 'controller/controller.dart' as controller;
import 'lang.dart' as lang;
import 'model/model.dart' as ui_model;
import 'view/view.dart' as view;
//import 'simulation.dart';

import 'package:logging/logging.dart';
import 'package:openreception.framework/event.dart' as event;
import 'package:openreception.framework/model.dart' as model;
import 'package:openreception.framework/service.dart' as service;
import 'package:openreception.framework/service-html.dart' as transport;

part 'configuration_url.dart';

const String libraryName = 'orc';

ui_model.UIORCDisaster uiDisaster = new ui_model.UIORCDisaster('orc-disaster');
ui_model.UIORCLoading uiLoading = new ui_model.UIORCLoading('orc-loading');

view.ORCDisaster appDisaster;
view.ORCLoading appLoading;
view.ORCReady appReady;
final Logger log = new Logger(libraryName);
StreamSubscription<Event> windowOnBeforeUnload;
StreamSubscription<Event> windowOnUnload;

Uri get _appUri => Uri.parse(window.location.href);

/// Verify that we support HTMl5 notifications
void _html5Checks() {
  if (Notification.supported) {
    uiLoading.addLoadingMessage('HTMl5 notification support OK');
    Notification
        .requestPermission()
        .then((String perm) => log.info('HTML5 permission $perm'));
  } else {
    log.shout('HTML5 notifications not supported.');
  }
}

Future main() async {
  Uri configUri;
  if (_appUri.queryParameters.containsKey('config_server')) {
    configUri = Uri.parse(_appUri.queryParameters['config_server']);
  } else {
    configUri = defaultConfigUri;
  }

  /// Hang here until the client configuration has been loaded from the server.
  final model.ClientConfiguration clientConfig =
      await getClientConfiguration(configUri);
  uiLoading.addLoadingMessage('Configuration fetched OK');

  Map<String, String> language;

  /// This is the 'settoken' URL path parameter.
  final String token = getToken(_appUri);

  final transport.WebSocketClient webSocketClient =
      new transport.WebSocketClient();

  final service.NotificationService notificationService =
      new service.NotificationService(
          clientConfig.notificationServerUri, token, new transport.Client());
  final controller.Notification notificationController =
      new controller.Notification(
          new service.NotificationSocket(webSocketClient), notificationService);
  final ui_model.AppClientState appState =
      new ui_model.AppClientState(notificationController);

  try {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen(print);

    _html5Checks();

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
        appState.changeState(ui_model.AppState.error);
        restartAppInTenSeconds(_appUri);
      };

      Uri uri = Uri.parse('${clientConfig.notificationSocketUri}?token=$token');

      await webSocketClient.connect(uri).then((_) {
        log.info('WebSocketClient connect succeeded - NotificationSocket up');
        uiLoading.addLoadingMessage('Websocket connected OK');

        final service.CallFlowControl callFlowControl =
            new service.CallFlowControl(
                clientConfig.callFlowServerUri, token, new transport.Client());
        final service.NotificationService notificationService =
            new service.NotificationService(clientConfig.notificationServerUri,
                token, new transport.Client());
        final service.RESTUserStore userService = new service.RESTUserStore(
            clientConfig.userServerUri, token, new transport.Client());

        final controller.User userController = new controller.User(
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
          appState.changeState(ui_model.AppState.ready);
        }).catchError((error) {
          log.shout('Loading of app failed with $error');
          appState.changeState(ui_model.AppState.error);
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
    appState.changeState(ui_model.AppState.error);
    await restartAppInTenSeconds(_appUri);
  }
}

/**
 * Return the configuration object for the client.
 */
Future<model.ClientConfiguration> getClientConfiguration(Uri configUri) async {
  service.RESTConfiguration configService =
      new service.RESTConfiguration(configUri, new transport.Client());

  try {
    return await configService
        .clientConfig()
        .then((model.ClientConfiguration config) {
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

    // Statement will never be reached as browser should have restarted.
    return null;
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
      map = lang.da;
      break;
    case 'en':
      map = lang.en;
      break;
    default:
      map = lang.en;
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
Future<model.User> getUser(Uri authServerUri, String token) {
  service.Authentication authService =
      new service.Authentication(authServerUri, token, new transport.Client());

  return authService.userOf(token);
}

/**
 * Load call state for current user.
 */
Future loadCallState(
    service.CallFlowControl callFlowControl, ui_model.AppClientState appState) {
  return callFlowControl.callList().then((Iterable<model.Call> calls) {
    model.Call myActiveCall = calls.firstWhere(
        (model.Call call) =>
            call.assignedTo == appState.currentUser.id &&
            call.state == model.CallState.speaking,
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
    controller.User userController,
    ui_model.AppClientState appState,
    transport.WebSocketClient webSocketClient,
    controller.Notification notification) {
  /// Make sure we don't steal focus from widgets with mouseclicks on
  /// non-widget elements. This is simply done by searching for the
  /// "ignoreclickfocus" attribute and ignoring mousedown events for those
  /// elements.
  document.onMouseDown.listen((MouseEvent event) {
    final HtmlElement element = event.target;

    if (element.attributes.keys.contains('ignoreclickfocus')) {
      event.preventDefault();
    }
  });

  windowOnBeforeUnload = window.onBeforeUnload.listen((Event event) {
    final BeforeUnloadEvent bfuEvent = event;

    bfuEvent.returnValue = '';
  });

  windowOnUnload = window.onUnload.listen((_) {
    webSocketClient.close();
  });

  controller.Navigate navigate = new controller.Navigate();
  navigate.onGo.listen((controller.Destination destination) {
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
 * Register the [view.ORCDisaster] and [view.ORCLoading] app view objects.
 */
void registerDisasterAndLoadingViews(ui_model.AppClientState appState) {
  appDisaster = new view.ORCDisaster(appState, uiDisaster);
  appLoading = new view.ORCLoading(appState, uiLoading);
}

/**
 * Register the [view.ORCReady] app view object.
 * NOTE: This depends on [clientConfig] being set.
 */
Future registerReadyView(
    ui_model.AppClientState appState,
    model.ClientConfiguration clientConfig,
    controller.User controllerUser,
    service.CallFlowControl callFlowControl,
    controller.Notification notification,
    Map<String, String> langMap,
    String token,
    transport.WebSocketClient webSocketClient) {
  ui_model.UIORCReady uiReady = new ui_model.UIORCReady('orc-ready');

  service.RESTCalendarStore calendarStore = new service.RESTCalendarStore(
      clientConfig.calendarServerUri, token, new transport.Client());
  service.RESTContactStore contactStore = new service.RESTContactStore(
      clientConfig.contactServerUri, token, new transport.Client());
  service.RESTMessageStore messageStore = new service.RESTMessageStore(
      clientConfig.messageServerUri, token, new transport.Client());
  controller.Message messageController =
      new controller.Message(messageStore, appState.currentUser);
  service.RESTReceptionStore receptionStore = new service.RESTReceptionStore(
      clientConfig.receptionServerUri, token, new transport.Client());
  controller.Reception receptionController =
      new controller.Reception(receptionStore);
  controller.Calendar calendarController =
      new controller.Calendar(calendarStore, appState.currentUser);
  controller.Call callController =
      new controller.Call(callFlowControl, appState);

  controller.Popup popup = new controller.Popup(
      new Uri.file('/images/popup_error.png'),
      new Uri.file('/images/popup_info.png'),
      new Uri.file('/images/popup_success.png'));

  controller.Sound sound =
      new controller.Sound(querySelector('audio.sound-pling'));

  observers(controllerUser, appState, webSocketClient, notification);

  return receptionController
      .list()
      .then((Iterable<model.ReceptionReference> receptions) {
    Iterable<model.ReceptionReference> sortedReceptions = receptions.toList()
      ..sort((x, y) => x.name.toLowerCase().compareTo(y.name.toLowerCase()));

    appReady = new view.ORCReady(
        appState,
        uiReady,
        calendarController,
        clientConfig,
        new controller.Contact(contactStore, notification),
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
    await windowOnBeforeUnload.cancel();
  }

  if (windowOnUnload != null) {
    await windowOnUnload.cancel();
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
