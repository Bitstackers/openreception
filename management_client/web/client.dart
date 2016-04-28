import 'dart:async';
import 'dart:html';

import 'package:logging/logging.dart';
import 'package:route_hierarchical/client.dart';

///Pages
import 'package:management_tool/page.dart' as page;
import 'package:management_tool/page/page-dialplan.dart' as page;
import 'package:management_tool/page/page-ivr.dart' as page;
import 'package:management_tool/page/page-message.dart' as page;
import 'package:management_tool/page/page-reception.dart' as page;
import 'package:management_tool/page/page-user.dart' as page;

import 'package:management_tool/controller.dart' as controller;
import 'package:management_tool/configuration.dart';

import 'package:openreception.framework/service.dart' as service;
import 'package:openreception.framework/storage.dart' as storage;
import 'package:openreception.framework/service-html.dart' as transport;

controller.Popup notify = controller.popup;

/**
 * Sends the user to the login site.
 */
void loginRedirect() {
  String loginUrl =
      '${config.clientConfig.authServerUri}/token/create?returnurl=${window.location}';
  window.location.assign(loginUrl);
}

Future main() async {
  /// Read token from GET parameters
  Uri clientUri = Uri.parse(window.location.href);
  if (clientUri.queryParameters.containsKey('settoken')) {
    config.token = clientUri.queryParameters['settoken'];
  }

  if (clientUri.queryParameters.containsKey('config_server')) {
    config.configUri = Uri.parse(clientUri.queryParameters['config_server']);
  }

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);
  Logger _log = Logger.root;

  PreElement loadingLog = querySelector('#loading-log');

  ProgressElement loadingProgress = querySelector('#loading-progress');

  loadingProgress.max = 10;
  loadingProgress.value = 0;
  final transport.Client client = new transport.Client();
  loadingLog.text += 'Henter konfiguration fra ${config.configUri}\n';
  config.clientConfig =
      await (new service.RESTConfiguration(config.configUri, client))
          .clientConfig();

  /// Check token.
  if (config.token.isNotEmpty) {
    loadingLog.text += 'Validerer eksistende token\n';
    loadingProgress.value++;
    try {
      config.user = await new service.Authentication(
              config.clientConfig.authServerUri, config.token, client)
          .userOf(config.token);
      controller.popup
          .success('Login godkendt', 'Loggede ind som ${config.user.name}');
    } on storage.NotFound {
      controller.popup.info('Token udløbet', 'Log ind igen');
      loginRedirect();
    }
  } else {
    controller.popup.info('Igen token fundet', 'Log ind');
    loginRedirect();
  }

  /// Install handler for taking care of token expirations
  controller.onForbidden = () {
    controller.popup.info('Token udløbet', 'Logger ind igen');
    loginRedirect();
  };

  loadingLog.text += 'Initialiserer lagring\n';
  loadingProgress.value++;

  /// Initialize the stores.
  final service.RESTUserStore userStore = new service.RESTUserStore(
      config.clientConfig.userServerUri, config.token, client);

  final service.RESTReceptionStore receptionStore =
      new service.RESTReceptionStore(
          config.clientConfig.receptionServerUri, config.token, client);
  final service.RESTOrganizationStore organizationStore =
      new service.RESTOrganizationStore(
          config.clientConfig.receptionServerUri, config.token, client);
  final service.RESTContactStore contactStore = new service.RESTContactStore(
      config.clientConfig.contactServerUri, config.token, client);
  final service.RESTCalendarStore calendarStore = new service.RESTCalendarStore(
      config.clientConfig.calendarServerUri, config.token, client);
  final service.RESTDialplanStore dialplanStore = new service.RESTDialplanStore(
      config.clientConfig.dialplanServerUri, config.token, client);
  final service.RESTIvrStore ivrStore = new service.RESTIvrStore(
      config.clientConfig.dialplanServerUri, config.token, client);

  final service.RESTMessageStore messageStore = new service.RESTMessageStore(
      config.clientConfig.messageServerUri, config.token, client);

  final transport.WebSocketClient _websocket = new transport.WebSocketClient();

  loadingLog.text += 'Forbinder websocket\n';
  loadingProgress.value++;

  await _websocket.connect(Uri.parse(
      config.clientConfig.notificationSocketUri.toString() +
          '?token=' +
          config.token));
  final service.NotificationSocket notification =
      new service.NotificationSocket(_websocket);

  /// Controllers

  final controller.Notification notificationController =
      new controller.Notification(notification, config.user);

  final controller.User userController =
      new controller.User(userStore, config.user);

  final controller.Cdr cdrController =
      new controller.Cdr(config.clientConfig.cdrServerUri, config.token);
  final controller.Reception receptionController =
      new controller.Reception(receptionStore, config.user);
  final controller.Organization organizationController =
      new controller.Organization(organizationStore, config.user);
  final controller.Contact contactController =
      new controller.Contact(contactStore, config.user);
  final controller.Calendar calendarController =
      new controller.Calendar(calendarStore, config.user);
  final controller.Dialplan dialplanController =
      new controller.Dialplan(dialplanStore, receptionStore);
  final controller.Message messageController =
      new controller.Message(messageStore, config.user);

  final controller.Ivr ivrController =
      new controller.Ivr(ivrStore, dialplanStore);

  loadingLog.text += 'Indlæser sider\n';
  loadingProgress.value++;

  /**
   * Initialize pages
   */
  final Router router = new Router();
  final page.Cdr cdrPage = new page.Cdr(cdrController, contactController,
      organizationController, receptionController, userController, router);

  final page.OrganizationView orgPage = new page.OrganizationView(
      organizationController, receptionController, router);

  querySelector('#cdr-page').replaceWith(cdrPage.element);

  querySelector("#organization-page").replaceWith(orgPage.element);

  querySelector("#reception-page").replaceWith(new page.ReceptionView(
          contactController,
          organizationController,
          receptionController,
          dialplanController,
          calendarController,
          router)
      .element);

  new page.ContactView(querySelector('#contact-page'), contactController,
      receptionController, calendarController, notificationController, router);

  final messagePage = new page.Message(contactController, messageController,
      receptionController, userController, router);
  final dialplanPage = new page.Dialplan(dialplanController, router);

  querySelector('#message-page').replaceWith(messagePage.element);
  querySelector('#dialplan-page').replaceWith(dialplanPage.element);

  querySelector('#ivr-page')
      .replaceWith(new page.Ivr(ivrController, router).element);
  querySelector("#user-page")
      .replaceWith(new page.UserPage(userController, router).element);

  //new Menu(querySelector('nav#navigation'));

  loadingLog.text += 'Undersøger HTML5 understøttelse\n';
  loadingProgress.value++;

  /// Verify that we support HTMl5 notifications
  if (Notification.supported) {
    Notification
        .requestPermission()
        .then((String perm) => _log.info('HTML5 permission ${perm}'));
  } else {
    _log.shout('HTML5 notifications not supported.');
  }

  loadingLog.text += 'Starter router\n';
  loadingProgress.value++;

  router.listen();

  loadingLog.text += 'Navigerer til startside\n';
  loadingProgress.value = loadingProgress.max;

  router.gotoUrl(window.location.toString());

  await new Future.delayed(new Duration(seconds: 1));

  /// Show the main UI
  querySelector('#loading-screen').hidden = true;
  querySelector('#navigation').hidden = false;
  querySelector('#page-main-screen').hidden = false;
}
