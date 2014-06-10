import 'dart:html';

import 'contact-view.dart' as conView;
import 'dialplan-view.dart' as diaView;
import 'organization-view.dart' as orgView;
import 'reception-view.dart' as recepView;
import 'record-view.dart' as recordView;
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
    new Menu(querySelector('nav#navigation'));
  }
}
