part of view;

class ContactList extends Widget {
  UIContactList _dom;
  Place          _myPlace;

  ContactList(UIModel this._dom, Place this._myPlace) {
    _registerEventListeners();
  }

  void _activateMe(_) {
    _navigateToMyPlace();
  }

  @override
  HtmlElement get focusElement => _dom.filter;

  @override
  Place get myPlace => _myPlace;

  void _registerEventListeners() {
    _navigate.onGo.listen(_setWidgetState);

    _dom.root.onClick.listen(_activateMe);
    _hotKeys.onAltS.listen(_activateMe);
  }

  @override
  HtmlElement get root => _dom.root;
}
