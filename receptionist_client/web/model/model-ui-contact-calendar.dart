part of model;

class UIContactCalendar extends UIModel {
  final DivElement _myRoot;

  UIContactCalendar(DivElement this._myRoot) {
    _observers();
  }

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
  set calendarEntries(List<CalendarEvent> items) {
    items.forEach((CalendarEvent item) {
      _entryList.append(new LIElement()
        ..text = item.content
        ..dataset['object'] = JSON.encode(item));
    });
  }

  /**
   * Remove all entries from the entry list.
   */
  void clearList() {
    _entryList.children.clear();
  }

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

  /**
   * Mark [entry] selected.
   */
  void _markSelected(LIElement entry) {
    if(entry != null) {
      _entryList.children.forEach((Element element) => element.classes.remove('selected'));
      entry.classes.add('selected');
      entry.scrollIntoView();
    }
  }

  /**
   * Return the [LIElement] following the currently selected [LIElement].
   * Return null if we're at last element.
   */
  LIElement _nextEntryInList() {
    try {
      LIElement li = _entryList.querySelector('.selected').nextElementSibling;
      return li == null || li.classes.contains('hide') ? null : li;
    } catch(e) {
      print(e);
      return null;
    }
  }

  /**
   * Observers
   */
  void _observers() {
    _hotKeys.onDown.listen(_handleUpDown);
    _hotKeys.onUp  .listen(_handleUpDown);

    _root.onClick.listen((MouseEvent event) => _select(_getEntryFromClick(event)));
  }

  /**
   * Return the [LIElement] preceeding the currently selected [LIElement].
   * Return null if we're at first element.
   */
  LIElement _previousEntryInList() {
    try {
      LIElement li = _entryList.querySelector('.selected').previousElementSibling;
      return li == null || li.classes.contains('hide') ? null : li;
    } catch(e) {
      print(e);
      return null;
    }
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
  void selectFirstCalendarEntry() {
    _markSelected(_entryList.children.first);
  }
}
