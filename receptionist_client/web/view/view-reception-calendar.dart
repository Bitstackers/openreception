part of view;

class ReceptionCalendar extends Widget {
//  final Bus<String>   _bus = new Bus<String>();
  final CalendarEditor _calendarEditor = new CalendarEditor(new UICalendarEditor(querySelector('#calendar-editor')));
  Place               _myPlace;
  UIReceptionCalendar _ui;

  /**
   * [root] is the parent element of the widget, and [_myPlace] is the [Place]
   * object that this widget reacts on when Navigate.go fires.
   */
  ReceptionCalendar(UIReceptionCalendar this._ui, Place this._myPlace) {
    _registerEventListeners();
  }

  void _activateMe(_) {
    _activate();
  }

  HtmlElement get focusElement => _ui.eventList;

  Place get myPlace => _myPlace;

  /**
   *
   */
//  Stream<String> get onEdit => _bus.stream;

  void _registerEventListeners() {
    _navigate.onGo.listen(_setWidgetState);

    _ui.root.onClick.listen(_activateMe);

    _hotKeys.onAltA.listen(_activateMe);

    // TODO (TL): temporary stuff
    _ui.eventList.onDoubleClick.listen((_) {
//      _bus.fire('Ret event fra ReceptionCalendar');
      _calendarEditor.activate('Event from reception calendar');
    });
  }

  HtmlElement get root => _ui.root;
}
