import 'dart:html';

import 'controller/controller.dart';
import 'model/model.dart';
import 'view/view.dart';

void main() {
  DomContexts domContexts = new DomContexts();
  Contexts    contexts    = new Contexts(domContexts);

  Place placeAgentInto         = new Place('context-home', 'agent-info');
  Place placeContactCalendar   = new Place('context-home', 'contact-calendar');
  Place placeMessageCompose    = new Place('context-home', 'message-compose');
  Place placeReceptionCalendar = new Place('context-home', 'reception-calendar');
  Place placeReceptionCommands = new Place('context-home', 'reception-commands');

  DomAgentInfo         domAgentInfo         = new DomAgentInfo(querySelector('#agent-info'));
  DomContactCalendar   domContactCalendar   = new DomContactCalendar(querySelector('#contact-calendar'));
  DomMessageCompose    domMessageCompose    = new DomMessageCompose(querySelector('#message-compose'));
  DomReceptionCalendar domReceptionCalendar = new DomReceptionCalendar(querySelector('#reception-calendar'));
  DomReceptionCommands domReceptionCommands = new DomReceptionCommands(querySelector('#reception-commands'));

  AgentInfo         agentInfo         = new AgentInfo(domAgentInfo);
  ContactCalendar   contactCalendar   = new ContactCalendar(domContactCalendar, placeContactCalendar);
  MessageCompose    messageCompose    = new MessageCompose(domMessageCompose, placeMessageCompose);
  ReceptionCalendar receptionCalendar = new ReceptionCalendar(domReceptionCalendar, placeReceptionCalendar);
  ReceptionCommands receptionCommands = new ReceptionCommands(domReceptionCommands, placeReceptionCommands);

  ContactData           contactData           = new ContactData();
  ContactList           contactList           = new ContactList();
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
