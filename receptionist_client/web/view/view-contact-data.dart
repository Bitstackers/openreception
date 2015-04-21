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
    _ui.header = 'Kontakt data';

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

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(setWidgetState);

    _hotKeys.onAltT.listen(activateMe);

    _ui.onClick.listen(activateMe);

    _contactSelector.onSelect.listen(render);

    _receptionSelector.onSelect.listen(clearOnNullReception);

    _ui.onMarkedRinging.listen(_call);
    ///
    ///
    ///
    /// TODO (TL): Listen for call notifications here? Possibly mark ringing?
    /// Or put this in model-ui-contact-data.dart?
    ///
    ///
    ///
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
    _ui.telephoneNumbers = [new TelNum(1, '45454545', 'some number', false),
                            new TelNum(2, '23456768', 'secret stuff', true),
                            new TelNum(3, '60431992', 'personal cell', false),
                            new TelNum(4, '60431993', 'wife cell', false)];
    _ui.titles = ['Nørd', 'Tekniker'];
    _ui.workHours = ['Hele tiden', 'Svarer sjældent telefonen om lørdagen'];

    _ui.selectFirstTelNum();
  }

  /**
   * This is called when the [_ui] fires a [TelNum] as marked ringing.
   */
  void _call(TelNum telNum) {
    print('view-contact-data.call() ${telNum}');
    /// TODO (TL): Call the Controller layer to actually get the call going.
  }
}
