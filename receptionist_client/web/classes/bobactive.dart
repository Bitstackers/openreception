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
import 'commands.keyboard.dart';
import 'location.dart' as nav;
//import 'logger.dart';
import 'state.dart';
import '../view/view.dart' as View;
import '../model/model.dart' as Model;
import 'package:logging/logging.dart';

class BobActive {
  DivElement element;

  View.WelcomeMessage welcomeMessage;
  View.AgentInfo agentInfo;
  View.ReceptionSelector receptionSelector;

  View.ReceptionHandling companyHandling;
  View.ReceptionOpeningHours receptionOpeningHours;
  View.ReceptionSalesCalls receptionSalesCalls;
  View.ReceptionProduct receptionProduct;
  View.ReceptionCustomerType receptionCustomerType;
  View.ReceptionTelephoneNumbers companyTelephoneNumbers;
  View.ReceptionAddresses receptionAddresses;
  View.ReceptionAlternateNames companyAlternateNames;
  View.ReceptionBankingInformation companyBankingInfomation;
  View.ReceptionEmailAddresses receptionEmailAddresses;
  View.ReceptionWebsites receptionWebsites;
  View.ReceptionRegistrationNumber compayRegistrationNumber;
  View.ReceptionExtraInformation receptionExtraInformation;
  View.Contact contactInfo;
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

  BobActive(DivElement this.element) {
    Logger.root.onRecord.listen (print);
    Logger.root.level = Level.INFO;

    element.classes.remove('hidden');

    event.bus.on(event.stateUpdated).listen((State value) {
      element.classes.toggle('hidden', !value.isOK);
    });

    registerContexts();
    contextSwitcher          = new View.ContextSwitcher(querySelector('#${Id.contextSwitcher}'), [homeContext, homePlusContext, messageContext]);

    /// Home context
    contactInfo              = new View.Contact(querySelector('#${Id.contactSelector}'), homeContext);


    messageCompose           = new View.Message(querySelector('#message-compose'), homeContext);
    welcomeMessage           = new View.WelcomeMessage(querySelector('#${Id.WELCOME_MESSAGE}'));
    agentInfo                = new View.AgentInfo(querySelector('#${Id.AGENT_INFO}'));
    receptionSelector        = new View.ReceptionSelector(querySelector('#${Id.receptionSelector}'), homeContext)
                                      ..onSelectReception = messageCompose.callerNameField.focus;
    receptionEvents          = new View.ReceptionCalendar(querySelector('#${Id.receptionEvents}'), homeContext);
    companyHandling          = new View.ReceptionHandling(querySelector('#${Id.companyHandling}'), homeContext);
    receptionOpeningHours    = new View.ReceptionOpeningHours(querySelector('#${Id.receptionOpeningHours}'), homeContext);
    receptionSalesCalls      = new View.ReceptionSalesCalls(querySelector('#${Id.receptionSalesCalls}'), homeContext);
    receptionProduct         = new View.ReceptionProduct(querySelector('#${Id.receptionProduct}'), homeContext);
    globalCallQueue          = new View.CallList(querySelector('#${Id.globalCallQueue}'), homeContext);
    callManagement           = new View.CallManagement(querySelector('#${Id.CALL_ORIGINATE}'), homeContext);
    //localQueue               = new LocalQueue(querySelector('#${id.LOCAL_QUEUE}'), home);

    /// Home Plus context
    receptionCustomerType     = new View.ReceptionCustomerType(querySelector('#${Id.receptionCustomerType}'), homePlusContext);
    companyTelephoneNumbers   = new View.ReceptionTelephoneNumbers(querySelector('#${Id.COMPANY_TELEPHONE_NUMBERS}'), homePlusContext);
    receptionAddresses        = new View.ReceptionAddresses(querySelector('#${Id.receptionAddresses}'), homeContext);
    companyAlternateNames     = new View.ReceptionAlternateNames(querySelector('#${Id.COMPANY_ALTERNATENAMES}'), homePlusContext);
    companyBankingInfomation  = new View.ReceptionBankingInformation(querySelector('#${Id.COMPANY_BANKING_INFORMATION}'), homePlusContext);
    receptionEmailAddresses   = new View.ReceptionEmailAddresses(querySelector('#${Id.receptionEmailAddresses}'), homePlusContext);
    receptionWebsites         = new View.ReceptionWebsites(querySelector('#${Id.receptionWebsites}'), homePlusContext);
    compayRegistrationNumber  = new View.ReceptionRegistrationNumber(querySelector('#${Id.COMPANY_REGISTRATION_NUMBER}'), homePlusContext);
    receptionExtraInformation = new View.ReceptionExtraInformation(querySelector('#${Id.receptionExtraInformation}'), homePlusContext);

    /// Message context
    messageSearch = new View.MessageFilter(querySelector('#${Id.MESSAGE_SEARCH}'), messageContext);
    messageList   = new View.MessageList(querySelector('#${Id.MESSAGE_OVERVIEW}'), messageContext);
    messageEdit   = new View.MessageEdit(querySelector('#${Id.MESSAGE_EDIT}'), messageContext);

    logBox = new View.LogBox(querySelector('#${Id.LOGBOX}'));

    //Don't remove. Objects are lazily loaded and no one else access keyboardHandler.
    keyboardHandler.toString();

    //TODO move this to Bob.dart when we have no dynamic default elements.
    nav.initialize();
    Model.CalendarEvent.registerObservers();
    Model.MessageList.instance.registerObservers();
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
