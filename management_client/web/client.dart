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

import 'package:openreception_framework/service.dart' as ORService;
import 'package:openreception_framework/service-html.dart' as Transport;

void main() {
  if(handleToken()) {

    final Transport.Client client = new Transport.Client();
    final ORService.RESTUserStore _userStore = new ORService.RESTUserStore(
        Uri.parse('http://localhost:4030'), 'feedabbadeadbeef0', client);


    final Controller.User userController = new Controller.User(_userStore);


    //Initializes the notification system.
    notify.initialize();
    new orgView.OrganizationView(querySelector('#organization-page'));
    new recepView.ReceptionView(querySelector('#reception-page'));
    new conView.ContactView(querySelector('#contact-page'));
    new diaView.DialplanView(querySelector('#dialplan-page'));
    new recordView.RecordView(querySelector('#record-page'));
    new userView.UserView(querySelector('#user-page'), userController);
    new billView.BillingView(querySelector('#billing-page'));
    new musicView.MusicView(querySelector('#music-page'));
    new Menu(querySelector('nav#navigation'));
  }
}
