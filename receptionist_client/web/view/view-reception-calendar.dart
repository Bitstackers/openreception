part of view;

class ReceptionCalendar extends ViewWidget {
  Place               _myPlace;
  ReceptionSelector   _receptionSelector;
  UIReceptionCalendar _ui;

  ReceptionCalendar(UIModel this._ui, Place this._myPlace, this._receptionSelector) {
    _ui.help = 'alt+a';

    observers();
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

  void observers() {
    _navigate.onGo.listen(setWidgetState);

    _ui.onClick.listen(activateMeFromClick);

    _hotKeys.onAltA .listen(activateMe);
    _hotKeys.onCtrlE.listen((_) => _ui.active ? _navigate.goCalendarEdit(_myPlace) : null);

    _hotKeys.onDown.listen(_handleUpDown);
    _hotKeys.onUp  .listen(_handleUpDown);

    _receptionSelector.onSelect.listen(render);
  }

  /**
   * Render the widget with .....
   */
  void render(Reception reception) {
    _ui.clearList();

    if(reception.name.isNotEmpty) {
      _ui.calendarEntries = [new CalendarEntry('First entry (${reception.name})'),
                             new CalendarEntry('Second entry (${reception.name})'),
                             new CalendarEntry('Third entry (${reception.name})'),
                             new CalendarEntry('Fourth entry (${reception.name})'),
                             new CalendarEntry('Fifth entry (${reception.name})'),
                             new CalendarEntry('Sixth entry (${reception.name})')];

      _ui.markSelected(_ui.getFirstEntry());
    }
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
}
