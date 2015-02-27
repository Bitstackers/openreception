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

part of view;

class ContactSearch {

  static const String className = '${libraryName}.ContactInfoSearch';
  static const String NavShortcut = 'S';

               model.Contact       contact              = model.Contact.noContact;
               Context             context;
               UListElement    get displayedContactList => element.querySelector('#${Id.contactSelectorList}');
               DivElement          element;
               List<model.Contact> filteredContactList  = new List<model.Contact>();
  static const int                 incrementSteps       = 20;
               model.Reception     reception            = model.Reception.noReception;
               List<model.Contact> contactList;
               InputElement    get searchBox            => this.element.querySelector('#${Id.contactSelectorInput}');
               Element             widget;

  bool hasFocus = false;

  ContactSearch(DivElement this.element, Context this.context, Element this.widget) {
    this.searchBox.disabled = true;

    registerEventListeners();
    setupLabels();
  }

  void setupLabels(){
    this.searchBox.placeholder = Label.PlaceholderSearch;
  }

  /**
   * Brings focus to the widget.
   */
  void focus () {
    event.bus.fire(event.locationChanged, new nav.Location(context.id, widget.id, searchBox.id));
  }

  void activeContact(model.Contact contact) {
    for(LIElement element in displayedContactList.children) {
      element.classes.toggle(CssClass.selected, element.value == contact.ID);
    }

    Controller.Contact.change(contact);
  }

  void _clearDisplayedContactList() {
    displayedContactList
      ..children.clear()
      ..scrollTop = 0;
  }

  void contactClick(Event e) {
    LIElement element = e.target;
    model.Contact contact = model.Contact.findContact(element.value, contactList);
    activeContact(contact);
    if(!hasFocus) {
      this.focus();
    }
  }

  bool _overflows(Element element) => element.scrollHeight > element.clientHeight;

  LIElement makeContactElement(model.Contact contact) =>
    new LIElement()
      ..text = contact.fullName
      ..value = contact.ID
      ..onClick.listen(contactClick);

  void onkeydown(KeyboardEvent e) {
    if(e.keyCode == Keys.DOWN) {
      nextElement(e);
    } else if(e.keyCode == Keys.UP) {
      previousElement(e);
    }
  }

  void previousElement(KeyboardEvent e) {
    LIElement li = displayedContactList.querySelector('.${CssClass.selected}');
    LIElement previous = li.previousElementSibling;

    if(previous != null) {
      li.classes.toggle(CssClass.selected, false);
      previous.classes.toggle(CssClass.selected, true);
      int contactId = previous.value;
      model.Contact con = model.Contact.findContact(contactId, contactList);
      if(con != null) {
        Controller.Contact.change(con);
      }
    }
    e.preventDefault();
  }

  void nextElement(KeyboardEvent e) {
    for(LIElement li in displayedContactList.children) {
      if(li.classes.contains(CssClass.selected)) {
        LIElement next = li.nextElementSibling;
        if(next != null) {
          li.classes.remove(CssClass.selected);
          next.classes.add(CssClass.selected);
          int contactId = next.value;
          model.Contact con = model.Contact.findContact(contactId, contactList);
          if(con != null) {
            Controller.Contact.change(con);
          }
        }
        break;
      }
    }
    e.preventDefault();
  }

  void _performSearch(String search) {
    model.Contact _selectedContact = model.Contact.noContact;
    //Clear filtered list
    filteredContactList.clear();

    //Do the search.
    if(search.isEmpty) {
      filteredContactList.addAll(contactList);
    } else {
      filteredContactList.addAll(contactList.where((model.Contact contact) => contactMatches(contact, search)));
    }

    _clearDisplayedContactList();

    if(filteredContactList.isNotEmpty) {
      _selectedContact = filteredContactList.first;
      _showMoreElements(incrementSteps);
    } else {
      _selectedContact = model.Contact.noContact;
    }
    activeContact(_selectedContact);
  }

  void registerEventListeners() {

    event.bus.on(model.Reception.activeReceptionChanged).listen((model.Reception newReception) {
      reception = newReception;
      searchBox.disabled = newReception == model.Reception.noReception;
      if(newReception == model.Reception.noReception) {
        searchBox.value = '';
      }

      model.Contact.list(reception.ID).then((List<model.Contact> list) {
        contactList = list;
        _performSearch(searchBox.value);
      }).catchError((error) => contactList = []);
    });

    event.bus.on(model.Contact.activeContactChanged).listen((model.Contact value) {
      contact = value;
    });

    event.bus.on(event.locationChanged).listen((nav.Location location) {
      bool active = location.widgetId == widget.id;
      widget.classes.toggle(FOCUS, active);
      if(location.elementId == searchBox.id) {
        searchBox.focus();
      }
    });

    searchBox.onInput.listen((_) {
      _performSearch(searchBox.value);
    });

    searchBox.onClick.listen((MouseEvent e) {
      event.bus.fire(event.locationChanged, new nav.Location(context.id, widget.id, searchBox.id));
    });

    searchBox
     ..onKeyDown.listen(onkeydown);

    displayedContactList.onScroll.listen(scrolling);

  }

  void scrolling(Event _) {
    var procentage = (displayedContactList.scrollTop + displayedContactList.clientHeight) / displayedContactList.scrollHeight;
    if(procentage >= 1.0) {
      _showMoreElements(incrementSteps);
    }
  }

  bool contactMatches(model.Contact value, String search) {
    String searchTerm = search.trim();
    if(searchTerm.contains(' ')) {
      var terms = searchTerm.toLowerCase().split(' ');
      var names = value.fullName.toLowerCase().split(' ');
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

    return value.fullName.toLowerCase().contains(searchTerm.toLowerCase()) ||
           value.tags.any((tag) => tag.toLowerCase().contains(searchTerm.toLowerCase()));
  }

  void _showMoreElements(int numberOfElementsMore) {
    int numberOfContactsDisplaying = displayedContactList.children.length;
    //If it don't have a scrollbar, add elements until it gets one, or there are no more elements to show.
    if(!this._overflows(displayedContactList)) {
      int triesStep = 5;
      while(!this._overflows(displayedContactList) && displayedContactList.children.length != filteredContactList.length) {
        var appendingList = filteredContactList.skip(displayedContactList.children.length).take(triesStep);
        displayedContactList.children.addAll(appendingList.map(makeContactElement));
      }

      //TODO: Add some spacing.
      var appendingList = filteredContactList.skip(displayedContactList.children.length).take(triesStep);
      displayedContactList.children.addAll(appendingList.map(makeContactElement));

    } else if (numberOfContactsDisplaying < filteredContactList.length) {
      var appendingList = filteredContactList.skip(numberOfContactsDisplaying).take(numberOfElementsMore);
      displayedContactList.children.addAll(appendingList.map(makeContactElement));
    }
  }
}