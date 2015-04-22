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

      item._li.dataset['initials'] = initials;
      item._li.dataset['firstinitial'] = initials.substring(0,1);
      item._li.dataset['otherinitials'] = initials.substring(1);

      /// TODO  (TL): Adding the name as "tags" is perhaps not the best idea in
      /// the world, but it works right now.
      ///
      /// Add contact name to tags. We simply treat the name as just another tag
      /// when searching for contacts.
      item.tags.addAll(item.name.split(' '));
      item._li.dataset['tags'] = item.tags.join(',').toLowerCase();

      _contactList.append(item._li);
    });
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
    markSelected(getContactFirstVisible());
  }

  /**
   * Return the selected [Contact] from [_contactList]
   * MAY return null if nothing is selected.
   */
  Contact getSelectedContact() {
    try {
      return new Contact.fromElement(_contactList.querySelector('.selected'));
    } catch (e) {
      print(e);
      return null;
    }
  }

  /**
   * Return the [Contact] the user clicked on.
   * MAY return null if the user did not click on an actual valid [Contact].
   */
  Contact getContactFromClick(MouseEvent event) {
    if(event.target is LIElement) {
      return new Contact.fromElement(event.target);
    }

    return null;
  }

  /**
   * Return the first visible [Contact] from [_contactList]
   * MAY return null if the list is empty.
   */
  Contact getContactFirstVisible() {
    LIElement li = _contactList.children.firstWhere((LIElement li) => !li.classes.contains('hide'), orElse: () => null);
    if(li != null) {
      return new Contact.fromElement(li);
    }

    return null;
  }

  /**
   * Mark [contact] selected.
   */
  void markSelected(Contact contact) {
    if(contact != null) {
      _contactList.children.forEach((Element element) => element.classes.remove('selected'));
      contact._li.classes.add('selected');
      contact._li.scrollIntoView();
    }
  }

  /**
   * Return the [Contact] following the currently selected [Contact].
   * Return null if we're at last element.
   */
  Contact nextContactInList() {
    LIElement li = scanAheadForVisibleSibling(_contactList.querySelector('.selected'));
    return li == null ? null : new Contact.fromElement(li);
  }

  /**
   * Return the [Contact] preceeding the currently selected [Contact].
   * Return null if we're at first element.
   */
  Contact previousContactInList() {
    LIElement li = scanBackForVisibleSibling(_contactList.querySelector('.selected'));
    return li == null ? null : new Contact.fromElement(li);
  }

  void _registerEventListeners() {
    _filter.onInput.listen(filter);

    /// These are here to prevent tab'ing out of the filter input.
    _hotKeys.onTab     .listen(handleTab);
    _hotKeys.onShiftTab.listen(handleShiftTab);
  }
}
