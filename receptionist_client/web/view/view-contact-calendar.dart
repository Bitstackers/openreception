part of view;

class ContactCalendar extends ViewWidget {
  Model.UIContactSelector _contactSelector;
  Controller.Place        _myPlace;
  Model.UIContactCalendar _ui;

  /**
   * Constructor.
   */
  ContactCalendar(Model.UIModel this._ui, Controller.Place this._myPlace, Model.UIContactSelector this._contactSelector) {
    _ui.help = 'alt+k';

    _observers();
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
  void _observers() {
    _navigate.onGo.listen(setWidgetState);

    _ui.onClick    .listen(activateMe);
    _hotKeys.onAltK.listen(activateMe);

    _hotKeys.onCtrlE.listen((_) => _ui.active ? _navigate.goCalendarEdit(_myPlace) : null);

    _contactSelector.onSelect.listen(render);
  }

  /**
   * Render the widget with [contact] [CalendarEvent]s.
   */
  void render(Contact contact) {
    _ui.clearList();

    _ui.calendarEntries = [new CalendarEvent.fromJson({'id': 1, 'contactId': 1, 'receptionId': 1, 'content': 'First entry (${contact.name})'}),
                           new CalendarEvent.fromJson({'id': 2, 'contactId': 1, 'receptionId': 1, 'content': 'Second entry (${contact.name})'}),
                           new CalendarEvent.fromJson({'id': 3, 'contactId': 1, 'receptionId': 1, 'content': 'Third entry (${contact.name})'}),
                           new CalendarEvent.fromJson({'id': 4, 'contactId': 1, 'receptionId': 1, 'content': 'Fourth entry (${contact.name})'})];

  }
}
