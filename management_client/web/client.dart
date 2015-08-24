import 'dart:html';

import 'views/contact-view.dart' as conView;
import 'views/billing-view.dart' as billView;
import 'views/dialplan-view.dart' as diaView;
import 'views/music-view.dart' as musicView;
import 'views/organization-view.dart' as orgView;
import 'views/reception-view.dart' as recepView;
import 'views/record-view.dart' as recordView;
import 'views/user-view.dart' as userView;
import 'menu.dart';
import 'lib/controller.dart' as Controller;
import 'lib/auth.dart';
import 'notification.dart' as notify;
import 'lib/configuration.dart';


import 'package:openreception_framework/service.dart' as ORService;
import 'package:openreception_framework/service-html.dart' as Transport;

void main() {
  if(handleToken()) {

    final Transport.Client client = new Transport.Client();
    final ORService.RESTUserStore _userStore = new ORService.RESTUserStore(
        config.userURI, 'feedabbadeadbeef0', client);


    final Controller.User userController = new Controller.User(_userStore);


    ORService.RESTCDRService _cdrStore = new ORService.RESTCDRService (
        config.cdrURI, config.token, client);

    ORService.RESTReceptionStore _receptionStore = new ORService.RESTReceptionStore(
        config.receptionURI, config.token, client);

    ORService.RESTOrganizationStore _organizationStore =
        new ORService.RESTOrganizationStore(
            config.receptionURI, config.token, client);

    Controller.Reception receptionController =
        new Controller.Reception(_receptionStore);

    Controller.Organization organizationController =
        new Controller.Organization(_organizationStore);

    ORService.RESTContactStore _contactStore = new ORService.RESTContactStore(
        Uri.parse('http://localhost:4010'), config.token, client);

    Controller.Contact contactController =
        new Controller.Contact(_contactStore);

    Controller.Calendar calendarController =
        new Controller.Calendar(_contactStore, _receptionStore);

    Controller.CDR cdrController =
        new Controller.CDR(_cdrStore);

    //Initializes the notification system.
    notify.initialize();
    new orgView.OrganizationView(querySelector('#organization-page'),
        organizationController, receptionController);
    new recepView.ReceptionView(querySelector('#reception-page'),
        contactController, organizationController, receptionController);
    new conView.ContactView(querySelector('#contact-page'), contactController,
        organizationController, receptionController, calendarController,
        dlistController, epController);
//    new diaView.DialplanView(
//        querySelector('#dialplan-page'), receptionController);
//    new recordView.RecordView(
//        querySelector('#record-page'), receptionController);
    new userView.UserView(querySelector('#user-page'), userController);
    new billView.BillingView(querySelector('#billing-page'), cdrController);
//    new musicView.MusicView(querySelector('#music-page'));
    new Menu(querySelector('nav#navigation'));
  }
}
