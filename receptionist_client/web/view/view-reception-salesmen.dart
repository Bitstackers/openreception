part of view;

class ReceptionSalesmen extends ViewWidget {
  final Controller.Destination    _myDestination;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIReceptionSalesmen _ui;

  /**
   * Constructor.
   */
  ReceptionSalesmen(Model.UIReceptionSalesmen this._ui,
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

    _hotKeys.onAltC.listen(activateMe);

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
      _ui.salesMen = reception.salesMen;
    }
  }
}
