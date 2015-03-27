import 'dart:html';

import 'controller/controller.dart';
import 'model/model.dart';
import 'view/view.dart';

void main() {
  Place            placeMessageCompose = new Place('context-home', 'message-compose');
  UIMessageCompose uiMessageCompose    = new UIMessageCompose(querySelector('#message-compose'));
  MessageCompose   messageCompose      = new MessageCompose(uiMessageCompose, placeMessageCompose);

  Place               placeReceptionCalendar = new Place('context-home', 'reception-calendar');
  UIReceptionCalendar uiReceptionCalendar    = new UIReceptionCalendar(querySelector('#reception-calendar'));
  ReceptionCalendar   receptionCalendar      = new ReceptionCalendar(uiReceptionCalendar, placeReceptionCalendar);

  Place placeReceptionCommands = new Place('context-home', 'reception-commands');
  UIReceptionCommands uiReceptionCommands = new UIReceptionCommands(querySelector('#reception-commands'));
  ReceptionCommands receptionCommands = new ReceptionCommands(uiReceptionCommands, placeReceptionCommands);

  AgentInfo             agentInfo             = new AgentInfo();
  Contexts              contexts              = new Contexts();
  ContactCalendar       contactCalendar       = new ContactCalendar();
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
