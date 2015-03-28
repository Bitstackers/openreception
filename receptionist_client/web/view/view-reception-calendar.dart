part of view;

class ReceptionCalendar extends Widget {
<<<<<<< Updated upstream
  final CalendarEditor _calendarEditor = new CalendarEditor(new UICalendarEditor(querySelector('#calendar-editor')));
  Place               _myPlace;
  UIReceptionCalendar _ui;
=======
  Place                _myPlace;
  DomReceptionCalendar _dom;
>>>>>>> Stashed changes

  /**
   * [root] is the parent element of the widget, and [_myPlace] is the [Place]
   * object that this widget reacts on when Navigate.go fires.
   */
  ReceptionCalendar(DomReceptionCalendar this._dom, Place this._myPlace) {
    _registerEventListeners();
  }

  void _activateMe(_) {
    _navigateToMyPlace();
  }

  @override
  HtmlElement get focusElement => _dom.eventList;

  @override
  Place get myPlace => _myPlace;

  void _registerEventListeners() {
    _navigate.onGo.listen(_setWidgetState);

    _dom.root.onClick.listen(_activateMe);

    _hotKeys.onAltA.listen(_activateMe);

    // TODO (TL): temporary stuff
<<<<<<< Updated upstream
    _ui.eventList.onDoubleClick.listen((_) {
//      _bus.fire('Ret event fra ReceptionCalendar');
      _calendarEditor.activate('Event from reception calendar');
    });
=======
    _dom.eventList.onDoubleClick.listen((_) => _navigate.goCalendarEdit());
>>>>>>> Stashed changes
  }

  @override
  HtmlElement get root => _dom.root;
}
