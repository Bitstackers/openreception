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
import 'commands.dart';
import 'location.dart' as nav;
//import 'logger.dart';
import 'state.dart';
import '../components.dart';
import '../view/view.dart' as View;
import '../constants.dart' as constant;

class BobActive {
  DivElement element;

  ContextSwitcher contextSwitcher;
  WelcomeMessage welcomeMessage;
  AgentInfo agentInfo;
  CompanySelector companySelector;
  
  ReceptionHandling companyHandling;
  CompanyOpeningHours companyOpeningHours;
  CompanySalesCalls companySalesCalls;
  CompanyProduct companyProduct;
  CompanyCustomerType companyCustomerType;
  CompanyTelephoneNumbers companyTelephoneNumbers;
  CompanyAddresses companyAddresses;
  CompanyAlternateNames companyAlternateNames;
  CompanyBankingInformation companyBankingInfomation;
  CompanyEmailAddresses companyEmailAddresses;
  CompanyWebsites companyWebsites;
  CompanyRegistrationNumber compayRegistrationNumber;
  CompanyOther companyOther;
  ContactInfo contactInfo;
  SendMessage sendMessage;
  GlobalQueue globalQueue;
  LocalQueue localQueue;
  
  View.CallManagement callManagement;
  View.ReceptionEvents receptionEvents;
  
  MessageSearch messageSearch;
  View.MessageList messageList;

  LogBox logBox;

  Phonebooth phonebooth;

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

    contextSwitcher          = new ContextSwitcher(querySelector('#${id.CONTEXT_SWITCHER}'), [home, homePlus, messages, logContext, statistics, phone, voicemails]);
    welcomeMessage           = new WelcomeMessage(querySelector('#${id.WELCOME_MESSAGE}'));
    agentInfo                = new AgentInfo(querySelector('#${id.AGENT_INFO}'));
    companySelector          = new CompanySelector(querySelector('#${id.COMPANY_SELECTOR}'), home);
    receptionEvents          = new View.ReceptionEvents(querySelector('#${id.COMPANY_EVENTS}'), home);
    companyHandling          = new ReceptionHandling(querySelector('#${id.COMPANY_HANDLING}'), home);
    companyOpeningHours      = new CompanyOpeningHours(querySelector('#${id.COMPANY_OPENINGHOURS}'), home);
    companySalesCalls        = new CompanySalesCalls(querySelector('#${id.COMPANY_SALESCALLS}'), home);
    companyProduct           = new CompanyProduct(querySelector('#${id.COMPANY_PRODUCT}'), home);
    companyCustomerType      = new CompanyCustomerType(querySelector('#${id.COMPANY_CUSTOMERTYPE}'), home);
    companyTelephoneNumbers  = new CompanyTelephoneNumbers(querySelector('#${id.COMPANY_TELEPHONE_NUMBERS}'), home);
    companyAddresses         = new CompanyAddresses(querySelector('#${id.COMPANY_ADDRESSES}'), home);
    companyAlternateNames    = new CompanyAlternateNames(querySelector('#${id.COMPANY_ALTERNATENAMES}'), home);
    companyBankingInfomation = new CompanyBankingInformation(querySelector('#${id.COMPANY_BANKING_INFORMATION}'), home);
    companyEmailAddresses    = new CompanyEmailAddresses(querySelector('#${id.COMPANY_EMAIL_ADDRESSES}'), home);
    companyWebsites          = new CompanyWebsites(querySelector('#${id.COMPANY_WEBSITES}'), home);
    compayRegistrationNumber = new CompanyRegistrationNumber(querySelector('#${id.COMPANY_REGISTRATION_NUMBER}'), home);
    companyOther             = new CompanyOther(querySelector('#${id.COMPANY_OTHER}'), home); 
    contactInfo              = new ContactInfo(querySelector('#${id.CONTACT_INFO}'), home);
    sendMessage              = new SendMessage(querySelector('#${id.SENDMESSAGE}'), home);
    globalQueue              = new GlobalQueue(querySelector('#${id.GLOBAL_QUEUE}'), home);
    localQueue               = new LocalQueue(querySelector('#${id.LOCAL_QUEUE}'), home);
    callManagement           = new View.CallManagement(querySelector('#${constant.ID.CALL_MANAGEMENT}'));
    messageSearch = new MessageSearch(querySelector('#${id.MESSAGE_SEARCH}'), messages);
    messageList = new View.MessageList(querySelector('#${id.MESSAGE_OVERVIEW}'), messages);

    logBox = new LogBox(querySelector('#${id.LOGBOX}'));

    phonebooth = new Phonebooth(querySelector('#phonebooth'), phone);

    setupKeyboardShortcuts();
//    event.bus.fire(event.activeContextChanged, id.CONTEXT_HOME);
    
    //TODO move this to Bob.dart when we have no dynamic default elements.
    nav.initialize();
    
    CommandHandlers.registerListeners();
  }

  void registerContexts() {
    home       = new Context(querySelector('#contexthome'))
      ..lastFocusId = 'company-selector-searchbar';
    homePlus   = new Context(querySelector('#contexthomeplus'))
        ..lastFocusId = 'company-customertype-body';
    messages   = new Context(querySelector('#contextmessages'))
      ..lastFocusId = 'message-search-agent-searchbar';
    logContext        = new Context(querySelector('#contextlog'));
    statistics = new Context(querySelector('#contextstatistics'));
    phone      = new Context(querySelector('#contextphone'))
      ..lastFocusId = 'phonebooth-company-searchbar';
    voicemails = new Context(querySelector('#contextvoicemails'));
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
    keyboardHandler.toString();
  }
}
