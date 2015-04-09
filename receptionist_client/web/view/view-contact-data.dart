part of view;

class ContactData extends ViewWidget {
  ContactSelector _contactSelector;
  Place           _myPlace;
  UIContactData   _ui;

  ContactData(UIModel this._ui, Place this._myPlace, ContactSelector this._contactSelector) {
    test(); // TODO (TL): Get rid of this testing code...

    registerEventListeners();
  }

  @override Place   get myPlace => _myPlace;
  @override UIModel get ui      => _ui;

  /**
   * Simply navigate to my [_myPlace]. Matters not if this widget is already
   * focused.
   */
  void activateMe(_) {
    _ui.focusOnTelNumList();
    navigateToMyPlace();
  }

  /**
   * Select the [event].target and navigate to my [_myPlace].
   */
  void activateMeFromClick(MouseEvent event) {
    clickSelect(_ui.getTelNumFromClick(event));
    navigateToMyPlace();
  }

  /**
   * Mark [TelNum] selected.
   */
  void clickSelect(TelNum telNum) {
    if(telNum != null) {
      _ui.markSelected(telNum);
    }
  }

  /**
   * Deal with arrow up/down.
   */
  void handleUpDown(KeyboardEvent event) {
    if(_ui.active) {
      event.preventDefault();
      switch(event.keyCode) {
        case KeyCode.DOWN:
          select(_ui.nextTelNumInList());
          break;
        case KeyCode.UP:
          select(_ui.previousTelNumInList());
          break;
      }
    }
  }

  @override void onBlur(_){}
  @override void onFocus(_){}

  void registerEventListeners() {
    _navigate.onGo.listen(setWidgetState);

    _ui.onClick.listen(activateMe);

    _hotKeys.onAltT.listen(activateMe);

    _hotKeys.onAlt1.listen((_) => select(_ui.getTelNumFromIndex(0)));
    _hotKeys.onAlt2.listen((_) => select(_ui.getTelNumFromIndex(1)));
    _hotKeys.onAlt3.listen((_) => select(_ui.getTelNumFromIndex(2)));
    _hotKeys.onAlt4.listen((_) => select(_ui.getTelNumFromIndex(3)));
    _hotKeys.onDown.listen(handleUpDown);
    _hotKeys.onUp  .listen(handleUpDown);

    _hotKeys.onStar.listen((_) => ring(_ui.getSelectedTelNum()));

    _ui.clickSelectTelNum.listen(activateMeFromClick);

    _contactSelector.onSelect.listen(render);

    /// TODO (TL): Add listener for call events to detect pickup/hangup
  }

  /**
   * Render the widget with [Contact].
   */
  void render(Contact contact) {
    print('ContactData received ${contact.name}');
  }

  /**
   * Mark [telNum] ringing if we're in focus, not already ringing and [telNum]
   * is not null.
   */
  void ring(TelNum telNum) {
    if(_ui.active && _ui.noRinging && telNum != null) {
      _ui.markRinging(telNum);
      /// TODO (TL): Call Controller.Call or something like that?
    }
  }

  /**
   * If the we're active and not ringing, mark [telNum] active.
   */
  void select(TelNum telNum) {
    if(_ui.active && _ui.noRinging && telNum != null) {
      _ui.markSelected(telNum);
    }
  }

  /// TODO (TL): Get rid of this. It's just here to test stuff.
  void test() {
    _ui.additionalInfo = ['additionalInfo 1', 'additionalInfo 2'];
    _ui.backups = ['backup 1', 'backup 2'];
    _ui.commands = ['command 1', 'command 2'];
    _ui.departments = ['department 1', 'department 2'];
    _ui.emailAddresses = ['thomas@responsum.dk', 'thomas.granvej6@gmail.com'];
    _ui.relations = ['Hustru: Trine Løcke', 'Far: Steen Løcke'];
    _ui.responsibility = ['Teknik og skidt der generelt ikke fungerer', 'Regelmæssig genstart af Windows'];
    _ui.telnums = [new TelNum('45454545', 'some number', false),
                   new TelNum('23456768', 'secret stuff', true),
                   new TelNum('60431992', 'personal cell', false),
                   new TelNum('60431993', 'wife cell', false)];
    _ui.titles = ['Nørd', 'Tekniker'];
    _ui.workHours = ['Hele tiden', 'Svarer sjældent telefonen om lørdagen'];

    _ui.markSelected(_ui.getTelNumFromIndex(0));
  }
}
