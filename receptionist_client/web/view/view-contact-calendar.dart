part of view;

class ContactCalendar extends ViewWidget {
  final Model.UIContactSelector   _contactSelector;
  final Controller.Destination    _myDestination;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIContactCalendar   _ui;

  /**
   * Constructor.
   */
  ContactCalendar(Model.UIModel this._ui,
                  Controller.Destination this._myDestination,
                  Model.UIContactSelector this._contactSelector,
                  Model.UIReceptionSelector this._receptionSelector) {
    _ui.setHint('alt+k');
    _observers();
  }

  @override Controller.Destination get myDestination => _myDestination;
  @override Model.UIModel          get ui            => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  /**
   * Activate this widget if it's not already activated.
   */
  void activateMe(_) {
    navigateToMyDestination();
  }

  /**
   * Empty the [CalendarEvent] list on null [Reception].
   */
  void clear(Reception reception) {
    if(reception.isNull) {
      _ui.clear();
    }
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(setWidgetState);

    _hotKeys.onAltK.listen(activateMe);

    _ui.onClick .listen(activateMe);
    _ui.onEdit  .listen((_) => _navigate.goCalendarEdit(from: _myDestination..cmd = Cmd.EDIT));
    _ui.onNew   .listen((_) => _navigate.goCalendarEdit(from: _myDestination..cmd = Cmd.NEW));

    _contactSelector.onSelect.listen(render);

    _receptionSelector.onSelect.listen(clear);
  }

  /**
   * Render the widget with [contact] [CalendarEvent]s.
   */
  void render(Contact contact) {
    if(contact.isNull) {
      _ui.clear();
    } else {
      _ui.headerExtra = 'for ${contact.name}';

      _ui.calendarEvents =
          [new CalendarEvent.fromJson({'id': 1, 'contactId': 1, 'receptionId': 1, 'content': 'First entry (${contact.name})'}),
           new CalendarEvent.fromJson({'id': 2, 'contactId': 1, 'receptionId': 1, 'content': 'Second entry (${contact.name})'}),
           new CalendarEvent.fromJson({'id': 3, 'contactId': 1, 'receptionId': 1, 'content': 'Third entry (${contact.name})'}),
           new CalendarEvent.fromJson({'id': 4, 'contactId': 1, 'receptionId': 1, 'content': 'Fourth entry (${contact.name})'})];

      _ui.selectFirstCalendarEvent();
    }
  }
}
