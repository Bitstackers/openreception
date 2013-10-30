part of components;

class ContactInfoSearch {
               model.Contact       contact              = model.nullContact;
               UListElement        displayedContactList;
               DivElement          element;
               List<model.Contact> filteredContactList  = new List<model.Contact>();
  static const int                 incrementSteps       = 20;
               model.Organization  organization         = model.nullOrganization;
               String              placeholder          = 'Søg...';
               InputElement        searchBox;

  ContactInfoSearch(DivElement this.element) {
    String html = '''
        <div class="contact-info-searchbox">
          <input class="contact-info-search" 
                 type="search"  
                 placeholder="${placeholder}"/>
        </div>
  
        <ul id="contactlist" class="contact-info-zebra">
          <!-- Contact List, filled from component class. -->
        </ul>
    ''';

    var frag = new DocumentFragment.html(html);
    searchBox = frag.querySelector('.contact-info-search') as InputElement
      ..disabled = true
      ..onKeyUp.listen(onkeyup);

    displayedContactList = frag.querySelector('#contactlist')
        ..onScroll.listen(scrolling);

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
    var contact = organization.contactList.getContact(element.value);
    activeContact(contact);
  }

  bool _hasScrollbar(Element element) => element.scrollHeight > element.clientHeight;

  LIElement makeContactElement(model.Contact contact) =>
    new LIElement()
      ..text = contact.name
      ..value = contact.id
      ..onClick.listen(contactClick);


  void onkeyup(Event e) {
    InputElement target = e.target as InputElement;
    _performSearch(target.value);
  }

  void _performSearch(String search) {
    model.Contact _selectedContact;
    //Clear filtered list
    filteredContactList.clear();

    //Do the search.
    if(search.isEmpty) {
      filteredContactList.addAll(organization.contactList);
    } else {
      filteredContactList.addAll(organization.contactList.where((model.Contact contact) => searchContact(contact, search)));
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

  void registerEventListeners() {
    event.bus.on(event.organizationChanged).listen((model.Organization value) {
      organization = value;
      searchBox.disabled = value == model.nullOrganization;
      if(value != model.nullOrganization) {
        _performSearch(searchBox.value);
      }
    });

    event.bus.on(event.contactChanged).listen((model.Contact value) {
      contact = value;
    });
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