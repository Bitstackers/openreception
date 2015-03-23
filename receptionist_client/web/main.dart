import 'dart:html';

import 'classes/navigation.dart';
import 'view/view.dart';

void main() {
  AgentInfo             agentInfo             = new AgentInfo();
  CalendarEditor        calendarEditor        = new CalendarEditor();
  Contexts              contexts              = new Contexts();
  ContextSwitcher       contextSwitcher       = new ContextSwitcher();
  ContactCalendar       contactCalendar       = new ContactCalendar();
  ContactData           contactData           = new ContactData();
  ContactList           contactList           = new ContactList();
  GlobalCallQueue       globalCallQueue       = new GlobalCallQueue();
  MessageCompose        messageCompose        = new MessageCompose();
  MyCallQueue           myCallQueue           = new MyCallQueue();
  ReceptionCalendar     receptionCalendar     = new ReceptionCalendar();
  ReceptionCommands     receptionCommands     = new ReceptionCommands();
  ReceptionOpeningHours receptionOpeningHours = new ReceptionOpeningHours();
  ReceptionProduct      receptionProduct      = new ReceptionProduct();
  ReceptionSalesCalls   receptionSalesCalls   = new ReceptionSalesCalls();
  ReceptionSelector     receptionSelector     = new ReceptionSelector();
  WelcomeMessage        welcomeMessage        = new WelcomeMessage();
  Navigate              navigate              = new Navigate();

  if(window.location.hash.isEmpty) {
    navigate.goHome();
  } else {
    navigate.goWindowLocation();
  }
}
