part of view;

class ContactCalendar extends ViewWidget {
  ContactSelector   _contactSelector;
  Place             _myPlace;
  UIContactCalendar _ui;

  ContactCalendar(UIModel this._ui, Place this._myPlace, ContactSelector this._contactSelector) {
    registerEventListeners();
  }

  @override Place   get myPlace => _myPlace;
  @override UIModel get ui      => _ui;

  /**
   * Simply navigate to my [Place]. Matters not if this widget is already
   * focused.
   */
  void activateMe(_) {
    navigateToMyPlace();
  }

  @override void onBlur(_){}
  @override void onFocus(_){}

  void registerEventListeners() {
    _navigate.onGo.listen(setWidgetState);

    _ui.onClick.listen(activateMe);

    _hotKeys.onAltK .listen(activateMe);
    _hotKeys.onCtrlE.listen((_) => _ui.active ? _navigate.goCalendarEdit(_myPlace) : null);

    _contactSelector.onSelect.listen(render);
  }

  /**
   * Render the widget with [Contact].
   */
  void render(Contact contact) {
    print('ContactCalendar received ${contact.name}');
  }
}
