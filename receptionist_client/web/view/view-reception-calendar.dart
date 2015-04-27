part of view;

class ReceptionCalendar extends ViewWidget {
  final Controller.Destination    _myDestination;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIReceptionCalendar _ui;

  /**
   * Constructor.
   */
  ReceptionCalendar(Model.UIModel this._ui,
                    Controller.Destination this._myDestination,
                    Model.UIReceptionSelector this._receptionSelector) {
    _ui.setHint('alt+a');
    observers();
  }

  @override Controller.Destination get myDestination => _myDestination;
  @override Model.UIModel          get ui            => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  /**
   * Simply navigate to my [Destination]. Matters not if this widget is already
   * focused.
   */
  void activateMe(_) {
    navigateToMyDestination();
  }

  /**
   * Observers.
   */
  void observers() {
    _navigate.onGo.listen(setWidgetState);

    _hotKeys.onAltA.listen(activateMe);

    _ui.onClick .listen(activateMe);
    _ui.onEdit  .listen((_) => _navigate.goCalendarEdit(from: _myDestination..cmd = Cmd.EDIT));
    _ui.onNew   .listen((_) => _navigate.goCalendarEdit(from: _myDestination..cmd = Cmd.NEW));

    _receptionSelector.onSelect.listen(render);
  }

  /**
   * Render the widget with [reception] [CalendarEvent]s.
   */
  void render(Reception reception) {
    if(reception.isNull) {
      _ui.clear();
    } else {
      _ui.headerExtra = 'for ${reception.name}';
      _ui.calendarEntries =
          [new CalendarEvent.fromJson({'id': 1, 'contactId': 1, 'receptionId': 1, 'content': 'First entry (${reception.name})'}),
           new CalendarEvent.fromJson({'id': 2, 'contactId': 1, 'receptionId': 1, 'content': 'Second entry (${reception.name})'}),
           new CalendarEvent.fromJson({'id': 3, 'contactId': 1, 'receptionId': 1, 'content': 'Third entry (${reception.name})'}),
           new CalendarEvent.fromJson({'id': 4, 'contactId': 1, 'receptionId': 1, 'content': 'Fourth entry (${reception.name})'})];

      _ui.selectFirstCalendarEvent();
    }
  }
}
