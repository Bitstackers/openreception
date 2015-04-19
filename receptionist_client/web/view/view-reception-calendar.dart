part of view;

class ReceptionCalendar extends ViewWidget {
  final Controller.Place          _myPlace;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIReceptionCalendar _ui;

  /**
   * Constructor.
   */
  ReceptionCalendar(Model.UIModel this._ui,
                    Controller.Place this._myPlace,
                    Model.UIReceptionSelector this._receptionSelector) {
    _ui.help = 'alt+a';

    observers();
  }

  @override Controller.Place get myPlace => _myPlace;
  @override Model.UIModel    get ui      => _ui;

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

    /// Delete and Edit. The actual edit/delete decision is made in the Calendar
    /// Editor.
    _hotKeys.onCtrlD.listen((_) => _ui.isFocused ? _navigate.goCalendarEdit(_myPlace) : null);
    _hotKeys.onCtrlE.listen((_) => _ui.isFocused ? _navigate.goCalendarEdit(_myPlace) : null);

    _receptionSelector.onSelect.listen(render);
  }

  /**
   * Render the widget with [reception] [CalendarEvent]s.
   */
  void render(Reception reception) {
//    _ui.clearList();

    if(!reception.isNull) {
      _ui.calendarEntries =
          [new CalendarEvent.fromJson({'id': 1, 'contactId': 1, 'receptionId': 1, 'content': 'First entry (${reception.name})'}),
           new CalendarEvent.fromJson({'id': 2, 'contactId': 1, 'receptionId': 1, 'content': 'Second entry (${reception.name})'}),
           new CalendarEvent.fromJson({'id': 3, 'contactId': 1, 'receptionId': 1, 'content': 'Third entry (${reception.name})'}),
           new CalendarEvent.fromJson({'id': 4, 'contactId': 1, 'receptionId': 1, 'content': 'Fourth entry (${reception.name})'})];

      _ui.selectFirstCalendarEvent();
    }
  }
}
