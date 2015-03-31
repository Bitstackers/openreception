import 'dart:html';

import 'controller/controller.dart';
import 'model/model.dart';
import 'view/view.dart';

void main() {
  Contexts contexts = new Contexts(new UIContexts());

  AgentInfo agentInfo = new AgentInfo(new UIAgentInfo(querySelector('#agent-info')));

  CalendarEditor calendarEditor =
      new CalendarEditor (new UICalendarEditor(querySelector('#calendar-editor')),
                          new Place('context-calendar-edit', 'calendar-editor'));

  ContactCalendar contactCalendar =
      new ContactCalendar(new UIContactCalendar(querySelector('#contact-calendar')),
                          new Place('context-home', 'contact-calendar'));

  ContactData contactData =
      new ContactData(new UIContactData(querySelector('#contact-data')),
                      new Place('context-home', 'contact-data'));

//  ContactList contactList =
//      new ContactList(new UIContactList(querySelector('#contact-list')),
//                      new Place('context-home', 'contact-list'));
//
//  MessageCompose messageCompose =
//      new MessageCompose(new UIMessageCompose(querySelector('#message-compose')),
//                         new Place('context-home', 'message-compose'));
//
//  ReceptionCalendar receptionCalendar =
//      new ReceptionCalendar(new UIReceptionCalendar(querySelector('#reception-calendar')),
//                            new Place('context-home', 'reception-calendar'));
//
//  ReceptionCommands receptionCommands =
//      new ReceptionCommands(new UIReceptionCommands(querySelector('#reception-commands')),
//                            new Place('context-home', 'reception-commands'));





  GlobalCallQueue       globalCallQueue       = new GlobalCallQueue();
  MyCallQueue           myCallQueue           = new MyCallQueue();
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
