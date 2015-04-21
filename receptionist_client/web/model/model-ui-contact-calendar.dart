part of model;

class UIContactCalendar extends UIModel {
  final Bus<KeyboardEvent> _busEdit   = new Bus<KeyboardEvent>();
  final Bus<KeyboardEvent> _busNew    = new Bus<KeyboardEvent>();
  final Keyboard           _keyboard  = new Keyboard();
  final DivElement         _myRoot;

  /**
   * Constructor.
   */
  UIContactCalendar(DivElement this._myRoot) {
    _help.text = 'alt+k';

    _setupWidgetKeys();
    _observers();
  }

  @override HtmlElement get _firstTabElement => _root;
  @override HtmlElement get _focusElement    => _root;
  @override SpanElement get _header          => _root.querySelector('h4 > span');
  @override SpanElement get _headerExtra     => _root.querySelector('h4 > span + span');
  @override DivElement  get _help            => _root.querySelector('div.help');
  @override HtmlElement get _lastTabElement  => _root;
  @override HtmlElement get _root            => _myRoot;

  OListElement get _eventList => _root.querySelector('.generic-widget-list');

  /**
   * Add [items] to the [CalendarEvent] list.
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
    _headerExtra.text = '';
    _eventList.children.clear();
  }

  /**
   * Return currently selected [CalendarEvent]. Return null event if nothing
   * is selected.
   */
  CalendarEvent get selectedCalendarEvent {
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
    if(_eventList.children.isNotEmpty) {
      final LIElement selected = _eventList.querySelector('.selected');

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
    _root.onKeyDown.listen(_keyboard.press);
    _root.onClick.listen(_selectFromClick);
  }

  /**
   * Fires when a [CalendarEvent] edit is requested from somewhere.
   */
  Stream<KeyboardEvent> get onEdit   => _busEdit.stream;

  /**
   * Fires when a [CalendarEvent] new is requested from somewhere.
   */
  Stream<KeyboardEvent> get onNew    => _busNew.stream;

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

  /**
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupWidgetKeys() {
    final Map<String, EventListener> bindings =
        {'Ctrl+e'   : _busEdit.fire,
         'Ctrl+k'   : _busNew.fire,
         'down'     : _handleUpDown,
         'Shift+Tab': _handleShiftTab,
         'Tab'      : _handleTab,
         'up'       : _handleUpDown};

    _hotKeys.registerKeysPreventDefault(_keyboard, bindings);
  }
}
