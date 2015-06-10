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
class UIReceptionCalendar extends UIModel {
  final Bus<KeyboardEvent> _busEdit   = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _busNew    = new Bus<KeyboardEvent>();
  final DivElement         _myRoot;
  final ORUtil.WeekDays    _weekDays;

  /**
   * Constructor.
   */
  UIReceptionCalendar(DivElement this._myRoot, ORUtil.WeekDays this._weekDays) {
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
   * Add [items] to the entry list.
   */
  set calendarEntries(Iterable<ORModel.CalendarEntry> items) {
    final List<LIElement> list = new List<LIElement>();

    items.forEach((ORModel.CalendarEntry item) {
      final DivElement content = new DivElement()..text = item.content;

      final String start = ORUtil.humanReadableTimestamp(item.start, _weekDays);
      final String stop = ORUtil.humanReadableTimestamp(item.stop, _weekDays);
      final DivElement timeStamps = new DivElement()
                                      ..classes.add('timestamps')
                                      ..text = '${start} - ${stop}';

      list.add(new LIElement()
                ..children.addAll([content, timeStamps])
                ..title = 'Id: ${item.ID.toString()}'
                ..dataset['object'] = JSON.encode(item)
                ..classes.toggle('active', item.active));
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
   * Fire the [onEdit] stream if an event is selected, else don't do anything.
   */
  void _maybeEdit(KeyboardEvent event) {
    if(_list.querySelector('.selected') != null) {
      _busEdit.fire(event);
    }
  }

  /**
   * Return currently selected [ReceptionCalendarEntry].
   * Return [ReceptionCalendarEntry.empty] if nothing is selected.
   */
  ORModel.CalendarEntry get selectedCalendarEntry {
    final LIElement selected = _list.querySelector('.selected');

    if(selected != null) {
      return new ORModel.CalendarEntry.fromMap(JSON.decode(selected.dataset['object']));
    } else {
      return new ORModel.CalendarEntry.empty();
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
   * Fires when a [ReceptionCalendarEntry] edit is requested from somewhere.
   */
  Stream<KeyboardEvent> get onEdit => _busEdit.stream;

  /**
   * Fires when a [ReceptionCalendarEntry] new is requested from somewhere.
   */
  Stream<KeyboardEvent> get onNew => _busNew.stream;

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
        {'Ctrl+e': _maybeEdit,
         'Ctrl+k': _busNew.fire};

    _hotKeys.registerKeysPreventDefault(_keyboard, _defaultKeyMap(myKeys: bindings));
  }
}
