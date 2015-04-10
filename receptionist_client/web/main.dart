import 'dart:html';

import 'controller/controller.dart';
import 'model/model.dart';
import 'view/view.dart';

void main() {
  Contexts contexts = new Contexts(new UIContexts());

  AgentInfo agentInfo = new AgentInfo(new UIAgentInfo(querySelector('#agent-info')));

  ContactSelector contactSelector =
        new ContactSelector(new UIContactSelector(querySelector('#contact-selector')),
                            new Place(Context.Home, Widget.ContactSelector));

  ContactCalendar contactCalendar =
      new ContactCalendar(new UIContactCalendar(querySelector('#contact-calendar')),
                          new Place(Context.Home, Widget.ContactCalendar),
                          contactSelector);

  ContactData contactData =
      new ContactData(new UIContactData(querySelector('#contact-data')),
                      new Place(Context.Home, Widget.ContactData),
                      contactSelector);

  CalendarEditor calendarEditor =
        new CalendarEditor (new UICalendarEditor(querySelector('#calendar-editor')),
                            new Place(Context.CalendarEdit, Widget.CalendarEditor));


  ReceptionCalendar receptionCalendar =
      new ReceptionCalendar(new UIReceptionCalendar(querySelector('#reception-calendar')),
                            new Place(Context.Home, Widget.ReceptionCalendar));

  ReceptionCommands receptionCommands =
      new ReceptionCommands(new UIReceptionCommands(querySelector('#reception-commands')),
                            new Place(Context.Home, Widget.ReceptionCommands));

  MessageCompose messageCompose =
      new MessageCompose(new UIMessageCompose(querySelector('#message-compose')),
                         new Place(Context.Home, Widget.MessageCompose));


  Help help = new Help();


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
