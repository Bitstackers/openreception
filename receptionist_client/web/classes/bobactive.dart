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
import 'focus.dart';
import 'keyboardhandler.dart';
import 'logger.dart';
import 'state.dart';
import '../components.dart';

class BobActive {
  DivElement element;

  ContextSwitcher contextSwitcher;
  WelcomeMessage welcomeMessage;
  AgentInfo agentInfo;
  CompanySelector companySelector;
  CompanyEvents companyEvents;
  CompanyHandling companyHandling;
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

  MessageSearch messageSearch;
  MessageOverview messageOverview;

  LogBox logBox;

  Phonebooth phonebooth;

  Context home;
  Context messages;
  Context logContext;
  Context statistics;
  Context phone;
  Context voicemails;

  BobActive(DivElement this.element) {
    assert(element != null);

    event.bus.on(event.stateUpdated).listen((State value) {
      element.classes.toggle('hidden', !value.isOK);
      log.debug('BobActive. stateUpdated: $value');
    });

    registerContexts();

    contextSwitcher          = new ContextSwitcher(querySelector('#contextswitcher'), [home, messages, logContext, statistics, phone, voicemails]);
    welcomeMessage           = new WelcomeMessage(querySelector('#welcomemessage'));
    agentInfo                = new AgentInfo(querySelector('#agentinfo'));
    companySelector          = new CompanySelector(querySelector('#companyselector'), home);
    companyEvents            = new CompanyEvents(querySelector('#companyevents'), home);
    companyHandling          = new CompanyHandling(querySelector('#companyhandling'), home);
    companyOpeningHours      = new CompanyOpeningHours(querySelector('#companyopeninghours'), home);
    companySalesCalls        = new CompanySalesCalls(querySelector('#companysalescalls'), home);
    companyProduct           = new CompanyProduct(querySelector('#companyproduct'), home);
    companyCustomerType      = new CompanyCustomerType(querySelector('#companycustomertype'), home);
    companyTelephoneNumbers  = new CompanyTelephoneNumbers(querySelector('#companytelephonenumbers'), home);
    companyAddresses         = new CompanyAddresses(querySelector('#companyaddresses'), home);
    companyAlternateNames    = new CompanyAlternateNames(querySelector('#companyalternatenames'), home);
    companyBankingInfomation = new CompanyBankingInformation(querySelector('#companybankinginformation'), home);
    companyEmailAddresses    = new CompanyEmailAddresses(querySelector('#companyemailaddresses'), home);
    companyWebsites          = new CompanyWebsites(querySelector('#companywebsites'), home);
    compayRegistrationNumber = new CompanyRegistrationNumber(querySelector('#companyregistrationnumber'), home);
    companyOther             = new CompanyOther(querySelector('#companyother'), home);
    contactInfo              = new ContactInfo(querySelector('#contactinfo'), home);
    sendMessage              = new SendMessage(querySelector('#sendmessage'), home);
    globalQueue              = new GlobalQueue(querySelector('#globalqueue'), home);
    localQueue               = new LocalQueue(querySelector('#localqueue'), home);

    messageSearch = new MessageSearch(querySelector('#message-search'), messages);
    messageOverview = new MessageOverview(querySelector('#messageoverview'), messages);

    logBox = new LogBox(querySelector('#logbox'));

    phonebooth = new Phonebooth(querySelector('#phonebooth'), phone);

    setupKeyboardShortcuts();
    event.bus.fire(event.activeContextChanged, CONTEXTHOME);
  }

  void registerContexts() {
    home       = new Context(querySelector('#contexthome'))
      ..lastFocusId = 'company-selector-searchbar';
    messages   = new Context(querySelector('#contextmessages'))
      ..lastFocusId = 'message-search-agent-searchbar';
    logContext        = new Context(querySelector('#contextlog'));
    statistics = new Context(querySelector('#contextstatistics'));
    phone      = new Context(querySelector('#contextphone'))
      ..lastFocusId = 'phonebooth-company-searchbar';
    voicemails = new Context(querySelector('#contextvoicemails'));
  }

  void setupKeyboardShortcuts() {
    keyboardHandler.onKeyName('companyselector').listen((_) {
      setFocus('company-selector-searchbar');
    });

    keyboardHandler.onKeyName('companyevents').listen((_) {
      setFocus('company_events_list');
    });

    keyboardHandler.onKeyName('companyhandling').listen((_) {
      setFocus('company_handling_list');
    });

    keyboardHandler.onKeyName('contactinfosearch').listen((_) {
      setFocus('contact-info-searchbar');
    });

    keyboardHandler.onKeyName('sendmessagetelephone').listen((_) {
      setFocus('sendmessagephone');
    });

    keyboardHandler.onKeyName('messagefield').listen((_) {
      setFocus('sendmessagetext');
    });

    keyboardHandler.onKeyName('companycustomertype').listen((_) {
      setFocus('company-customertype-body');
    });

  }
}
