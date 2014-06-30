import 'dart:html';

import 'views/contact-view.dart' as conView;
import 'views/dialplan-view.dart' as diaView;
import 'views/organization-view.dart' as orgView;
import 'views/reception-view.dart' as recepView;
import 'views/record-view.dart' as recordView;
import 'views/user-view.dart' as userView;
import 'menu.dart';
import 'lib/auth.dart';
import 'notification.dart' as notify;

void main() {
  if(handleToken()) {
    notify.initialize();
    new orgView.OrganizationView(querySelector('#organization-page'));
    new recepView.ReceptionView(querySelector('#reception-page'));
    new conView.ContactView(querySelector('#contact-page'));
    new diaView.DialplanView(querySelector('#dialplan-page'));
    new recordView.RecordView(querySelector('#record-page'));
    new userView.UserView(querySelector('#user-page'));
    new Menu(querySelector('nav#navigation'));
  }
}
