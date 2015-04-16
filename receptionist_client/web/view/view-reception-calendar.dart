part of view;

class ReceptionCalendar extends ViewWidget {
  Place               _myPlace;
  ReceptionSelector   _receptionSelector;
  UIReceptionCalendar _ui;

  /**
   * Constructor.
   */
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
   * Observers.
   */
  void observers() {
    _navigate.onGo.listen(setWidgetState);

    _ui.onClick    .listen(activateMe);
    _hotKeys.onAltA.listen(activateMe);

    _hotKeys.onCtrlE.listen((_) => _ui.active ? _navigate.goCalendarEdit(_myPlace) : null);

    _receptionSelector.onSelect.listen(render);
  }

  /**
   * Render the widget with [reception] [CalendarEvent]s.
   */
  void render(Reception reception) {
    _ui.clearList();

    if(reception.name.isNotEmpty) {
      _ui.calendarEntries =
          [new CalendarEvent.fromJson({'id': 1, 'contactId': 1, 'receptionId': 1, 'content': 'First entry (${reception.name})'}),
           new CalendarEvent.fromJson({'id': 2, 'contactId': 1, 'receptionId': 1, 'content': 'Second entry (${reception.name})'}),
           new CalendarEvent.fromJson({'id': 3, 'contactId': 1, 'receptionId': 1, 'content': 'Third entry (${reception.name})'}),
           new CalendarEvent.fromJson({'id': 4, 'contactId': 1, 'receptionId': 1, 'content': 'Fourth entry (${reception.name})'})];

      _ui.selectFirstCalendarEntry();
    }
  }
}
