part of view;

class ReceptionSelector extends ViewWidget {
  Bus<Reception>      _bus = new Bus<Reception>();
  Place               _myPlace;
  UIReceptionSelector _ui;

  ReceptionSelector(UIModel this._ui, Place this._myPlace) {
    _ui.help = 'alt+v';

    _registerEventListeners();

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

  /**
   * Activate this widget if it's not already active. Also mark a contact in the
   * list selected, if one such is the target of the [event].
   */
  void activateMeFromClick(MouseEvent event) {
    if(!_ui.eventTargetIsFilterInput(event)) {
      event.preventDefault();
    }
    clickSelect(_ui.getReceptionFromClick(event));
    navigateToMyPlace();
  }

  /**
   * Mark [Reception] selected. This call does not check if we're active. Use
   * this to select a reception using the mouse, else use the plain [select]
   * function.
   */
  void clickSelect(Reception reception) {
    if(reception != null) {
      _ui.markSelected(reception);
      _bus.fire(reception);
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
          select(_ui.nextReceptionInList());
          break;
        case KeyCode.UP:
          select(_ui.previousReceptionInList());
          break;
      }
    }
  }

  /**
   * Fires the selected [Reception].
   */
  Stream<Reception> get onSelect => _bus.stream;

  void _registerEventListeners() {
    _navigate.onGo.listen(setWidgetState);

    _ui.onClick.listen(activateMeFromClick);

    _hotKeys.onAltV.listen(activateMe);

    _hotKeys.onEenter.listen((_) => select(_ui.nextReceptionInList()));
    _hotKeys.onEsc.listen(reset);

    _hotKeys.onDown.listen(_handleUpDown);
    _hotKeys.onUp  .listen(_handleUpDown);
  }

  /**
   * Reset the selector and fire a null [Reception]
   */
  void reset(_) {
    _ui.reset();
    _bus.fire(new Reception('')); // TODO (TL): fire an actual null reception.
  }

  /**
   * Mark [Reception] selected.
   * MouseClick selection is handled by [clickSelect], not by this method.
   */
  void select(Reception reception) {
    if(_ui.active && reception != null) {
      _ui.markSelected(reception);
      _bus.fire(reception);
    }
  }

  /// TODO (TL): Get rid of this. It's just here to test stuff.
  void test() {
    _ui.receptions = [new Reception('Responsum K/S'),
                      new Reception('Bitstackers K/S'),
                      new Reception('Loecke K/S'),
                      new Reception('Another Loecke K/S'),
                      new Reception('Another Responsum K/S'),
                      new Reception('FooBar K/S')];

  }
}
