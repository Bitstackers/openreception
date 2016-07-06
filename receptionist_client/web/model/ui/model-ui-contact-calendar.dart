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
 * Provides methods for manipulating the contact calendar UI widget.
 */
class UIContactCalendar extends UIModel {
  final Map<String, String> _langMap;
  final DivElement _myRoot;
  final ORUtil.WeekDays _weekDays;
  final NodeValidatorBuilder _validator = new NodeValidatorBuilder()
    ..allowTextElements()
    ..allowHtml5()
    ..allowInlineStyles();

  /**
   * Constructor.
   */
  UIContactCalendar(DivElement this._myRoot, ORUtil.WeekDays this._weekDays,
      Map<String, String> this._langMap) {
    _setupLocalKeys();
    _observers();
  }

  @override
  HtmlElement get _firstTabElement => _root;
  @override
  HtmlElement get _focusElement => _root;
  @override
  HtmlElement get _lastTabElement => _root;
  @override
  HtmlElement get _listTarget => _list;
  @override
  HtmlElement get _root => _myRoot;

  OListElement get _list => _root.querySelector('.generic-widget-list');

  /**
   * Construct a calendar entry LIElement from [entry]
   */
  LIElement _buildEntryElement(ORModel.CalendarEntry entry) {
    final DateTime now = new DateTime.now();

    bool isToday(DateTime stamp) =>
        stamp.day == now.day &&
        stamp.month == now.month &&
        stamp.year == now.year;

    SpanElement labelElement(ORModel.CalendarEntry item) {
      final SpanElement label = new SpanElement();

      if (!item.active) {
        final DateTime now = new DateTime.now();
        if (item.start.isBefore(now)) {
          label.classes.add('label-past');
          label.text = _langMap[Key.past];
        } else {
          label.classes.add('label-future');
          label.text = _langMap[Key.future];
        }
      }

      return label;
    }

    final DivElement content = new DivElement()
      ..classes.add('markdown')
      ..setInnerHtml(Markdown.markdownToHtml(entry.content),
          validator: _validator);

    String start = ORUtil.humanReadableTimestamp(entry.start, _weekDays);
    String stop = ORUtil.humanReadableTimestamp(entry.stop, _weekDays);

    if (isToday(entry.start) && !isToday(entry.stop)) {
      start = '${_langMap[Key.today]} $start';
    }

    if (isToday(entry.stop) && !isToday(entry.start)) {
      stop = '${_langMap[Key.today]} $stop';
    }

    final DivElement labelAndTimestamp = new DivElement()
      ..classes.add('label-and-timestamp')
      ..children.addAll([
        labelElement(entry),
        new SpanElement()
          ..classes.add('timestamp')
          ..text = '${start} - ${stop}'
      ]);

    return new LIElement()
      ..children.addAll([content, labelAndTimestamp])
      ..title = 'Id: ${entry.id.toString()}'
      ..dataset['object'] = JSON.encode(entry)
      ..dataset['id'] = entry.id.toString()
      ..classes.toggle('active', entry.active);
  }

  /**
   * Add [items] to the [CalendarEntry] list.
   */
  set calendarEntries(Iterable<ORModel.CalendarEntry> items) {
    _list.children = items.map(_buildEntryElement).toList(growable: false);
  }

  /**
   * Remove all entries from the entry list and clear the header.
   */
  void clear() {
    _headerExtra.text = '';
    _list.children.clear();
  }

  /**
   * Return the first [ContactCalendarEntry]. Return empty entry if list is
   * empty.
   */
  ORModel.CalendarEntry get firstCalendarEntry {
    try {
      return new ORModel.CalendarEntry.fromMap(
          JSON.decode(_list.children.first.dataset['object']));
    } catch (_) {
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
   * Delete the [entry] in the calendar entry list. This does not perform any
   * action on the server.
   *
   * The returned function re-instates the entry into the list when called.
   */
  Function preDeleteEntry(ORModel.CalendarEntry entry) {
    final LIElement li = _list.querySelector('[data-id="${entry.id}"]');
    li.style.display = 'none';

    return () => li.style.display = 'block';
  }

  /**
   * Return currently selected [ContactCalendarEntry]. Return empty entry if
   * nothing is selected.
   */
  ORModel.CalendarEntry get selectedCalendarEntry {
    final LIElement selected = _list.querySelector('.selected');

    if (selected != null) {
      return new ORModel.CalendarEntry.fromMap(
          JSON.decode(selected.dataset['object']));
    } else {
      return new ORModel.CalendarEntry.empty();
    }
  }

  /**
   * Mark a [LIElement] in the calendar entry list selected, if one such is the
   * target of the [event].
   */
  void _selectFromClick(MouseEvent event) {
    if (event.target is LIElement) {
      _markSelected(event.target);
    }
  }

  /**
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupLocalKeys() {
    _hotKeys.registerKeysPreventDefault(_keyboard, _defaultKeyMap(myKeys: {}));
  }

  /**
   * Either add or update the [entry] in the calendar entry listing. This does
   * not perform any actions on the server.
   *
   * The returned function removes the created/changed LIElement when called.
   */
  Function unsavedEntry(ORModel.CalendarEntry entry) {
    final LIElement newLi = _buildEntryElement(entry);

    if (entry.id == ORModel.CalendarEntry.noId) {
      if (_list.children.isEmpty) {
        _list.children.add(newLi);
      } else {
        LIElement found;
        for (LIElement li in _list.children) {
          final ORModel.CalendarEntry foundEntry =
              new ORModel.CalendarEntry.fromMap(
                  JSON.decode(li.dataset['object']));
          if (foundEntry.start.isAfter(entry.start) ||
              foundEntry.start.isAtSameMomentAs(entry.start)) {
            found = li;
            break;
          }
        }

        if (found != null) {
          _list.insertBefore(newLi, found);
        } else {
          _list.children.add(newLi);
        }
      }
    } else {
      final LIElement orgLi = _list.querySelector('[data-id="${entry.id}"]');
      orgLi.replaceWith(newLi);
    }

    return () => newLi.remove();
  }
}
