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
 * TODO (TL): Comment
 */
class UIContactCalendar extends UIModel {
  final Bus<KeyboardEvent> _busEdit = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _busNew  = new Bus<KeyboardEvent>();
  final DivElement         _myRoot;

  /**
   * Constructor.
   */
  UIContactCalendar(DivElement this._myRoot) {
    _setupLocalKeys();
    _observers();
  }

  @override HtmlElement get _firstTabElement => _root;
  @override HtmlElement get _focusElement    => _root;
  @override HtmlElement get _lastTabElement  => _root;
  @override HtmlElement get _listTarget      => _list;
  @override HtmlElement get _root            => _myRoot;

  OListElement get _list => _root.querySelector('.generic-widget-list');

  /**
   * Add [items] to the [CalendarEntry] list.
   */
  set calendarEntries(Iterable<ContactCalendarEntry> items) {
    final List<LIElement> list =  new List<LIElement>();

    items.forEach((ContactCalendarEntry item) {
      list.add(new LIElement()
                ..text = item.content
                ..dataset['object'] = JSON.encode(item));
    });

    _list.children = list;
  }

  /**
   * Remove all entries from the entry list and clear the header.
   */
  void clear() {
    _headerExtra.text = '';
    _list.children.clear();
  }

  /**
   * Return currently selected [ContactCalendarEntry]. Return empty entry if
   * nothing is selected.
   */
  ContactCalendarEntry get selectedCalendarEntry {
    final LIElement selected = _list.querySelector('.selected');

    if(selected != null) {
      return new ContactCalendarEntry.fromMap(JSON.decode(selected.dataset['object']));
    } else {
      return new ContactCalendarEntry.empty();
    }
  }

  /**
   * Observers
   */
  void _observers() {
    _root.onKeyDown.listen(_keyboard.press);
    _root.onClick.listen(_selectFromClick);
  }

  /**
   * Fires when a [CalendarEntry] edit is requested from somewhere.
   */
  Stream<KeyboardEvent> get onEdit => _busEdit.stream;

  /**
   * Fires when a [CalendarEvent] new is requested from somewhere.
   */
  Stream<KeyboardEvent> get onNew => _busNew.stream;

  /**
   * Select the first [ContactCalendarEntry] in the list.
   */
  void selectFirstCalendarEntry() {
    if(_list.children.isNotEmpty) {
      _markSelected(_scanForwardForVisibleElement(_list.children.first));
    }
  }

  /**
   * Mark a [LIElement] in the calendar entry list selected, if one such is the
   * target of the [event].
   */
  void _selectFromClick(MouseEvent event) {
    if(event.target is LIElement) {
      _markSelected(event.target);
    }
  }

  /**
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupLocalKeys() {
    final Map<String, EventListener> bindings =
        {'Ctrl+e': _busEdit.fire,
         'Ctrl+k': _busNew.fire};

    _hotKeys.registerKeysPreventDefault(_keyboard, _defaultKeyMap(myKeys: bindings));
  }
}
