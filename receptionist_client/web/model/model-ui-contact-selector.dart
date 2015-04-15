part of model;

class UIContactSelector extends UIModel {
  final DivElement _myRoot;

  UIContactSelector(DivElement this._myRoot) {
    _registerEventListeners();
  }

  @override HtmlElement    get _firstTabElement => _filter;
  @override HtmlElement    get _focusElement    => _filter;
  @override HeadingElement get _header          => _root.querySelector('h4');
  @override DivElement     get _help            => _root.querySelector('div.help');
  @override HtmlElement    get _lastTabElement  => _filter;
  /**
   * Return the mousedown click event stream for this widget. We capture
   * mousedown instead of regular click to avoid the ugly focus/blur flicker
   * on the filter input whenever a contact li element is clicked.
   */
  @override Stream<MouseEvent> get onClick => _myRoot.onMouseDown;
  @override HtmlElement        get _root   => _myRoot;

  OListElement get _contactList => _root.querySelector('.generic-widget-list');
  InputElement get _filter      => _root.querySelector('.filter');

  /**
   * Add [items] to the contacts list.
   */
  set contacts(List<Contact> items) {
    items.forEach((Contact item) {
      String initials = item.name.trim().split(' ').fold('', (acc, value) => '${acc}${value.substring(0,1).toLowerCase()}');

      /// Add contact name to tags. We simply treat the name as just another tag
      /// when searching for contacts.
      item.tags.addAll(item.name.split(' '));

      _contactList.append(new LIElement()
          ..dataset['initials']      = initials
          ..dataset['firstinitial']  = initials.substring(0,1)
          ..dataset['otherinitials'] = initials.substring(1)
          ..dataset['tags']          = item.tags.join(',').toLowerCase()
          ..dataset['object']        = JSON.encode(item));
    });
  }

  /**
   * Remove all entries from the contact list.
   */
  void clearList() {
    _contactList.children.clear();
  }

  /**
   * Return true if the [event].target is the filter input field.
   */
  bool eventTargetIsFilterInput(MouseEvent event) {
    if(event.target == _filter) {
      return true;
    }

    return false;
  }

  /**
   * Filter the contact list whenever the user enters data into the [_filter]
   * input field.
   */
  void filter(_) {
    String filter = _filter.value.toLowerCase();
    String trimmedFilter = filter.trim();

    /// TODO (TL): This filtering model is a bit "meh". What we probably should
    /// do is leverage the CSS :not() selector and simply add/remove CSS rules
    /// based on the given filter values. That way we don't do any kind of
    /// looping, and all hiding/unhiding is left entirely to the browser.

    if(filter.length == 0 || trimmedFilter.isEmpty) {
      /// Empty filter. Remove .hide from all list elements.
      _contactList.children.forEach((LIElement li) => li.classes.toggle('hide', false));
    } else if(trimmedFilter.length == 1 && !filter.startsWith(' ')) {
      /// Pattern: one non-space character followed by zero or more spaces
      _contactList.children.forEach((LIElement li) {
        if(li.dataset['firstinitial'] == trimmedFilter) {
          li.classes.toggle('hide', false);
        } else {
          li.classes.toggle('hide', true);
        }
      });
    } else if(trimmedFilter.length ==1 && filter.startsWith(new RegExp(r'\s+[^ ]'))) {
      /// Pattern: one or more spaces followed by one non-space character
      _contactList.children.forEach((LIElement li) {
        if(li.dataset['otherinitials'].contains(trimmedFilter)) {
          li.classes.toggle('hide', false);
        } else {
          li.classes.toggle('hide', true);
        }
      });
    } else if(trimmedFilter.length == 3 && trimmedFilter.startsWith(new RegExp(r'[^ ]\s[^ ]'))) {
      /// Pattern: one character, one space, one character
      _contactList.children.forEach((LIElement li) {
        if(li.dataset['firstinitial'] == trimmedFilter.substring(0,1) && li.dataset['otherinitials'].contains(trimmedFilter.substring(2))) {
          li.classes.toggle('hide', false);
        } else {
          li.classes.toggle('hide', true);
        }
      });
    } else {
      /// Split filter string on space and search for contacts that have all
      /// the resulting parts in their tag list.
      List<String> parts = trimmedFilter.split(' ');

      _contactList.children.forEach((LIElement li) {
        if(parts.every((String part) => li.dataset['tags'].contains(part))) {
          li.classes.toggle('hide', false);
        } else {
          li.classes.toggle('hide', true);
        }
      });
    }

    /// Select the first item on the list
    _markSelected(_getFirstVisibleEntry());
  }

  /**
   * Return the selected [Contact] from [_contactList]
   * MAY return null if nothing is selected.
   */
  Contact getSelectedContact() {
    try {
      return new Contact.fromJson(JSON.decode(_contactList.querySelector('.selected').dataset['object']));
    } catch (e) {
      print(e);
      return null;
    }
  }

//  /**
//   * Return the [Contact] the user clicked on.
//   * MAY return null if the user did not click on an actual valid [Contact].
//   */
//  Contact getContactFromClick(MouseEvent event) {
//    if(event.target is LIElement) {
//      return new Contact.fromElement(event.target);
//    }
//
//    return null;
//  }

  /**
   * Return the [LIElement] the user clicked on.
   * MAY return null if the user did not click on a [LIElement].
   */
  LIElement _getEntryFromClick(MouseEvent event) {
    if(event.target is LIElement) {
      return event.target;
    }

    return null;
  }

//  /**
//   * Return the first visible [Contact] from [_contactList]
//   * MAY return null if the list is empty.
//   */
//  Contact _getContactFirstVisible() {
//    LIElement li = _scanAheadForVisibleSibling(_contactList.firstChild);// _contactList.children.firstWhere((LIElement li) => !li.classes.contains('hide'), orElse: () => null);
//    if(li != null) {
//      return new Contact.fromJson(JSON.decode(li.dataset['object']));
//    }
//
//    return null;
//  }

  /**
   * Return the first visible [LIELement] from [_contactList]
   * MAY return null if the list is empty.
   */
  LIElement _getFirstVisibleEntry() {
    LIElement li = _scanAheadForVisibleSibling(_contactList.firstChild);
    return li == null ? null : li;
  }

  /**
   * Deal with arrow up/down.
   */
  void _handleUpDown(KeyboardEvent event) {
    if(active) {
      event.preventDefault();
      switch(event.keyCode) {
        case KeyCode.DOWN:
          _select(_nextEntryInList());
          break;
        case KeyCode.UP:
          _select(_previousEntryInList());
          break;
      }
    }
  }

//  /**
//   * Mark [contact] selected.
//   */
//  void markSelected(Contact contact) {
//    if(contact != null) {
//      _contactList.children.forEach((Element element) => element.classes.remove('selected'));
//      contact.li.classes.add('selected');
//      contact.li.scrollIntoView();
//    }
//  }

  /**
   * Mark [entry] selected.
   */
  void _markSelected(LIElement entry) {
    if(entry != null) {
      _contactList.children.forEach((Element element) => element.classes.remove('selected'));
      entry.classes.add('selected');
      entry.scrollIntoView();
    }
  }

//  /**
//   * Return the [Contact] following the currently selected [Contact].
//   * Return null if we're at last element.
//   */
//  Contact nextContactInList() {
//    LIElement li = _scanAheadForVisibleSibling(_contactList.querySelector('.selected'));
//    return li == null ? null : new Contact.fromElement(li);
//  }

  /**
   * Return the [LIElement] following the currently selected [LIElement].
   * Return null if we're at last element.
   */
  LIElement _nextEntryInList() {
    LIElement li = _scanAheadForVisibleSibling(_contactList.querySelector('.selected'));
    return li == null ? null : li;
//    try {
//      LIElement li = _entryList.querySelector('.selected').nextElementSibling;
//      return li == null || li.classes.contains('hide') ? null : li;
//    } catch(e) {
//      print(e);
//      return null;
//    }
  }

  /**
   * Observers
   */
  void _observers() {
    _filter.onInput.listen(filter);

    /// These are here to prevent tab'ing out of the filter input.
    _hotKeys.onTab     .listen(_handleTab);
    _hotKeys.onShiftTab.listen(_handleShiftTab);

    _hotKeys.onDown.listen(_handleUpDown);
    _hotKeys.onUp  .listen(_handleUpDown);

    _root.onClick.listen((MouseEvent event) => _select(_getEntryFromClick(event)));
  }

//  /**
//   * Return the [Contact] preceeding the currently selected [Contact].
//   * Return null if we're at first element.
//   */
//  Contact previousContactInList() {
//    LIElement li = _scanBackForVisibleSibling(_contactList.querySelector('.selected'));
//    return li == null ? null : new Contact.fromElement(li);
//  }

  /**
   * Return the [LIElement] preceeding the currently selected [LIElement].
   * Return null if we're at first element.
   */
  LIElement _previousEntryInList() {
    LIElement li = _scanBackForVisibleSibling(_contactList.querySelector('.selected'));
    return li == null ? null : li;
//    try {
//      LIElement li = _entryList.querySelector('.selected').previousElementSibling;
//      return li == null || li.classes.contains('hide') ? null : li;
//    } catch(e) {
//      print(e);
//      return null;
//    }
  }

  /**
   * Mark [entry] selected, if it is !null. This method does not check whether
   * the widget is active or not.
   */
  void _select(LIElement entry) {
    if(entry != null) {
      _markSelected(entry);
    }
  }

  /**
   * Mark the first element of the calendar event list selected.
   */
  void selectFirstEntry() {
    _markSelected(_contactList.children.first);
  }

//  void _registerEventListeners() {
//    _filter.onInput.listen(filter);
//
//    /// These are here to prevent tab'ing out of the filter input.
//    _hotKeys.onTab     .listen(_handleTab);
//    _hotKeys.onShiftTab.listen(_handleShiftTab);
//  }
}
