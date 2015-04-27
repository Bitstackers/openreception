part of view;

class ReceptionTelephoneNumbers extends ViewWidget {
  final Controller.Destination            _myDestination;
  final Model.UIReceptionSelector         _receptionSelector;
  final Model.UIReceptionTelephoneNumbers _ui;

  /**
   * Constructor.
   */
  ReceptionTelephoneNumbers(Model.UIModel this._ui,
                            Controller.Destination this._myDestination,
                            Model.UIReceptionSelector this._receptionSelector) {
    _observers();
  }

  @override Controller.Destination get myDestination => _myDestination;
  @override Model.UIModel          get ui            => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  /**
   * Simply navigate to my [Destination]. Matters not if this widget is already
   * focused.
   */
  void activateMe(_) {
    navigateToMyDestination();
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(setWidgetState);

    _ui.onClick.listen(activateMe);

    _receptionSelector.onSelect.listen(render);
  }

  /**
   * Render the widget with .....
   */
  void render(Reception reception) {
    if(reception.isNull) {
      _ui.clear();
    } else {
      _ui.headerExtra = 'for ${reception.name}';
      _ui.telephoneNumbers = reception.telephoneNumbers;
    }
  }
}
