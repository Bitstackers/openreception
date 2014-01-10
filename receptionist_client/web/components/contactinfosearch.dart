part of components;

class ContactInfoSearch {
               model.Contact       contact              = model.nullContact;
               Context             context;
               UListElement        displayedContactList;
               DivElement          element;
               List<model.Contact> filteredContactList  = new List<model.Contact>();
  static const int                 incrementSteps       = 20;
               model.Organization  organization         = model.nullOrganization;
               String              placeholder          = 'Søg...';
               model.ContactList   contactList;
               InputElement        searchBox;

  bool hasFocus = false;

  ContactInfoSearch(DivElement this.element, Context this.context) {
    String html = '''
        <div class="contact-info-searchbox">
          <input id="contact-info-searchbar" 
                 type="search"  
                 placeholder="${placeholder}"/>
        </div>
  
        <ul id="contactlist" class="contact-info-zebra">
          <!-- Contact List, filled from component class. -->
        </ul>
    ''';

    var frag = new DocumentFragment.html(html);
    searchBox = frag.querySelector('#contact-info-searchbar') as InputElement
      ..disabled = true;

    displayedContactList = frag.querySelector('#contactlist');

    element.children.addAll(frag.children);

    registerEventListeners();
  }

  void activeContact(model.Contact contact) {
    for(LIElement element in displayedContactList.children) {
      element.classes.toggle('contact-info-active', element.value == contact.id);
    }

    event.bus.fire(event.contactChanged, contact);
  }

  void _clearDisplayedContactList() {
    displayedContactList
      ..children.clear()
      ..scrollTop = 0;
  }

  void contactClick(Event event) {
    LIElement element = event.target;
    model.Contact contact = contactList.getContact(element.value);
    activeContact(contact);
  }

  bool _hasScrollbar(Element element) => element.scrollHeight > element.clientHeight;

  LIElement makeContactElement(model.Contact contact) =>
    new LIElement()
      ..text = contact.name
      ..value = contact.id
      ..onClick.listen(contactClick);

  void onkeydown(KeyboardEvent e) {
    if(e.keyCode == Keys.DOWN) {
      for(LIElement li in displayedContactList.children) {
        if(li.classes.contains('contact-info-active')) {
          LIElement next = li.nextElementSibling;
          if(next != null) {
            li.classes.remove('contact-info-active');
            next.classes.add('contact-info-active');
            int contactId = next.value;
            model.Contact con = contactList.getContact(contactId);
            if(con != null) {
              event.bus.fire(event.contactChanged, con);
            }
          }
          break;
        }
      }
      e.preventDefault();
    } else if(e.keyCode == Keys.UP) {
      for(LIElement li in displayedContactList.children) {
        if(li.classes.contains('contact-info-active')) {
          LIElement previous = li.previousElementSibling;
          if(previous != null) {
            li.classes.remove('contact-info-active');
            previous.classes.add('contact-info-active');
            int contactId = previous.value;
            model.Contact con = contactList.getContact(contactId);
            if(con != null) {
              event.bus.fire(event.contactChanged, con);
            }
          }
          break;
        }
      }
      e.preventDefault();
    }
  }

  void onkeyup(KeyboardEvent e) {
    if(e.keyCode == Keys.DOWN || e.keyCode == Keys.UP) {
      //NOTHING
    } else {
      _performSearch(searchBox.value);
    }
  }

  void _performSearch(String search) {
    model.Contact _selectedContact;
    //Clear filtered list
    filteredContactList.clear();

    //Do the search.
    if(search.isEmpty) {
      filteredContactList.addAll(contactList);
    } else {
      filteredContactList.addAll(contactList.where((model.Contact contact) => searchContact(contact, search)));
    }

    _clearDisplayedContactList();

    if(filteredContactList.isNotEmpty) {
      _selectedContact = filteredContactList.first;
      _showMoreElements(incrementSteps);
    } else {
      _selectedContact = model.nullContact;
    }
    activeContact(_selectedContact);
  }

  void registerEventListeners() {
    event.bus.on(event.organizationChanged).listen((model.Organization value) {
      organization = value;
      searchBox.disabled = value == model.nullOrganization;
      if(value == model.nullOrganization) {
        searchBox.value = '';
      }
      
      protocol.getContactList(organization.id).then((protocol.Response<model.ContactList> response) {
        contactList = response.data;
        _performSearch(searchBox.value);
      }).catchError((error) => contactList = new model.ContactList.emptyList());
    });

    event.bus.on(event.contactChanged).listen((model.Contact value) {
      contact = value;
    });

    event.bus.on(event.focusChanged).listen((Focus value) {
      if(value.old == searchBox.id) {
        hasFocus = false;
        //TODO HACK FIXME ??? THOMAS LØCKE
        element.parent.parent.classes.remove(focusClassName);
      }

      if(value.current == searchBox.id) {
        hasFocus = true;
        searchBox.focus();
        //TODO HACK FIXME ??? THOMAS LØCKE
        element.parent.parent.classes.add(focusClassName);
      }
    });

    searchBox.onFocus.listen((_) {
      if(!hasFocus) {
        setFocus(searchBox.id);
      }
    });

    searchBox
     ..onKeyUp.listen(onkeyup)
     ..onKeyDown.listen(onkeydown);

    displayedContactList.onScroll.listen(scrolling);

    keyboardHandler.onKeyName('selectedContactCall').listen((_) {
      if (contact != model.nullContact) {
        if (contact.telephoneNumberList.isNotEmpty) {
          //TODO call contact;
        }
      }
    });

    context.registerFocusElement(searchBox);
  }

  void scrolling(Event _) {
    var procentage = (displayedContactList.scrollTop + displayedContactList.clientHeight) / displayedContactList.scrollHeight;
    if(procentage >= 1.0) {
      _showMoreElements(incrementSteps);
    }
  }

  bool searchContact(model.Contact value, String search) {
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
}