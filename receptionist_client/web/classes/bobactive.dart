/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

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

import 'context.dart';
import 'events.dart' as event;
import 'id.dart' as id;
import 'commands.keyboard.dart';
import 'location.dart' as nav;
//import 'logger.dart';
import 'state.dart';
import '../view/view.dart' as View;
import '../model/model.dart' as Model;

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
  View.CompanyOther companyOther;
  View.ContactInfo contactInfo;
  View.CallList globalQueue;
  View.CallManagement callManagement;
  //LocalQueue localQueue;

  View.ContextSwitcher contextSwitcher;
  View.ReceptionEvents receptionEvents;
  View.Message sendMessage;

  View.MessageSearch messageSearch;
  View.MessageList messageList;

  View.LogBox logBox;

  Context home;
  Context homePlus;
  Context messages;
  Context logContext;
  Context statistics;
  Context phone;
  Context voicemails;

  BobActive(DivElement this.element) {
    element.classes.remove('hidden');

    event.bus.on(event.stateUpdated).listen((State value) {
      element.classes.toggle('hidden', !value.isOK);
    });

    registerContexts();
    contextSwitcher          = new View.ContextSwitcher(querySelector('#${id.CONTEXT_SWITCHER}'), [home, homePlus, messages, logContext]);

    /// Home context
    welcomeMessage           = new View.WelcomeMessage(querySelector('#${id.WELCOME_MESSAGE}'));
    agentInfo                = new View.AgentInfo(querySelector('#${id.AGENT_INFO}'));
    companySelector          = new View.ReceptionSelector(querySelector('#${id.COMPANY_SELECTOR}'), home);
    receptionEvents          = new View.ReceptionEvents(querySelector('#${id.COMPANY_EVENTS}'), home);
    companyHandling          = new View.ReceptionHandling(querySelector('#${id.COMPANY_HANDLING}'), home);
    companyOpeningHours      = new View.ReceptionOpeningHours(querySelector('#${id.COMPANY_OPENINGHOURS}'), home);
    companySalesCalls        = new View.ReceptionSalesCalls(querySelector('#${id.COMPANY_SALESCALLS}'), home);
    companyProduct           = new View.ReceptionProduct(querySelector('#${id.COMPANY_PRODUCT}'), home);
    contactInfo              = new View.ContactInfo(querySelector('#${id.CONTACT_INFO}'), home);
    sendMessage              = new View.Message(querySelector('#${id.SENDMESSAGE}'), home);
    globalQueue              = new View.CallList(querySelector('#${id.GLOBAL_QUEUE}'), home);
    callManagement           = new View.CallManagement(querySelector('#${id.CALL_ORIGINATE}'), home);
    //localQueue               = new LocalQueue(querySelector('#${id.LOCAL_QUEUE}'), home);
    messageSearch            = new View.MessageSearch(querySelector('#${id.MESSAGE_SEARCH}'), messages);
    messageList              = new View.MessageList(querySelector('#${id.MESSAGE_OVERVIEW}'), messages);

    /// Home Plus context
    companyCustomerType      = new View.ReceptionCustomerType(querySelector('#${id.COMPANY_CUSTOMERTYPE}'), homePlus);
    companyTelephoneNumbers  = new View.ReceptionTelephoneNumbers(querySelector('#${id.COMPANY_TELEPHONE_NUMBERS}'), homePlus);
    companyAddresses         = new View.ReceptionAddresses(querySelector('#${id.COMPANY_ADDRESSES}'), home);
    companyAlternateNames    = new View.ReceptionAlternateNames(querySelector('#${id.COMPANY_ALTERNATENAMES}'), homePlus);
    companyBankingInfomation = new View.ReceptionBankingInformation(querySelector('#${id.COMPANY_BANKING_INFORMATION}'), homePlus);
    companyEmailAddresses    = new View.ReceptionEmailAddresses(querySelector('#${id.COMPANY_EMAIL_ADDRESSES}'), homePlus);
    companyWebsites          = new View.ReceptionWebsites(querySelector('#${id.COMPANY_WEBSITES}'), homePlus);
    compayRegistrationNumber = new View.ReceptionRegistrationNumber(querySelector('#${id.COMPANY_REGISTRATION_NUMBER}'), homePlus);
    companyOther             = new View.CompanyOther(querySelector('#${id.COMPANY_OTHER}'), homePlus);

    logBox = new View.LogBox(querySelector('#${id.LOGBOX}'));

    setupKeyboardShortcuts();
//    event.bus.fire(event.activeContextChanged, id.CONTEXT_HOME);

    //TODO move this to Bob.dart when we have no dynamic default elements.
    nav.initialize();
    Model.CalendarEventList.registerObservers();
  }

  void registerContexts() {
    home       = new Context(querySelector('#contexthome'))
      ..lastFocusId = 'company-selector-searchbar';
    homePlus   = new Context(querySelector('#contexthomeplus'))
        ..lastFocusId = 'company-customertype-body';
    messages   = new Context(querySelector('#contextmessages'))
      ..lastFocusId = 'message-search-agent-searchbar';
    logContext        = new Context(querySelector('#contextlog'));
  }

  void setupKeyboardShortcuts() {
//    keyboardHandler.onKeyName('companyselector').listen((_) {
//      //setFocus('company-selector-searchbar');
//      event.bus.fire(event.locationChanged, new nav.Location('contexthome', 'companyhandling'));
//    });
//
//    keyboardHandler.onKeyName('companyevents').listen((_) {
//      event.bus.fire(event.locationChanged, new nav.Location('contexthome', 'companyevents'));
//      //setFocus('company_events_list');
//    });
//
//    keyboardHandler.onKeyName('companyhandling').listen((_) {
//      setFocus('company_handling_list');
//    });
//
//    keyboardHandler.onKeyName('contactinfosearch').listen((_) {
//      setFocus('contact-info-searchbar');
//    });
//
//    keyboardHandler.onKeyName('sendmessagetelephone').listen((_) {
//      setFocus('sendmessagephone');
//    });
//
//    keyboardHandler.onKeyName('messagefield').listen((_) {
//      setFocus('sendmessagetext');
//    });
//
//    keyboardHandler.onKeyName('companycustomertype').listen((_) {
//      setFocus('company-customertype-body');
//    });

    //Don't remove. Objects are lazily loaded and no one else access keyboardHandler.
    keyboardHandler.toString();
  }
}
