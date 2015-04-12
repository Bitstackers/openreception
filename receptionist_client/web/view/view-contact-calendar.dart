part of view;

class ContactCalendar extends ViewWidget {
  ContactSelector   _contactSelector;
  Place             _myPlace;
  UIContactCalendar _ui;

  ContactCalendar(UIModel this._ui, Place this._myPlace, ContactSelector this._contactSelector) {
    _ui.help = 'alt+k';

    registerEventListeners();

    test(); // TODO (TL): Get rid of this testing code...
  }

  @override Place   get myPlace => _myPlace;
  @override UIModel get ui      => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  /**
   * Simply navigate to my [Place]. Matters not if this widget is already
   * focused.
   */
  void activateMe(_) {
    navigateToMyPlace();
  }

  /**
   * Activate this widget if it's not already active. Also mark an entry in the
   * list selected, if one such is the target of the [event].
   */
  void activateMeFromClick(MouseEvent event) {
    clickSelect(_ui.getEntryFromClick(event));
    navigateToMyPlace();
  }

  /**
   * Mark [CalendarEntry] selected. This call does not check if we're active. Use
   * this to select a contact using the mouse, else use the plain [select]
   * function.
   */
  void clickSelect(CalendarEntry entry) {
    if(entry != null) {
      _ui.markSelected(entry);
    }
  }

  /**
   * Deal with arrow up/down.
   */
  void _handleUpDown(KeyboardEvent event) {
    if(_ui.active) {
      event.preventDefault();
      switch(event.keyCode) {
        case KeyCode.DOWN:
          select(_ui.nextEntryInList());
          break;
        case KeyCode.UP:
          select(_ui.previousEntryInList());
          break;
      }
    }
  }

  void registerEventListeners() {
    _navigate.onGo.listen(setWidgetState);

    _ui.onClick.listen(activateMeFromClick);

    _hotKeys.onAltK .listen(activateMe);
    _hotKeys.onCtrlE.listen((_) => _ui.active ? _navigate.goCalendarEdit(_myPlace) : null);

    _hotKeys.onDown.listen(_handleUpDown);
    _hotKeys.onUp  .listen(_handleUpDown);

    _contactSelector.onSelect.listen(render);
  }

  /**
   * Render the widget with [Contact].
   */
  void render(Contact contact) {
    print('ContactCalendar received ${contact.name}');
  }

  /**
   * Mark [CalendarEntry] selected. This call checks if we're active. Do not use this
   * to select items using the mouse.
   */
  void select(CalendarEntry entry) {
    if(_ui.active && entry != null) {
      _ui.markSelected(entry);
    }
  }

  /// TODO (TL): Get rid of this. It's just here to test stuff.
  void test() {
    _ui.calendarEntries = [new CalendarEntry('First entry'),
                           new CalendarEntry('Second entry'),
                           new CalendarEntry('Third entry'),
                           new CalendarEntry('Fourth entry')];

    _ui.markSelected(_ui.getFirstEntry());
  }
}
