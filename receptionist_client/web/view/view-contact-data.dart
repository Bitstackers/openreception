part of view;

class ContactData extends Widget {
  Model.UIContactData _ui;
  Place         _myPlace;

  ContactData(Model.UIModel this._ui, Place this._myPlace) {
    test(); // TODO (TL): Get rid of this testing code...

    _registerEventListeners();
  }

  void _activateMe(_) {
    _ui.focusElement.focus(); // NOTE (TL): Sticky focus on focusElement
    _navigateToMyPlace();
  }

  void _addTelephoneNumber(TelephoneNumber number) {
    _ui.telephoneNumberList.append(number.element);
  }

  LIElement _getListElement(int index) {
    try {
      return _ui.telephoneNumberList.children[index];
    } catch(e) {
      return null;
    }
  }

  void _handleMouseClick(MouseEvent event) {
    if((event.target is LIElement) || (event.target is SpanElement)) {
      LIElement _clickedElement =
          (event.target is SpanElement) ? (event.target as Element).parentNode : event.target;
      _selectTelephoneNumber(_clickedElement);
    }
  }

  void _handleUpDown(KeyboardEvent event) {
    switch(event.keyCode) {
        case KeyCode.DOWN:
          event.preventDefault();
          _selectTelephoneNumber(_ui.telephoneNumberList.querySelector('.selected').nextElementSibling);
          break;
        case KeyCode.UP:
          event.preventDefault();
          _selectTelephoneNumber(_ui.telephoneNumberList.querySelector('.selected').previousElementSibling);
          break;
      }
  }

  @override
  Place get myPlace => _myPlace;

  void _registerEventListeners() {
    // TODO (TL): Maybe navigate to _myPlace on alt+1-3?
    _navigate.onGo.listen(_setWidgetState);

    _ui.root.onClick.listen(_activateMe);

    _hotKeys.onAltT.listen(_activateMe);

    // TODO (TL): Hangup on alt+1-3/mouseclick if number is already ringing?
    _hotKeys.onAlt1.listen((_) => _selectTelephoneNumber(_getListElement(0)));
    _hotKeys.onAlt2.listen((_) => _selectTelephoneNumber(_getListElement(1)));
    _hotKeys.onAlt3.listen((_) => _selectTelephoneNumber(_getListElement(2)));

    _ui.telephoneNumberList.onClick.listen(_handleMouseClick);

    _ui.telephoneNumberList.onKeyDown.listen(_handleUpDown);
  }

  void _selectTelephoneNumber(LIElement selectedElement) {
    if(selectedElement != null && _active && !_ui.telephoneNumberList.children.any((e) => e.classes.contains('ringing'))) {
      if(selectedElement.classes.contains('selected')) {
        selectedElement.classes.toggle('ringing', true);
        // TODO (TL): On ringing, call the appropriate controller.
      } else {
        _ui.telephoneNumberList.children.forEach((LIElement element) {
          element.classes.toggle('selected', (element == selectedElement));
          if(element == selectedElement) {
            element.focus();
          }
        });
      }
    }
  }

  // TODO (TL): Get rid of this. It's just here to test stuff.
  void test() {
    TelephoneNumber foo = new TelephoneNumber('45454545', 'some number', false);
    _addTelephoneNumber(foo);
    TelephoneNumber bar = new TelephoneNumber('123456768', 'some number', true);
    _addTelephoneNumber(bar);

    _active = true; // NOTE (TL): fake _active true for first child selection
    _selectTelephoneNumber(_ui.telephoneNumberList.children.first);
  }

  @override
  Model.UIModel get ui => _ui;
}

class TelephoneNumber {
  LIElement   _li         = new LIElement()..tabIndex = -1;
  bool        _secret;
  SpanElement _spanLabel  = new SpanElement();
  SpanElement _spanNumber = new SpanElement();

  TelephoneNumber(number, label, this._secret) {
    if(_secret) {
      _spanNumber.classes.add('secret');
    }

    _spanNumber.text = number;
    _spanLabel.text = label;
    _spanLabel.classes.add('label');

    _li.children.addAll([_spanNumber, _spanLabel]);
  }

  LIElement get element => _li;
}
