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

  LogBox logBox;

  Context home;
  Context messages;
  Context log;
  Context statistics;
  Context phone;
  Context voicemails;

  BobActive(DivElement this.element) {
    assert(element != null);

    event.bus.on(event.stateUpdated).listen((State value) => element.classes.toggle('hidden', !value.isOK));

    registerContexts();

    contextSwitcher          = new ContextSwitcher(querySelector('#contextswitcher'), [home, messages, log, statistics, phone, voicemails]);
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
    contactInfo = new ContactInfo(querySelector('#contactinfo'), home);
    sendMessage = new SendMessage(querySelector('#sendmessage'), home);
    globalQueue = new GlobalQueue(querySelector('#globalqueue'), home);
    localQueue  = new LocalQueue(querySelector('#localqueue'), home);

    logBox = new LogBox(querySelector('#logbox'));

    setupKeyboardShortcuts();
    event.bus.fire(event.activeContextChanged, CONTEXTHOME);
  }

  void registerContexts() {
    home       = new Context(querySelector('#contexthome'));
    messages   = new Context(querySelector('#contextmessages'));
    log        = new Context(querySelector('#contextlog'));
    statistics = new Context(querySelector('#contextstatistics'));
    phone      = new Context(querySelector('#contextphone'));
    voicemails = new Context(querySelector('#contextvoicemails'));
  }

  void setupKeyboardShortcuts() {
    keyboardHandler.onKeyName('companyselector').listen((_) {
      setFocus('company-selector-searchbar');
      event.bus.fire(event.activeContextChanged, CONTEXTHOME);
    });

    keyboardHandler.onKeyName('companyevents').listen((_) {
      setFocus('company_events_list');
      event.bus.fire(event.activeContextChanged, CONTEXTHOME);
    });

    keyboardHandler.onKeyName('companyhandling').listen((_) {
      setFocus('company_handling_list');
      event.bus.fire(event.activeContextChanged, CONTEXTHOME);
    });

    keyboardHandler.onKeyName('contactinfosearch').listen((_) {
      setFocus('contact-info-searchbar');
      event.bus.fire(event.activeContextChanged, CONTEXTHOME);
    });

    keyboardHandler.onKeyName('contactcalendar').listen((_) {
      setFocus('contact-calendar');
      event.bus.fire(event.activeContextChanged, CONTEXTHOME);
    });

    keyboardHandler.onKeyName('sendmessagetelephone').listen((_) {
      setFocus('sendmessagephone');
      event.bus.fire(event.activeContextChanged, CONTEXTHOME);
    });

    keyboardHandler.onKeyName('companyproduct').listen((_) {
      setFocus('company-product-body');
      event.bus.fire(event.activeContextChanged, CONTEXTHOME);
    });

    keyboardHandler.onKeyName('companycustomertype').listen((_) {
      setFocus('company-customertype-body');
      event.bus.fire(event.activeContextChanged, CONTEXTHOME);
    });
  }
}
