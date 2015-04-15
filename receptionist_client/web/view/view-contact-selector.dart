part of view;

class ContactSelector extends ViewWidget {
  Bus<Contact>      _bus = new Bus<Contact>();
  Place             _myPlace;
  UIContactSelector _ui;

  /**
   * Constructor.
   */
  ContactSelector(UIModel this._ui, Place this._myPlace) {
    _ui.help = 'alt+s';

    _observers();

    test(); // TODO (TL): Get rid of this testing code...
  }

  @override Place   get myPlace => _myPlace;
  @override UIModel get ui      => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  /**
   * Activate this widget if it's not already activated.
   */
  void activateMe(_) {
    navigateToMyPlace();
  }

//  /**
//   * Activate this widget if it's not already active. Also mark a contact in the
//   * list selected, if one such is the target of the [event].
//   */
//  void activateMeFromClick(MouseEvent event) {
//    if(!_ui.eventTargetIsFilterInput(event)) {
//      event.preventDefault();
//    }
//    clickSelect(_ui.getContactFromClick(event));
//    navigateToMyPlace();
//  }

//  /**
//   * Mark [Contact] selected. This call does not check if we're active. Use
//   * this to select a contact using the mouse, else use the plain [select]
//   * function.
//   */
//  void clickSelect(Contact contact) {
//    if(contact != null) {
//      _ui.markSelected(contact);
//      _bus.fire(contact);
//    }
//  }

//  /**
//   * Deal with arrow up/down.
//   */
//  void _handleUpDown(KeyboardEvent event) {
//    if(_ui.active) {
//      event.preventDefault();
//      switch(event.keyCode) {
//        case KeyCode.DOWN:
//          select(_ui.nextContactInList());
//          break;
//        case KeyCode.UP:
//          select(_ui.previousContactInList());
//          break;
//      }
//    }
//  }

  /**
   * Fires the selected [Contact].
   */
  Stream<Contact> get onSelect => _bus.stream;

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(setWidgetState);

    _ui.onClick    .listen(activateMe);
    _hotKeys.onAltS.listen(activateMe);
  }

//  /**
//   * Mark [Contact] selected.
//   * MouseClick selection is handled by [clickSelect], not by this method.
//   */
//  void select(Contact contact) {
//    if(_ui.active && contact != null) {
//      _ui.markSelected(contact);
//      _bus.fire(contact);
//    }
//  }

  /// TODO (TL): Get rid of this. It's just here to test stuff.
  void test() {
    _ui.contacts = [new Contact.fromJson({'id': 1, 'name': 'Trine Løcke Snøcke', 'receptionId': 2, 'tags': ['Oplæring','Service']}),
                    new Contact.fromJson({'id': 2, 'name': 'Hoop Karaoke', 'receptionId': 2, 'tags': ['Entertainment', 'International Business', 'teknik']}),
                    new Contact.fromJson({'id': 3, 'name': 'Thomas Løcke', 'receptionId': 2, 'tags': ['Teknik', 'Service', 'Farum', 'salg']}),
                    new Contact.fromJson({'id': 4, 'name': 'Simpleton McNuggin', 'receptionId': 2, 'tags': ['Teknik', 'Glostrup', 'salg', 'løn', 'kreditor']})];

    _ui.selectFirstEntry();
    new Future.delayed((new Duration(seconds: 1))).then((_) {
      _bus.fire(_ui.getContactFirstVisible());
    });
  }
}
