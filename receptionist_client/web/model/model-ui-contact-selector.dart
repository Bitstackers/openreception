part of model;

class UIContactSelector extends UIModel {
  Bus<Contact> _bus = new Bus<Contact>();
  final DivElement _myRoot;

  /**
   * Constructor.
   */
  UIContactSelector(DivElement this._myRoot) {
    _observers();
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
   * Remove all entries from the contact list.
   */
  void clearList() {
    _contactList.children.clear();
  }

  /**
   * Add [items] to the [Contact] list. Note that this method does not clear the
   * list before adding new items. It merely appends to the list.
   */
  set contacts(List<Contact> items) {
    List<LIElement> list = new List<LIElement>();

    items.forEach((Contact item) {
      String initials = item.name.trim().split(' ').fold('', (acc, value) => '${acc}${value.substring(0,1).toLowerCase()}');

      /// Add contact name to tags. We simply treat the name as just another tag
      /// when searching for contacts.
      item.tags.addAll(item.name.split(' '));

      list.add(new LIElement()
                 ..dataset['initials']      = initials
                 ..dataset['firstinitial']  = initials.substring(0,1)
                 ..dataset['otherinitials'] = initials.substring(1)
                 ..dataset['tags']          = item.tags.join(',').toLowerCase()
                 ..dataset['object']        = JSON.encode(item)
                 ..text = item.name);
    });

    _contactList.children = list;
  }

  /**
   * Filter the contact list whenever the user enters data into the [_filter]
   * input field.
   */
  void _filterList(_) {
    String filter = _filter.value.toLowerCase();
    String trimmedFilter = filter.trim();

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

    /// Select the first visible item on the list
    _markSelected(_scanForwardForVisibleElement(_contactList.children.first));
  }

  /**
   * Deal with arrow up/down.
   */
  void _handleUpDown(KeyboardEvent event) {
    if(active && _contactList.children.isNotEmpty) {
      LIElement selected = _contactList.querySelector('.selected');
      event.preventDefault();

      switch(event.keyCode) {
        case KeyCode.DOWN:
          _markSelected(_scanForwardForVisibleElement(selected.nextElementSibling));
          break;
        case KeyCode.UP:
          _markSelected(_scanBackwardsForVisibleElement(selected.previousElementSibling));
          break;
      }
    }
  }

  /**
   * Mark [li] selected, scroll it into view and fire the [Contact] contained
   * in the [li] on the [onSelect] bus.
   * Does nothing if [li] is null or [li] is already selected.
   */
  void _markSelected(LIElement li) {
    if(li != null && !li.classes.contains('selected')) {
      _contactList.children.forEach((Element element) => element.classes.remove('selected'));
      li.classes.add('selected');
      li.scrollIntoView();
      _bus.fire(new Contact.fromJson(JSON.decode(li.dataset['object'])));
    }
  }

  /**
   * Observers
   */
  void _observers() {
    _filter.onInput.listen(_filterList);

    /// These are here to prevent tab'ing out of the filter input.
    _hotKeys.onTab     .listen(_handleTab);
    _hotKeys.onShiftTab.listen(_handleShiftTab);

    _hotKeys.onDown.listen(_handleUpDown);
    _hotKeys.onUp  .listen(_handleUpDown);

    /// NOTE (TL): Don't switch this to _root.onClick. We need the mousedown
    /// event, not the mouseclick event. We want to keep focus on the filter at
    /// all times.
    onClick.listen(_selectFromClick);
  }

  /**
   * Fires the selected [Contact].
   */
  Stream<Contact> get onSelect => _bus.stream;

  /**
   * Select the first [Contact] in the list.
   */
  void selectFirstContact() {
    if(_contactList.children.isNotEmpty) {
      LIElement li = _scanForwardForVisibleElement(_contactList.children.first);
      _markSelected(li);
    }
  }

  /**
   * Mark a [LIElement] in the contact list selected, if one such is the target
   * of the [event].
   */
  void _selectFromClick(MouseEvent event) {
    if(event.target != _filter) {
      /// NOTE (TL): This keeps focus on the _filter field, despite clicks on
      /// other elements.
      event.preventDefault();

      if(event.target is LIElement) {
        _markSelected(event.target);
      }
    }
  }
}
