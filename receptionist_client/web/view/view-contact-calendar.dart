part of view;

class ContactCalendar extends Widget {
  DomContactCalendar _dom;
  Place              _myPlace;

  ContactCalendar(DomContactCalendar this._dom, Place this._myPlace) {
    _registerEventListeners();
  }

  void _activateMe(_) {
    _navigateToMyPlace();
  }

  @override
  HtmlElement get focusElement => _dom.eventList;

  @override
  Place get myPlace => _myPlace;

  /**
   *
   */
  void _registerEventListeners() {
    _navigate.onGo.listen(_setWidgetState);

    _dom.root.onClick.listen(_activateMe);

    _hotKeys.onAltK.listen(_activateMe);

    // TODO (TL): temporary stuff
    _dom.eventList.onDoubleClick.listen((_) => _navigate.goCalendarEdit());
  }

  @override
  HtmlElement get root => _dom.root;
}
