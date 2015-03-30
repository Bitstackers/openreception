import 'dart:html';

import 'controller/controller.dart';
import 'model/model.dart';
import 'view/view.dart' as View;

void main() {
  DomContexts domContexts = new DomContexts();
  View.Contexts    contexts    = new View.Contexts(domContexts);

  Place placeAgentInto         = new Place('context-home', 'agent-info');
  Place placeContactCalendar   = new Place('context-home', 'contact-calendar');
  Place placeContactList       = new Place('context-home', 'contact-list');
  Place placeMessageCompose    = new Place('context-home', 'message-compose');
  Place placeReceptionCalendar = new Place('context-home', 'reception-calendar');
  Place placeReceptionCommands = new Place('context-home', 'reception-commands');

  DomAgentInfo         domAgentInfo         = new DomAgentInfo(querySelector('#agent-info'));
  DomContactCalendar   domContactCalendar   = new DomContactCalendar(querySelector('#contact-calendar'));
  DomContactList       domContactList       = new DomContactList(querySelector('#contact-list'));
  DomMessageCompose    domMessageCompose    = new DomMessageCompose(querySelector('#message-compose'));
  DomReceptionCalendar domReceptionCalendar = new DomReceptionCalendar(querySelector('#reception-calendar'));
  DomReceptionCommands domReceptionCommands = new DomReceptionCommands(querySelector('#reception-commands'));

  View.AgentInfo         agentInfo         = new View.AgentInfo(domAgentInfo);
  View. ContactCalendar   contactCalendar  = new View.ContactCalendar(domContactCalendar, placeContactCalendar);
  View.ContactList       contactList       = new View.ContactList(domContactList, placeContactList);
  View.MessageCompose    messageCompose    = new View.MessageCompose(domMessageCompose, placeMessageCompose);
  View.ReceptionCalendar receptionCalendar = new View.ReceptionCalendar(domReceptionCalendar, placeReceptionCalendar);
  View.ReceptionCommands receptionCommands = new View.ReceptionCommands(domReceptionCommands, placeReceptionCommands);

  View.ContactData           contactData           = new View.ContactData();
  View.GlobalCallQueue       globalCallQueue       = new View.GlobalCallQueue();
  View.MyCallQueue           myCallQueue           = new View.MyCallQueue();
  View.ReceptionOpeningHours receptionOpeningHours = new View.ReceptionOpeningHours();
  View.ReceptionProduct      receptionProduct      = new View.ReceptionProduct();
  View.ReceptionSalesCalls   receptionSalesCalls   = new View.ReceptionSalesCalls();
  View.ReceptionSelector     receptionSelector     = new View.ReceptionSelector();
  View.WelcomeMessage        welcomeMessage        = new View.WelcomeMessage();
  Navigate              navigate              = new Navigate();

  if(window.location.hash.isEmpty) {
    navigate.goHome();
  } else {
    navigate.goWindowLocation();
  }
}
