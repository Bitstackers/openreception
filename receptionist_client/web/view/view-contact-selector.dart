part of view;

class ContactSelector extends ViewWidget {
  Bus<Contact>      _bus = new Bus<Contact>();
  Place             _myPlace;
  UIContactSelector _ui;

  ContactSelector(UIModel this._ui, Place this._myPlace) {
    test(); // TODO (TL): Get rid of this testing code...

    _registerEventListeners();
  }

  @override Place   get myPlace => _myPlace;
  @override UIModel get ui      => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  void activateMe(_) {
    navigateToMyPlace();
  }

  void activateMeFromClick(MouseEvent event) {
    event.preventDefault();
    clickSelect(_ui.getContactFromClick(event));
    navigateToMyPlace();
  }

  /**
   * Mark [Contact] selected. This call does not check if we're active. Use
   * this to select a contact using the mouse, else use the plain [select]
   * function.
   */
  void clickSelect(Contact contact) {
    if(contact != null) {
      _ui.markSelected(contact);
      _bus.fire(contact);
    }
  }

  /**
   * Deal with arrow up/down.
   */
  void _handleUpDown(KeyboardEvent event) {
    if(_ui.active) {
      event.preventDefault();
      switch(event.keyCode) {
        case KeyCode.DOWN:
          select(_ui.nextContactInList());
          break;
        case KeyCode.UP:
          select(_ui.previousContactInList());
          break;
      }
    }
  }

  /**
   * Fires the selected [Contact].
   */
  Stream<Contact> get onSelect => _bus.stream;

  void _registerEventListeners() {
    _navigate.onGo.listen(setWidgetState);

    _ui.onClick.listen(activateMeFromClick);

    _hotKeys.onAltS.listen(activateMe);

    _hotKeys.onDown.listen(_handleUpDown);
    _hotKeys.onUp  .listen(_handleUpDown);

    /// These are here to prevent tab'ing out of the filter input.
    _hotKeys.onTab     .listen(handleTab);
    _hotKeys.onShiftTab.listen(handleShiftTab);
  }

  /**
   * Mark [Contact] selected. This call checks if we're active. Do not use this
   * to select contacts using the mouse.
   */
  void select(Contact contact) {
    if(_ui.active && contact != null) {
      _ui.markSelected(contact);
      _bus.fire(contact);
    }
  }

  /// TODO (TL): Get rid of this. It's just here to test stuff.
  void test() {
    _ui.contacts = [new Contact('Trine Løcke Snøcke', tags:['Oplæring','Service']),
                    new Contact('Thomas Løcke', tags:['Teknik', 'Service', 'Farum', 'salg']),
                    new Contact('Hoop Karaoke', tags:['Entertainment', 'International Business', 'teknik']),
                    new Contact('Simpleton McNuggin', tags:['Teknik', 'Glostrup', 'salg', 'løn', 'kreditor'])];

    _ui.markSelected(_ui.getContactFirstVisible());
    new Future.delayed((new Duration(seconds: 1))).then((_) {
      _bus.fire(_ui.getContactFirstVisible());
    });
  }
}
