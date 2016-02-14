import 'dart:async';
import 'dart:html';

import 'views/contact-view.dart' as conView;
import 'package:management_tool/page/page-calendar.dart' as page;

import 'package:management_tool/page/page-dialplan.dart' as page;
import 'package:management_tool/page/page-organization.dart' as orgView;
import 'package:management_tool/page/page-reception.dart' as recepView;
import 'package:management_tool/page/page-user.dart' as userView;
import 'menu.dart';
import 'package:management_tool/controller.dart' as Controller;
import 'lib/auth.dart';
import 'package:management_tool/notification.dart' as notify;
import 'package:management_tool/configuration.dart';
import 'package:logging/logging.dart';

import 'package:openreception_framework/service.dart' as service;
import 'package:openreception_framework/service-html.dart' as transport;

Future main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  final transport.Client client = new transport.Client();
  config.clientConfig =
      await (new service.RESTConfiguration(config.configUri, client))
          .clientConfig();

  if (handleToken()) {
    /// Initialize the stores.
    final service.RESTUserStore userStore = new service.RESTUserStore(
        config.clientConfig.userServerUri, config.token, client);
    final service.RESTDistributionListStore dlistStore =
        new service.RESTDistributionListStore(
            config.clientConfig.contactServerUri, config.token, client);
    final service.RESTEndpointStore epStore = new service.RESTEndpointStore(
        config.clientConfig.contactServerUri, config.token, client);
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

    /// Controllers
    final Controller.User userController = new Controller.User(userStore);
    final Controller.DistributionList dlistController =
        new Controller.DistributionList(dlistStore);
    final Controller.Endpoint epController = new Controller.Endpoint(epStore);
    final Controller.Reception receptionController =
        new Controller.Reception(receptionStore);
    final Controller.Organization organizationController =
        new Controller.Organization(organizationStore);
    final Controller.Contact contactController =
        new Controller.Contact(contactStore);
    final Controller.Calendar calendarController =
        new Controller.Calendar(calendarStore);
    final Controller.Dialplan dialplanController =
        new Controller.Dialplan(dialplanStore);
    //Initializes the notification system.
    notify.initialize();

    final orgView.OrganizationView orgPage = new orgView.OrganizationView(
        organizationController, receptionController);

    querySelector("#organization-page").replaceWith(orgPage.element);

    querySelector("#reception-page").replaceWith(new recepView.ReceptionView(
            contactController, organizationController, receptionController)
        .element);

    new conView.ContactView(
        querySelector('#contact-page'),
        contactController,
        organizationController,
        receptionController,
        calendarController,
        dlistController,
        epController);

    querySelector('#calendar-page').replaceWith(new page.Calendar(
            userController,
            calendarController,
            contactController,
            receptionController)
        .element);
    querySelector('#dialplan-page')
        .replaceWith(new page.Dialplan(dialplanController).element);
    querySelector("#user-page")
        .replaceWith(new userView.UserPage(userController).element);
//    new billView.BillingView(querySelector('#billing-page'), cdrController);
//    new musicView.MusicView(querySelector('#music-page'));
    new Menu(querySelector('nav#navigation'));
  }
}
