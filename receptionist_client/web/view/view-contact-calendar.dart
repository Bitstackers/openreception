part of view;

class ContactCalendar extends Widget {
  Place              _myPlace;
  UIContactCalendar _ui;

  ContactCalendar(UIModel this._ui, Place this._myPlace) {
    _registerEventListeners();
  }

  @override Place   get myPlace => _myPlace;
  @override UIModel get ui      => _ui;

  void _activateMe(_) {
    _navigateToMyPlace();
  }

  /**
   *
   */
  void _registerEventListeners() {
    _navigate.onGo.listen(_setWidgetState);

    _ui.root.onClick.listen(_activateMe);

    _hotKeys.onAltK.listen(_activateMe);

    // TODO (TL): temporary stuff
    _ui.entryList.onDoubleClick.listen((_) => _navigate.goCalendarEdit());
  }
}
