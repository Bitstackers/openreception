part of view;

class ContactCalendar extends ViewWidget {
  final Model.UIContactSelector   _contactSelector;
  final Controller.Place          _myPlace;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIContactCalendar   _ui;

  /**
   * Constructor.
   */
  ContactCalendar(Model.UIModel this._ui,
                  Controller.Place this._myPlace,
                  Model.UIContactSelector this._contactSelector,
                  Model.UIReceptionSelector this._receptionSelector) {
    _ui.help = 'alt+k';

    _observers();
  }

  @override Controller.Place get myPlace => _myPlace;
  @override Model.UIModel    get ui      => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  /**
   * Activate this widget if it's not already activated.
   */
  void activateMe(_) {
    navigateToMyPlace();
  }

  /**
   * Empty the [CalendarEvent] list on null [Reception].
   */
  void clearOnNullReception(Reception reception) {
    if(reception.isNull) {
      _ui.clearList();
    }
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(setWidgetState);

    _ui.onClick    .listen(activateMe);
    _hotKeys.onAltK.listen(activateMe);

    /// Delete and Edit. The actual edit/delete decision is made in the Calendar
    /// Editor.
    _hotKeys.onCtrlD.listen((_) => _ui.isFocused ? _navigate.goCalendarEdit(_myPlace) : null);
    _hotKeys.onCtrlE.listen((_) => _ui.isFocused ? _navigate.goCalendarEdit(_myPlace) : null);

    _contactSelector.onSelect.listen(render);
    _receptionSelector.onSelect.listen(clearOnNullReception);
  }

  /**
   * Render the widget with [contact] [CalendarEvent]s.
   */
  void render(Contact contact) {
    _ui.clearList();

    _ui.calendarEvents = [new CalendarEvent.fromJson({'id': 1, 'contactId': 1, 'receptionId': 1, 'content': 'First entry (${contact.name})'}),
                          new CalendarEvent.fromJson({'id': 2, 'contactId': 1, 'receptionId': 1, 'content': 'Second entry (${contact.name})'}),
                          new CalendarEvent.fromJson({'id': 3, 'contactId': 1, 'receptionId': 1, 'content': 'Third entry (${contact.name})'}),
                          new CalendarEvent.fromJson({'id': 4, 'contactId': 1, 'receptionId': 1, 'content': 'Fourth entry (${contact.name})'})];

    _ui.selectFirstCalendarEvent();
  }
}
