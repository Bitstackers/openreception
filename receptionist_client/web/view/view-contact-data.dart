part of view;

class ContactData extends Widget {
  UIContactData _ui;
  Place         _myPlace;

  ContactData(UIModel this._ui, Place this._myPlace) {
    test(); // TODO (TL): Get rid of this testing code...

    _registerEventListeners();
  }

  @override Place   get myPlace => _myPlace;
  @override UIModel get ui      => _ui;

  void _activateMe(_) {
    _ui.focusElement.focus(); /// NOTE (TL): Sticky focus on focusElement
    _navigateToMyPlace();
  }

  void _handleMouseClick(MouseEvent event) {
    selectOrRing(_ui.getTelNoFromClick(event));
  }

  void _handleUpDown(KeyboardEvent event) {
    switch(event.keyCode) {
        case KeyCode.DOWN:
          event.preventDefault();
          selectOrRing(_ui.nextTelNoInList());
          break;
        case KeyCode.UP:
          event.preventDefault();
          selectOrRing(_ui.previousTelNoInList());
          break;
      }
  }

  void _registerEventListeners() {
    /// TODO (TL): Maybe navigate to _myPlace on alt+1-3?
    _navigate.onGo.listen(_setWidgetState);

    _ui.root.onClick.listen(_activateMe);

    _hotKeys.onAltT.listen(_activateMe);

    /// TODO (TL): Hangup on alt+1-3/mouseclick if number is already ringing?
    _hotKeys.onAlt1.listen((_) => selectOrRing(_ui.getTelNoFromIndex(0)));
    _hotKeys.onAlt2.listen((_) => selectOrRing(_ui.getTelNoFromIndex(1)));
    _hotKeys.onAlt3.listen((_) => selectOrRing(_ui.getTelNoFromIndex(2)));

    _ui.telNoList.onClick.listen(_handleMouseClick);

    _ui.telNoList.onKeyDown.listen(_handleUpDown);
  }

  void selectOrRing(TelNo telNo) {
    if(_ui.active && telNo != null && _ui.noRinging) {
      if(_ui.isSelected(telNo)) {
        _ui.markRinging(telNo);
      } else {
        _ui.markSelected(telNo);
      }
    }
  }

  /// TODO (TL): Get rid of this. It's just here to test stuff.
  void test() {
    TelNo foo = new TelNo('45454545', 'some number', false);
    _ui.addTelNo(foo);
    TelNo bar = new TelNo('123456768', 'some number', true);
    _ui.addTelNo(bar);
  }
}
