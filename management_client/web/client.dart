import 'dart:async';
import 'dart:html';

import 'package:logging/logging.dart';

///Pages
import 'package:management_tool/page/page-contact.dart' as page;
import 'package:management_tool/page/page-dialplan.dart' as page;
import 'package:management_tool/page/page-cdr.dart' as page;
import 'package:management_tool/page/page-ivr.dart' as page;
import 'package:management_tool/page/page-message.dart' as page;
import 'package:management_tool/page/page-organization.dart' as page;
import 'package:management_tool/page/page-reception.dart' as page;
import 'package:management_tool/page/page-user.dart' as page;
import 'package:management_tool/controller.dart' as controller;
import 'package:management_tool/auth.dart';
import 'package:management_tool/configuration.dart';
import 'menu.dart';

import 'package:openreception_framework/service.dart' as service;
import 'package:openreception_framework/service-html.dart' as transport;

controller.Popup notify = controller.popup;

Future main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);
  Logger _log = Logger.root;

  final transport.Client client = new transport.Client();
  config.clientConfig =
      await (new service.RESTConfiguration(config.configUri, client))
          .clientConfig();

  if (handleToken()) {
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
    final service.RESTCalendarStore calendarStore =
        new service.RESTCalendarStore(
            config.clientConfig.calendarServerUri, config.token, client);
    final service.RESTDialplanStore dialplanStore =
        new service.RESTDialplanStore(
            config.clientConfig.dialplanServerUri, config.token, client);
    final service.RESTIvrStore ivrStore = new service.RESTIvrStore(
        config.clientConfig.dialplanServerUri, config.token, client);

    final service.RESTMessageStore messageStore = new service.RESTMessageStore(
        config.clientConfig.messageServerUri, config.token, client);

    final transport.WebSocketClient _websocket =
        new transport.WebSocketClient();

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

    final page.Cdr cdrPage =
        new page.Cdr(cdrController, organizationController);

    final page.OrganizationView orgPage =
        new page.OrganizationView(organizationController, receptionController);

    querySelector('#cdr-page').replaceWith(cdrPage.element);

    querySelector("#organization-page").replaceWith(orgPage.element);

    querySelector("#reception-page").replaceWith(new page.ReceptionView(
            contactController,
            organizationController,
            receptionController,
            dialplanController,
            calendarController)
        .element);

    new page.ContactView(querySelector('#contact-page'), contactController,
        receptionController, calendarController, notificationController);

    final messagePage = new page.Message(contactController, messageController,
        receptionController, userController);
    final dialplanPage = new page.Dialplan(dialplanController);

    querySelector('#message-page').replaceWith(messagePage.element);
    querySelector('#dialplan-page').replaceWith(dialplanPage.element);

    querySelector('#ivr-page').replaceWith(new page.Ivr(ivrController).element);
    querySelector("#user-page")
        .replaceWith(new page.UserPage(userController).element);

    new Menu(querySelector('nav#navigation'));

    /// Verify that we support HTMl5 notifications
    if (Notification.supported) {
      Notification
          .requestPermission()
          .then((String perm) => _log.info('HTML5 permission ${perm}'));
    } else {
      _log.shout('HTML5 notifications not supported.');
    }
  }
}
