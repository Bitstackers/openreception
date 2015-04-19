part of model;

class UIContactCalendar extends UIModel {
  final DivElement _myRoot;

  /**
   * Constructor.
   */
  UIContactCalendar(DivElement this._myRoot) {
    _observers();
  }

  @override HtmlElement    get _firstTabElement => null;
  @override HtmlElement    get _focusElement    => _eventList;
  @override HeadingElement get _header          => _root.querySelector('h4');
  @override DivElement     get _help            => _root.querySelector('div.help');
  @override HtmlElement    get _lastTabElement  => null;
  @override HtmlElement    get _root            => _myRoot;

  OListElement get _eventList => _root.querySelector('.generic-widget-list');

  /**
   * Add [items] to the [CalendarEvent] list. Note that this method does not
   * clear the list before adding new items. It merely appends to the list.
   */
  set calendarEvents(List<CalendarEvent> items) {
    final List<LIElement> list =  new List<LIElement>();

    items.forEach((CalendarEvent item) {
      list.add(new LIElement()
                ..text = item.content
                ..dataset['object'] = JSON.encode(item));
    });

    _eventList.children = list;
  }

  /**
   * Remove all entries from the entry list and clear the header.
   */
  void clear() {
    _header.text = '';
    _eventList.children.clear();
  }

  /**
   * Return currently selected [CalendarEvent]. Return null event if nothing
   * is selected.
   */
  CalendarEvent get selected {
    final LIElement selected = _eventList.querySelector('.selected');

    if(selected != null) {
      return new CalendarEvent.fromJson(JSON.decode(selected.dataset['object']));
    } else {
      return new CalendarEvent.Null();
    }
  }

  /**
   * Deal with arrow up/down.
   */
  void _handleUpDown(KeyboardEvent event) {
    if(isFocused && _eventList.children.isNotEmpty) {
      final LIElement selected = _eventList.querySelector('.selected');
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
   * Mark [li] selected, scroll it into view.
   * Does nothing if [li] is null or [li] is already selected.
   */
  void _markSelected(LIElement li) {
    if(li != null && !li.classes.contains('selected')) {
      _eventList.children.forEach((Element element) => element.classes.remove('selected'));
      li.classes.add('selected');
      li.scrollIntoView();
    }
  }

  /**
   * Observers
   */
  void _observers() {
    _hotKeys.onDown.listen(_handleUpDown);
    _hotKeys.onUp  .listen(_handleUpDown);

    _root.onClick.listen(_selectFromClick);
  }

  /**
   * Select the first [CalendarEvent] in the list.
   */
  void selectFirstCalendarEvent() {
    if(_eventList.children.isNotEmpty) {
      _markSelected(_scanForwardForVisibleElement(_eventList.children.first));
    }
  }

  /**
   * Mark a [LIElement] in the event list selected, if one such is the target
   * of the [event].
   */
  void _selectFromClick(MouseEvent event) {
    if(event.target is LIElement) {
      _markSelected(event.target);
    }
  }
}
