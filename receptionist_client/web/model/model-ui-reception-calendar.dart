part of model;

class UIReceptionCalendar extends UIModel {
  final DivElement _myRoot;

  UIReceptionCalendar(DivElement this._myRoot);

  @override HtmlElement    get _firstTabElement => null;
  @override HtmlElement    get _focusElement    => _entryList;
  @override HeadingElement get _header          => _root.querySelector('h4');
  @override DivElement     get _help            => _root.querySelector('div.help');
  @override HtmlElement    get _lastTabElement  => null;
  @override HtmlElement    get _root            => _myRoot;

  OListElement get _entryList => _root.querySelector('.generic-widget-list');

  /**
   * Add [items] to the entry list.
   */
  set calendarEntries(List<CalendarEntry> items) {
    items.forEach((CalendarEntry item) {
      _entryList.append(item._li);
    });
  }

  /**
   * Remove all entries from the entry list.
   */
  void clearList() {
    _entryList.children.clear();
  }

  /**
   * Return the first [CalendarEntry] from [_entryList]
   * MAY return null if the list is empty.
   */
  CalendarEntry getFirstEntry() {
    LIElement li = _entryList.children.first;
    if(li != null) {
      return new CalendarEntry.fromElement(li);
    }

    return null;
  }

  /**
   * Return the [CalendarEntry] the user clicked on.
   * MAY return null if the user did not click on an actual valid [CalendarEntry].
   */
  CalendarEntry getEntryFromClick(MouseEvent event) {
    if(event.target is LIElement) {
      return new CalendarEntry.fromElement(event.target);
    }

    return null;
  }

  /**
   * Mark [CalendarEntry] selected.
   */
  void markSelected(CalendarEntry entry) {
    if(entry != null) {
      _entryList.children.forEach((Element element) => element.classes.remove('selected'));
      entry._li.classes.add('selected');
      entry._li.scrollIntoView();
    }
  }

  /**
   * Return the [CalendarEntry] following the currently selected [CalendarEntry].
   * Return null if we're at last element.
   */
  CalendarEntry nextEntryInList() {
    try {
      LIElement li = _entryList.querySelector('.selected').nextElementSibling;
      return li == null || li.classes.contains('hide') ? null : new CalendarEntry.fromElement(li);
    } catch(e) {
      print(e);
      return null;
    }
  }

  /**
   * Return the [CalendarEntry] preceeding the currently selected [CalendarEntry].
   * Return null if we're at first element.
   */
  CalendarEntry previousEntryInList() {
    try {
      LIElement li = _entryList.querySelector('.selected').previousElementSibling;
      return li == null || li.classes.contains('hide') ? null : new CalendarEntry.fromElement(li);
    } catch(e) {
      print(e);
      return null;
    }
  }
}
