import 'dart:html';

import 'contact-view.dart' as conView;
import 'dialplan-view.dart' as diaView;
import 'organization-view.dart' as orgView;
import 'reception-view.dart' as recView;
import 'menu.dart';
import 'lib/auth.dart';
import 'notification.dart' as notify;

void main() {
  if(handleToken()) {
    notify.initialize();
//    notify.info('Good morning sir!');
//
//    new Future.delayed(new Duration(milliseconds: 4500)).then((_) {
//      notify.error('What do you mean? \n Do you wish me a good morning, or mean that it is a good morning whether I want it or not; or that you feel good this morning; or that it is a morning to be good on?');
//    });
    new orgView.OrganizationView(querySelector('#organization-page'));
    new recView.ReceptionView(querySelector('#reception-page'));
    new conView.ContactView(querySelector('#contact-page'));
    new diaView.DialplanView(querySelector('#dialplan-page'));
    new Menu(querySelector('nav#navigation'));
  }
}
