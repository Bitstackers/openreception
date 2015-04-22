/*                  This file is part of OpenReception
                   Copyright (C) 2012-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library bob_active;

import 'dart:html';

import 'constants.dart';
import 'context.dart';
import 'events.dart' as event;
import 'commands-keyboard.dart';
import 'location.dart' as nav;
import 'state.dart';
import '../view.nonflex/view.dart' as View;
import '../model/model.dart' as Model;
import '../service/service.dart' as Service;

import 'package:logging/logging.dart';

class BobActive {
  DivElement element;

  View.WelcomeMessage welcomeMessage;
  View.AgentInfo agentInfo;
  View.ReceptionSelector receptionSelector;

  View.ReceptionHandling receptionHandling;
  View.ReceptionOpeningHours receptionOpeningHours;
  View.ReceptionSalesCalls receptionSalesCalls;
  View.ReceptionProduct receptionProduct;
  View.ReceptionCustomerType receptionCustomerType;
  View.ReceptionTelephoneNumbers receptionTelephoneNumbers;
  View.ReceptionAddresses receptionAddresses;
  View.ReceptionAlternateNames receptionAlternateNames;
  View.ReceptionBankingInformation receptionBankingInfomation;
  View.ReceptionEmailAddresses receptionEmailAddresses;
  View.ReceptionWebsites receptionWebsites;
  View.ReceptionRegistrationNumber receptionRegistrationNumber;
  View.ReceptionExtraInformation receptionExtraInformation;
  View.Contact contactInfo;
  View.ContactCalendar contactCalendar;
  View.CallList globalCallQueue;
  View.CallManagement callManagement;
  //LocalQueue localQueue;

  View.ContextSwitcher contextSwitcher;
  View.ReceptionCalendar receptionEvents;
  View.Message messageCompose;

  View.MessageFilter messageSearch;
  View.MessageList messageList;
  View.MessageEdit messageEdit;

  View.LogBox logBox;

  Context homeContext;
  Context homePlusContext;
  Context messageContext;
  Context logContext;
  Context statistics;
  Context phone;
  Context voicemails;

  Model.CallList callList = new Model.CallList (Service.Notification.instance);

  BobActive(DivElement this.element) {
    element.classes.remove(CssClass.hidden);

    event.bus.on(event.stateUpdated).listen((State value) {
      element.classes.toggle(CssClass.hidden, !value.isOK);
    });

    callList.reloadFromServer(Service.Call.instance);

    registerContexts();
    contextSwitcher          = new View.ContextSwitcher(querySelector('#${Id.contextSwitcher}'), [homeContext, homePlusContext, messageContext]);

    /// Home context
    contactInfo              = new View.Contact(querySelector('#${Id.contactSelector}'), homeContext);
    contactCalendar          = new View.ContactCalendar(querySelector('#${Id.contactCalendar}'), homeContext,
        new Model.ContactCalendar (Service.Notification.instance));

    messageCompose           = new View.Message(querySelector('#${Id.messageCompose}'), homeContext);
    welcomeMessage           = new View.WelcomeMessage(querySelector('#${Id.welcomeMessage}'));
    agentInfo                = new View.AgentInfo(querySelector('#${Id.agentInfo}'), Model.User.currentUser);
    receptionSelector        = new View.ReceptionSelector(querySelector('#${Id.receptionSelector}'), homeContext)
                                      ..onSelectReception = messageCompose.callerNameField.focus;
    receptionEvents          = new View.ReceptionCalendar(querySelector('#${Id.receptionEvents}'), homeContext);
    receptionHandling        = new View.ReceptionHandling(querySelector('#${Id.receptionHandling}'), homeContext);
    receptionOpeningHours    = new View.ReceptionOpeningHours(querySelector('#${Id.receptionOpeningHours}'), homeContext);
    receptionSalesCalls      = new View.ReceptionSalesCalls(querySelector('#${Id.receptionSalesCalls}'), homeContext);
    receptionProduct         = new View.ReceptionProduct(querySelector('#${Id.receptionProduct}'), homeContext);
    globalCallQueue          = new View.CallList(querySelector('#${Id.globalCallQueue}'), homeContext, callList);
    callManagement           = new View.CallManagement(querySelector('#${Id.callOriginate}'), homeContext);
    //localQueue               = new LocalQueue(querySelector('#${id.LOCAL_QUEUE}'), home);

    /// Home Plus context
    receptionCustomerType       = new View.ReceptionCustomerType(querySelector('#${Id.receptionCustomerType}'), homePlusContext);
    receptionTelephoneNumbers   = new View.ReceptionTelephoneNumbers(querySelector('#${Id.receptionTelephoneNumbers}'), homePlusContext);
    receptionAddresses          = new View.ReceptionAddresses(querySelector('#${Id.receptionAddresses}'), homeContext);
    receptionAlternateNames     = new View.ReceptionAlternateNames(querySelector('#${Id.receptionAlternateNames}'), homePlusContext);
    receptionBankingInfomation  = new View.ReceptionBankingInformation(querySelector('#${Id.receptionBankingInformation}'), homePlusContext);
    receptionEmailAddresses     = new View.ReceptionEmailAddresses(querySelector('#${Id.receptionEmailAddresses}'), homePlusContext);
    receptionWebsites           = new View.ReceptionWebsites(querySelector('#${Id.receptionWebsites}'), homePlusContext);
    receptionRegistrationNumber = new View.ReceptionRegistrationNumber(querySelector('#${Id.receptionRegistrationNumber}'), homePlusContext);
    receptionExtraInformation   = new View.ReceptionExtraInformation(querySelector('#${Id.receptionExtraInformation}'), homePlusContext);

    /// Message context
    messageSearch = new View.MessageFilter(querySelector('#${Id.messageSearch}'), messageContext);
    messageList   = new View.MessageList(querySelector('#${Id.messageOverview}'), messageContext);
    messageEdit   = new View.MessageEdit(querySelector('#${Id.messageEdit}'), messageContext);

    logBox = new View.LogBox(querySelector('#${Id.logBox}'), callList);

    //Don't remove. Objects are lazily loaded and no one else access keyboardHandler.
    keyboardHandler.toString();

    //TODO move this to Bob.dart when we have no dynamic default elements.
    nav.initialize();

  }

  void registerContexts() {
    homeContext       = new Context(querySelector('#${Id.contextHome}'))
      ..lastFocusId = '${Id.receptionSelectorSearchbar}';
    homePlusContext   = new Context(querySelector('#${Id.contextHomeplus}'))
        ..lastFocusId = '${Id.receptionCustomerTypeBody}';
    messageContext   = new Context(querySelector('#${Id.contextMessages}'))
      ..lastFocusId = 'message-search-agent-searchbar';
//    logContext        = new Context(querySelector('#${Id.CONTEXT_LOG}'));
  }

}
