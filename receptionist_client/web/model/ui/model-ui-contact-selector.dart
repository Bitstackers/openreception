/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of model;

/**
 * Provides methods for manipulating the contact selector UI widget.
 */
class UIContactSelector extends UIModel {
  final Bus<ORModel.Contact> _bus = new Bus<ORModel.Contact>();
  final DivElement _myRoot;

  /**
   * Constructor.
   */
  UIContactSelector(DivElement this._myRoot) {
    _setupLocalKeys();
    _observers();
  }

  @override HtmlElement get _firstTabElement => _filter;
  @override HtmlElement get _focusElement => _filter;
  @override HtmlElement get _lastTabElement => _filter;
  @override HtmlElement get _listTarget => _list;
  /**
   * Return the mousedown click event stream for this widget. We capture
   * mousedown instead of regular click to avoid the ugly focus/blur flicker
   * on the filter input whenever a contact li element is clicked.
   */
  @override Stream<MouseEvent> get onClick => _myRoot.onMouseDown;
  @override SelectCallback get _selectCallback => _contactSelectCallback;
  @override HtmlElement get _root => _myRoot;

  OListElement get _list => _root.querySelector('.generic-widget-list');
  InputElement get _filter => _root.querySelector('.filter');

  /**
   * Remove all entries from the contact list.
   */
  void clear() {
    _list.children.clear();
    _filter.value = '';
  }

  /**
   * Add [contacts] to the [Contact] list. Always resets the filter input to
   * empty string.
   */
  set contacts(Iterable<ORModel.Contact> contacts) {
    _filter.value = '';

    final List<LIElement> list = new List<LIElement>();

    contacts.forEach((ORModel.Contact item) {
      String initials = item.fullName
          .split(' ')
          .where((value) => value.trim().isNotEmpty)
          .map((value) => value.substring(0, 1))
          .join()
          .toLowerCase();

      /// Add contact name to tags. We simply treat the name as just another tag
      /// when searching for contacts.
      final List<String> tags = new List<String>()
        ..addAll(item.tags)
        ..addAll(item.fullName.split(' '));

      list.add(new LIElement()
        ..dataset['initials'] = initials
        ..dataset['firstinitial'] = initials.substring(0, 1)
        ..dataset['otherinitials'] = initials.substring(1)
        ..dataset['tags'] = tags.join(',').toLowerCase()
        ..dataset['object'] = JSON.encode(item)
        ..classes.addAll(item.enabled ? [] : ['disabled'])
        ..classes.addAll(item.contactType == 'function' ? ['function'] : [])
        ..text = item.fullName);
    });

    _list.children = list;
  }

  /**
   * Fire a [Contact] on [_bus]. The [Contact] is constructed from JSON found
   * in the data-object attribute of [li].
   */
  void _contactSelectCallback(LIElement li) {
    _bus.fire(new ORModel.Contact.fromMap(JSON.decode(li.dataset['object'])));
  }

  /**
   * Filter the contact list whenever the user enters data into the [_filter]
   * input field.
   */
  void filter() {
    final String filter = _filter.value.toLowerCase();
    final String trimmedFilter = filter.trim();

    if (filter.length == 0 || trimmedFilter.isEmpty) {
      /// Empty filter. Remove .hide from all list elements.
      _list.children.forEach((Element li) => li.classes.toggle('hide', false));
      _list.classes.toggle('zebra', true);
    } else if (trimmedFilter.length == 1 && !filter.startsWith(' ')) {
      /// Pattern: one non-space character followed by zero or more spaces
      _list.classes.toggle('zebra', false);

      _list.children.forEach((Element li) {
        if (li.dataset['firstinitial'] == trimmedFilter) {
          li.classes.toggle('hide', false);
        } else {
          li.classes.toggle('hide', true);
        }
      });
    } else if (trimmedFilter.length == 1 &&
        filter.startsWith(new RegExp(r'\s+[^ ]'))) {
      /// Pattern: one or more spaces followed by one non-space character
      _list.classes.toggle('zebra', false);

      _list.children.forEach((Element li) {
        if (li.dataset['otherinitials'].contains(trimmedFilter)) {
          li.classes.toggle('hide', false);
        } else {
          li.classes.toggle('hide', true);
        }
      });
    } else if (trimmedFilter.length == 3 &&
        trimmedFilter.startsWith(new RegExp(r'[^ ]\s[^ ]'))) {
      /// Pattern: one character, one space, one character
      _list.classes.toggle('zebra', false);

      _list.children.forEach((Element li) {
        if (li.dataset['firstinitial'] == trimmedFilter.substring(0, 1) &&
            li.dataset['otherinitials'].contains(trimmedFilter.substring(2))) {
          li.classes.toggle('hide', false);
        } else {
          li.classes.toggle('hide', true);
        }
      });
    } else {
      /// Split filter string on space and search for contacts that have all
      /// the resulting parts in their tag list.
      final List<String> parts = trimmedFilter.split(' ');

      _list.classes.toggle('zebra', false);

      _list.children.forEach((Element li) {
        if (parts.every((String part) => li.dataset['tags'].contains(part))) {
          li.classes.toggle('hide', false);
        } else {
          li.classes.toggle('hide', true);
        }
      });
    }

    if (_list.children.isNotEmpty) {
      /// Select the first visible item on the list
      _markSelected(_scanForwardForVisibleElement(_list.children.first));
    }
  }

  /**
   * Observers
   */
  void _observers() {
    _filter.onKeyDown.listen(_keyboard.press);

    _filter.onInput.listen((Event _) => filter());

    /// NOTE (TL): Don't switch this to _root.onClick. We need the mousedown
    /// event, not the mouseclick event. We want to keep focus on the filter at
    /// all times.
    onClick.listen(_selectFromClick);
  }

  /**
   * Fires the selected [Contact].
   */
  Stream<ORModel.Contact> get onSelect => _bus.stream;

  /**
   * Remove selections, scroll to top, empty filter input and then select the
   * first contact.
   */
  void _reset(Event _) {
    _filter.value = '';
    filter();
    selectFirstContact();
  }

  /**
   * Returns the currently selected [Contact].
   *
   * Return [Contact.none] if no [Contact] is selected.
   */
  ORModel.Contact get selectedContact {
    LIElement li = _list.querySelector('.selected');

    if (li != null) {
      return new ORModel.Contact.fromMap(JSON.decode(li.dataset['object']));
    } else {
      return new ORModel.Contact.empty();
    }
  }

  /**
   * Select the first [Contact] in the list.
   */
  void selectFirstContact() {
    if (_list.children.isNotEmpty) {
      _markSelected(_scanForwardForVisibleElement(_list.children.first));
    } else {
      _bus.fire(new ORModel.Contact.empty());
    }
  }

  /**
   * Mark a [LIElement] in the contact list selected, if one such is the target
   * of the [event].
   */
  void _selectFromClick(MouseEvent event) {
    if (event.target != _filter) {
      /// NOTE (TL): This keeps focus on the _filter field, despite clicks on
      /// other elements.
      event.preventDefault();

      if (event.target is LIElement) {
        _markSelected(event.target);
      }
    }
  }

  /**
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupLocalKeys() {
    final Map<String, EventListener> bindings = {'Esc': _reset};

    _hotKeys.registerKeysPreventDefault(
        _keyboard, _defaultKeyMap(myKeys: bindings));
  }
}
