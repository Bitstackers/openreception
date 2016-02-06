import 'dart:async';
import 'dart:html';

import 'views/contact-view.dart' as conView;
import 'views/organization-view.dart' as orgView;
import 'views/reception-view.dart' as recepView;
import 'views/user-view.dart' as userView;
import 'menu.dart';
import 'lib/controller.dart' as Controller;
import 'lib/auth.dart';
import 'notification.dart' as notify;
import 'lib/configuration.dart';

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
    final service.RESTReceptionStore receptionStore = new service.RESTReceptionStore(
        config.clientConfig.receptionServerUri, config.token, client);
    final service.RESTOrganizationStore organizationStore =
        new service.RESTOrganizationStore(
            config.clientConfig.receptionServerUri, config.token, client);
    final service.RESTContactStore contactStore = new service.RESTContactStore(
        config.clientConfig.contactServerUri, config.token, client);
    final service.RESTCalendarStore calendarStore = new service.RESTCalendarStore(
        config.clientConfig.calendarServerUri, config.token, client);

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

    //Initializes the notification system.
    notify.initialize();
    new orgView.OrganizationView(querySelector('#organization-page'),
        organizationController, receptionController);
    new recepView.ReceptionView(querySelector('#reception-page'),
        contactController, organizationController, receptionController);
    new conView.ContactView(
        querySelector('#contact-page'),
        contactController,
        organizationController,
        receptionController,
        calendarController,
        dlistController,
        epController);
//    new diaView.DialplanView(
//        querySelector('#dialplan-page'), receptionController);
//    new recordView.RecordView(
//        querySelector('#record-page'), receptionController);
    new userView.UserView(querySelector('#user-page'), userController);
//    new billView.BillingView(querySelector('#billing-page'), cdrController);
//    new musicView.MusicView(querySelector('#music-page'));
    new Menu(querySelector('nav#navigation'));
  }
}
