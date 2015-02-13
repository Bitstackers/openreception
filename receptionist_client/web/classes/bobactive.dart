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

library BobActive;

import 'dart:html';

import 'constants.dart';
import 'context.dart';
import 'events.dart' as event;
import 'id.dart' as id;
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
  View.ReceptionSelector companySelector;

  View.ReceptionHandling companyHandling;
  View.ReceptionOpeningHours companyOpeningHours;
  View.ReceptionSalesCalls companySalesCalls;
  View.ReceptionProduct companyProduct;
  View.ReceptionCustomerType companyCustomerType;
  View.ReceptionTelephoneNumbers companyTelephoneNumbers;
  View.ReceptionAddresses companyAddresses;
  View.ReceptionAlternateNames companyAlternateNames;
  View.ReceptionBankingInformation companyBankingInfomation;
  View.ReceptionEmailAddresses companyEmailAddresses;
  View.ReceptionWebsites companyWebsites;
  View.ReceptionRegistrationNumber compayRegistrationNumber;
  View.ReceptionOther companyOther;
  View.ContactInfo contactInfo;
  View.CallList globalQueue;
  View.CallManagement callManagement;
  //LocalQueue localQueue;

  View.ContextSwitcher contextSwitcher;
  View.ReceptionEvents receptionEvents;
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
    contextSwitcher          = new View.ContextSwitcher(querySelector('#${ID.CONTEXT_SWITCHER}'), [homeContext, homePlusContext, messageContext]);

    /// Home context
    contactInfo              = new View.ContactInfo(querySelector('#${ID.CONTACT_INFO}'), homeContext);


    messageCompose           = new View.Message(querySelector('#message-compose'), homeContext);
    welcomeMessage           = new View.WelcomeMessage(querySelector('#${ID.WELCOME_MESSAGE}'));
    agentInfo                = new View.AgentInfo(querySelector('#${ID.AGENT_INFO}'));
    companySelector          = new View.ReceptionSelector(querySelector('#${ID.COMPANY_SELECTOR}'), homeContext)
    ..onSelectReception = messageCompose.callerNameField.focus;
    receptionEvents          = new View.ReceptionEvents(querySelector('#${ID.COMPANY_EVENTS}'), homeContext);
    companyHandling          = new View.ReceptionHandling(querySelector('#${ID.COMPANY_HANDLING}'), homeContext);
    companyOpeningHours      = new View.ReceptionOpeningHours(querySelector('#${ID.COMPANY_OPENINGHOURS}'), homeContext);
    companySalesCalls        = new View.ReceptionSalesCalls(querySelector('#${ID.COMPANY_SALESCALLS}'), homeContext);
    companyProduct           = new View.ReceptionProduct(querySelector('#${ID.COMPANY_PRODUCT}'), homeContext);
    globalQueue              = new View.CallList(querySelector('#${ID.GLOBAL_QUEUE}'), homeContext);
    callManagement           = new View.CallManagement(querySelector('#${ID.CALL_ORIGINATE}'), homeContext);
    //localQueue               = new LocalQueue(querySelector('#${id.LOCAL_QUEUE}'), home);

    /// Home Plus context
    companyCustomerType      = new View.ReceptionCustomerType(querySelector('#${ID.COMPANY_CUSTOMERTYPE}'), homePlusContext);
    companyTelephoneNumbers  = new View.ReceptionTelephoneNumbers(querySelector('#${ID.COMPANY_TELEPHONE_NUMBERS}'), homePlusContext);
    companyAddresses         = new View.ReceptionAddresses(querySelector('#${ID.COMPANY_ADDRESSES}'), homeContext);
    companyAlternateNames    = new View.ReceptionAlternateNames(querySelector('#${ID.COMPANY_ALTERNATENAMES}'), homePlusContext);
    companyBankingInfomation = new View.ReceptionBankingInformation(querySelector('#${ID.COMPANY_BANKING_INFORMATION}'), homePlusContext);
    companyEmailAddresses    = new View.ReceptionEmailAddresses(querySelector('#${ID.COMPANY_EMAIL_ADDRESSES}'), homePlusContext);
    companyWebsites          = new View.ReceptionWebsites(querySelector('#${ID.COMPANY_WEBSITES}'), homePlusContext);
    compayRegistrationNumber = new View.ReceptionRegistrationNumber(querySelector('#${ID.COMPANY_REGISTRATION_NUMBER}'), homePlusContext);
    companyOther             = new View.ReceptionOther(querySelector('#${ID.COMPANY_OTHER}'), homePlusContext);

    /// Message context
    messageSearch = new View.MessageFilter(querySelector('#${ID.MESSAGE_SEARCH}'), messageContext);
    messageList   = new View.MessageList(querySelector('#${ID.MESSAGE_OVERVIEW}'), messageContext);
    messageEdit   = new View.MessageEdit(querySelector('#${ID.MESSAGE_EDIT}'), messageContext);

    logBox = new View.LogBox(querySelector('#${ID.LOGBOX}'));

    //Don't remove. Objects are lazily loaded and no one else access keyboardHandler.
    keyboardHandler.toString();

    //TODO move this to Bob.dart when we have no dynamic default elements.
    nav.initialize();
    Model.CalendarEvent.registerObservers();
    Model.MessageList.instance.registerObservers();
  }

  void registerContexts() {
    homeContext       = new Context(querySelector('#contexthome'))
      ..lastFocusId = 'company-selector-searchbar';
    homePlusContext   = new Context(querySelector('#contexthomeplus'))
        ..lastFocusId = 'company-customertype-body';
    messageContext   = new Context(querySelector('#contextmessages'))
      ..lastFocusId = 'message-search-agent-searchbar';
    //logContext        = new Context(querySelector('#contextlog'));
  }

}
