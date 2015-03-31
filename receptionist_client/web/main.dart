import 'dart:html';

import 'controller/controller.dart' as Controller;
import 'model/model.dart' as Model;
import 'view/view.dart';

void main() {
  Contexts contexts = new Contexts(new Model.UIContexts());

  AgentInfo agentInfo = new AgentInfo(new Model.UIAgentInfo(querySelector('#agent-info')));

  CalendarEditor calendarEditor =
      new CalendarEditor (new Model.UICalendarEditor(querySelector('#calendar-editor')),
                          new Controller.Place('context-calendar-edit', 'calendar-editor'));

  ContactCalendar contactCalendar =
      new ContactCalendar(new Model.UIContactCalendar(querySelector('#contact-calendar')),
                          new Controller.Place('context-home', 'contact-calendar'));

  ContactData contactData =
      new ContactData(new Model.UIContactData(querySelector('#contact-data')),
                      new Controller.Place('context-home', 'contact-data'));

  ContactList contactList =
      new ContactList(new Model.UIContactList(querySelector('#contact-list')),
                      new Controller.Place('context-home', 'contact-list'));

  MessageCompose messageCompose =
      new MessageCompose(new Model.UIMessageCompose(querySelector('#message-compose')),
                         new Controller.Place('context-home', 'message-compose'));

  ReceptionCalendar receptionCalendar =
      new ReceptionCalendar(new Model.UIReceptionCalendar(querySelector('#reception-calendar')),
                            new Controller.Place('context-home', 'reception-calendar'));

  ReceptionCommands receptionCommands =
      new ReceptionCommands(new Model.UIReceptionCommands(querySelector('#reception-commands')),
                            new Controller.Place('context-home', 'reception-commands'));



  GlobalCallQueue       globalCallQueue       = new GlobalCallQueue();
  MyCallQueue           myCallQueue           = new MyCallQueue();
  ReceptionOpeningHours receptionOpeningHours = new ReceptionOpeningHours();
  ReceptionProduct      receptionProduct      = new ReceptionProduct();
  ReceptionSalesCalls   receptionSalesCalls   = new ReceptionSalesCalls();
  ReceptionSelector     receptionSelector     = new ReceptionSelector();
  WelcomeMessage        welcomeMessage        = new WelcomeMessage();
  Controller.Navigate   navigate              = new Controller.Navigate();

  if(window.location.hash.isEmpty) {
    navigate.goHome();
  } else {
    navigate.goWindowLocation();
  }
}
