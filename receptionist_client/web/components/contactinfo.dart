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

import 'dart:async';
import 'dart:html';

import 'package:polymer/polymer.dart';

import '../classes/common.dart';
import '../classes/events.dart' as event;
import '../classes/logger.dart';
import '../classes/model.dart' as model;

@CustomTag('contact-info')
class ContactInfo extends PolymerElement with ApplyAuthorStyle {
               String              calendarTitle       = 'Kalender';
  @observable  model.Contact       contact             = model.nullContact;
               UListElement        displayedContactList;
  static const int                 incrementSteps      = 20;
               model.Organization  nullOrganization    = model.nullOrganization;
  @observable  model.Organization  organization        = model.nullOrganization;
  @observable  List<model.Contact> filteredContactList = toObservable([]);
               String              placeholder         = 'søg...';
               String              search              = '';
               String              title               = 'Medarbejdere';

  void created() {
    super.created();
    registerEventListeners();

    onPropertyChange(this, #search, _performSearch);
    displayedContactList = getShadowRoot('contact-info').query('#ulcontactlist')
        //TODO Why does onscroll not work
      ..onScroll.listen((Event event) => scrolling(event));
  }

  void onkeyup(Event _, var __, InputElement target) {
    search = target.value;
    _performSearch();
  }

  void _performSearch() {
    model.Contact _selectedContact;
    //Clear filtered list
    filteredContactList.clear();

    //Do the search.
    if(search.isEmpty) {
      filteredContactList.addAll(organization.contactList);
    } else {
      filteredContactList.addAll(organization.contactList.where(searchContact));
    }

    _clearDisplayedContactList();

    if(filteredContactList.isNotEmpty) {
      _selectedContact = filteredContactList.first;
      _showMoreElements(incrementSteps);
      activeContact(_selectedContact);
    } else {
      _selectedContact = model.nullContact;
    }
    event.bus.fire(event.contactChanged, _selectedContact);
  }

  scrolling(Event _) {
    var procentage = (displayedContactList.scrollTop + displayedContactList.clientHeight) / displayedContactList.scrollHeight;
    if(procentage >= 1.0) {
      _showMoreElements(incrementSteps);
    }
  }

  bool searchContact(model.Contact value) {
    var searchTerm = search.trim();
    if(searchTerm.contains(' ')) {
      var terms = searchTerm.toLowerCase().split(' ');
      var names = value.name.toLowerCase().split(' ');
      int termIndex = 0;
      int nameIndex = 0;
      while(termIndex < terms.length && nameIndex < names.length) {
        if(names[nameIndex].startsWith(terms[termIndex])) {
          termIndex += 1;
        }
        nameIndex += 1;
      }
      return termIndex >= terms.length;
    }

    return value.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
           value.tags.any((tag) => tag.toLowerCase().contains(searchTerm.toLowerCase()));
  }

  void _clearDisplayedContactList() {
    displayedContactList.children.clear();
    displayedContactList.scrollTop = 0;
  }

  LIElement makeContactElement(model.Contact contact) {
    return new LIElement()
            ..text = contact.name
            ..value = contact.id
            ..onClick.listen(contactClick);
  }

  void contactClick(Event event) {
    LIElement element = event.target;
    var contact = organization.contactList.getContact(element.value);
    activeContact(contact);
  }

  void activeContact(model.Contact contact) {
    for(LIElement element in displayedContactList.children) {
      element.classes.toggle('contact-info-active', element.value == contact.id);
    }

    event.bus.fire(event.contactChanged, contact);
  }

  void _showMoreElements(int numberOfElementsMore) {
    int numberOfContactsDisplaying = displayedContactList.children.length;
    //If it don't have a scrollbar, add elements until it gets one, or there are no more elements to show.
    if(!_hasScrollbar(displayedContactList)) {
      int triesStep = 5;
      while(!_hasScrollbar(displayedContactList) && displayedContactList.children.length != filteredContactList.length) {
        var appendingList = filteredContactList.skip(displayedContactList.children.length).take(triesStep);
        displayedContactList.children.addAll(appendingList.map(makeContactElement));
      }

      //Add some air
      var appendingList = filteredContactList.skip(displayedContactList.children.length).take(triesStep);
      displayedContactList.children.addAll(appendingList.map(makeContactElement));

    } else if (numberOfContactsDisplaying < filteredContactList.length) {
      var appendingList = filteredContactList.skip(numberOfContactsDisplaying).take(numberOfElementsMore);
      displayedContactList.children.addAll(appendingList.map(makeContactElement));
    }
  }

  bool _hasScrollbar(Element element) {
    return element.scrollHeight > element.clientHeight;
  }

  void registerEventListeners() {
    event.bus.on(event.organizationChanged).listen((model.Organization value) {
      organization = value;
      _performSearch();
    });

    event.bus.on(event.contactChanged).listen((model.Contact value) => contact = value);
  }

  void select(Event _, var __, Node target) {
    int id = int.parse((target as LIElement).id.split('_').last);
    var contact = organization.contactList.getContact(id);
    event.bus.fire(event.contactChanged, contact);

    log.debug('ContactInfo.select on id: ${id} updated contact to ${contact}');
  }

  String getClass(model.CalendarEvent event) => event.active ? 'company-events-active' : '';
  String getInfoClass(model.Contact value) {
    log.debug('ContactInfo - infoClass value: ${value}');
    return contact == value ? 'contact-info-active' : '';
  }
}
