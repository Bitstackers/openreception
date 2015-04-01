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
    navigateToMyPlace();
  }

  /**
   *
   */
  void _registerEventListeners() {
    navigate.onGo.listen(setWidgetState);

    _ui.root.onClick.listen(_activateMe);

    hotKeys.onAltK.listen(_activateMe);

    // TODO (TL): temporary test dbl click
    _ui.entryList.onDoubleClick.listen((_) => navigate.goCalendarEdit());
  }
}
