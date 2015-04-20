part of view;

class ContactData extends ViewWidget {
  final Model.UIContactSelector   _contactSelector;
  final Controller.Destination    _myDestination;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIContactData       _ui;

  /**
   * Constructor.
   */
  ContactData(Model.UIModel this._ui,
              Controller.Destination this._myDestination,
              Model.UIContactSelector this._contactSelector,
              Model.UIReceptionSelector this._receptionSelector) {
    _observers();
  }

  @override Controller.Destination get myDestination => _myDestination;
  @override Model.UIModel          get ui            => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  /**
   * Simply navigate to my [_myDestination]. Matters not if this widget is
   * already focused.
   */
  void activateMe(_) {
//    _ui.focusOnTelNumList();
    navigateToMyDestination();
  }

  /**
   * Select the [event].target and navigate to my [_myDestination].
   */
  void activateMeFromClick(MouseEvent event) {
//    clickSelect(_ui.getTelNumFromClick(event));
    navigateToMyDestination();
  }

  /**
   * Clear the widget on null [Reception].
   */
  void clearOnNullReception(Reception reception) {
    if(reception.isNull) {
      _ui.clear();
    }
  }

//  /**
//   * Mark [TelNum] selected.
//   */
//  void clickSelect(TelNum telNum) {
//    if(telNum != null) {
//      _ui.markSelected(telNum);
//    }
//  }

//  /**
//   * Deal with arrow up/down.
//   */
//  void handleUpDown(KeyboardEvent event) {
//    if(_ui.isFocused) {
//      event.preventDefault();
//      switch(event.keyCode) {
//        case KeyCode.DOWN:
//          select(_ui.nextTelNumInList());
//          break;
//        case KeyCode.UP:
//          select(_ui.previousTelNumInList());
//          break;
//      }
//    }
//  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(setWidgetState);

    _hotKeys.onAltT.listen(activateMe);

    _ui.onClick          .listen(activateMe);
    _ui.clickSelectTelNum.listen(activateMeFromClick);

//    _hotKeys.onAlt1.listen((_) => select(_ui.getTelNumFromIndex(0)));
//    _hotKeys.onAlt2.listen((_) => select(_ui.getTelNumFromIndex(1)));
//    _hotKeys.onAlt3.listen((_) => select(_ui.getTelNumFromIndex(2)));
//    _hotKeys.onAlt4.listen((_) => select(_ui.getTelNumFromIndex(3)));
//    _hotKeys.onDown.listen(handleUpDown);
//    _hotKeys.onUp  .listen(handleUpDown);

//    _hotKeys.onStar.listen((_) => ring(_ui.getSelectedTelNum()));

    _contactSelector.onSelect.listen(render);

    _receptionSelector.onSelect.listen(clearOnNullReception);
  }

  /**
   * Render the widget with [Contact].
   */
  void render(Contact contact) {
    _ui.clear();

    _ui.header = 'Kontaktdata';
    _ui.headerExtra = 'for ${contact.name}';

    _ui.additionalInfo = ['additionalInfo 1', 'additionalInfo 2'];
    _ui.backups = ['backup 1', 'backup 2'];
    _ui.commands = ['command 1', 'command 2'];
    _ui.departments = ['department 1', 'department 2'];
    _ui.emailAddresses = ['thomas@responsum.dk', 'thomas.granvej6@gmail.com'];
    _ui.relations = ['Hustru: Trine Løcke', 'Far: Steen Løcke'];
    _ui.responsibility = ['Teknik og skidt der generelt ikke fungerer', 'Regelmæssig genstart af Windows'];
    _ui.telephoneNumbers = [new TelNum('45454545', 'some number', false),
                            new TelNum('23456768', 'secret stuff', true),
                            new TelNum('60431992', 'personal cell', false),
                            new TelNum('60431993', 'wife cell', false)];
    _ui.titles = ['Nørd', 'Tekniker'];
    _ui.workHours = ['Hele tiden', 'Svarer sjældent telefonen om lørdagen'];

    _ui.selectFirstTelNum();
//    _ui.markSelected(_ui.getTelNumFromIndex(0));
  }

//  /**
//   * Mark [telNum] ringing if we're in focus, not already ringing and [telNum]
//   * is not null.
//   */
//  void ring(TelNum telNum) {
//    if(_ui.isFocused && _ui.noRinging && telNum != null) {
//      _ui.markRinging(telNum);
//      /// TODO (TL): Call Controller.Call or something like that?
//    }
//  }

//  /**
//   * If the we're active and not ringing, mark [telNum] active.
//   */
//  void select(TelNum telNum) {
//    if(_ui.isFocused && _ui.noRinging && telNum != null) {
//      _ui.markSelected(telNum);
//    }
//  }
}
