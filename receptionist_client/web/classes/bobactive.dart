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

  BobActive(DivElement this.element) {
    assert(element != null);

    event.bus.on(event.stateUpdated).listen((State value) => element.classes.toggle('hidden', !value.isOK));

    contextSwitcher = new ContextSwitcher(querySelector('#contextswitcher'), registerContexts());
    welcomeMessage = new WelcomeMessage(querySelector('#welcomemessage'));
    agentInfo = new AgentInfo(querySelector('#agentinfo'));
    companySelector = new CompanySelector(querySelector('#companyselector'), CONTEXTHOME);
    companyEvents = new CompanyEvents(querySelector('#companyevents'), CONTEXTHOME);
    companyHandling = new CompanyHandling(querySelector('#companyhandling'), CONTEXTHOME);
    companyOpeningHours = new CompanyOpeningHours(querySelector('#companyopeninghours'), CONTEXTHOME);
    companySalesCalls = new CompanySalesCalls(querySelector('#companysalescalls'), CONTEXTHOME);
    companyProduct = new CompanyProduct(querySelector('#companyproduct'), CONTEXTMESSAGES);
    companyCustomerType = new CompanyCustomerType(querySelector('#companycustomertype'), CONTEXTHOME);
    companyTelephoneNumbers = new CompanyTelephoneNumbers(querySelector('#companytelephonenumbers'), CONTEXTHOME);
    companyAddresses = new CompanyAddresses(querySelector('#companyaddresses'), CONTEXTHOME);
    companyAlternateNames = new CompanyAlternateNames(querySelector('#companyalternatenames'), CONTEXTHOME);
    companyBankingInfomation = new CompanyBankingInformation(querySelector('#companybankinginformation'), CONTEXTHOME);
    companyEmailAddresses = new CompanyEmailAddresses(querySelector('#companyemailaddresses'), CONTEXTHOME);
    companyWebsites = new CompanyWebsites(querySelector('#companywebsites'), CONTEXTHOME);
    compayRegistrationNumber = new CompanyRegistrationNumber(querySelector('#companyregistrationnumber'), CONTEXTHOME);
    companyOther = new CompanyOther(querySelector('#companyother'), CONTEXTHOME);

    contactInfo = new ContactInfo(querySelector('#contactinfo'), CONTEXTHOME);
    sendMessage = new SendMessage(querySelector('#sendmessage'), CONTEXTHOME);
    globalQueue = new GlobalQueue(querySelector('#globalqueue'), CONTEXTHOME);
    localQueue = new LocalQueue(querySelector('#localqueue'), CONTEXTHOME);

    setupKeyboardShortcuts();
    event.bus.fire(event.activeContextChanged, CONTEXTHOME);
  }

  List<Context> registerContexts() {
    return querySelectorAll('#bobactive > section')
        .map((HtmlElement section) => new Context(section)).toList(growable: false);
  }

  void setupKeyboardShortcuts() {
    keyboardHandler.onKeyName('companyselector').listen((_) => setFocus('company-selector-searchbar'));
    keyboardHandler.onKeyName('companyevents').listen((_) => setFocus('company_events_list'));
    keyboardHandler.onKeyName('companyhandling').listen((_) => setFocus('company_handling_list'));
    keyboardHandler.onKeyName('contactinfosearch').listen((_) => setFocus('contact-info-searchbar'));
    keyboardHandler.onKeyName('contactcalendar').listen((_) => setFocus('contact-calendar'));
    keyboardHandler.onKeyName('sendmessagetelephone').listen((_) {
      setFocus('sendmessagephone');
      event.bus.fire(event.activeContextChanged, CONTEXTHOME);
    });
    keyboardHandler.onKeyName('companyproduct').listen((_) {
      setFocus('company-product-body');
      event.bus.fire(event.activeContextChanged, CONTEXTMESSAGES);
      });
  }
}
