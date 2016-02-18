import 'dart:async';
import 'dart:html';

import 'views/contact-view.dart' as conView;

import 'package:management_tool/page/page-dialplan.dart' as page;
import 'package:management_tool/page/page-ivr.dart' as page;
import 'package:management_tool/page/page-organization.dart' as orgView;
import 'package:management_tool/page/page-reception.dart' as recepView;
import 'package:management_tool/page/page-user.dart' as userView;
import 'menu.dart';
import 'package:management_tool/controller.dart' as controller;
import 'lib/auth.dart';
import 'package:management_tool/configuration.dart';
import 'package:logging/logging.dart';

import 'package:openreception_framework/service.dart' as service;
import 'package:openreception_framework/service-html.dart' as transport;

controller.Popup notify = controller.popup;

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
    final service.RESTIvrStore ivrStore = new service.RESTIvrStore(
        config.clientConfig.dialplanServerUri, config.token, client);

    /// Controllers
    final controller.User userController = new controller.User(userStore);
    final controller.DistributionList dlistController =
        new controller.DistributionList(dlistStore);
    final controller.Endpoint epController = new controller.Endpoint(epStore);
    final controller.Reception receptionController =
        new controller.Reception(receptionStore);
    final controller.Organization organizationController =
        new controller.Organization(organizationStore);
    final controller.Contact contactController =
        new controller.Contact(contactStore);
    final controller.Calendar calendarController =
        new controller.Calendar(calendarStore);
    final controller.Dialplan dialplanController =
        new controller.Dialplan(dialplanStore, receptionStore);

    final controller.Ivr ivrController =
        new controller.Ivr(ivrStore, dialplanStore);

    final orgView.OrganizationView orgPage = new orgView.OrganizationView(
        organizationController, receptionController);

    querySelector("#organization-page").replaceWith(orgPage.element);

    querySelector("#reception-page").replaceWith(new recepView.ReceptionView(
            contactController,
            organizationController,
            receptionController,
            dialplanController,
            calendarController)
        .element);

    new conView.ContactView(
        querySelector('#contact-page'),
        contactController,
        organizationController,
        receptionController,
        calendarController,
        dlistController,
        epController);

    querySelector('#dialplan-page')
        .replaceWith(new page.Dialplan(dialplanController).element);
    querySelector('#ivr-page').replaceWith(new page.Ivr(ivrController).element);
    querySelector("#user-page")
        .replaceWith(new userView.UserPage(userController).element);

    new Menu(querySelector('nav#navigation'));
  }
}
