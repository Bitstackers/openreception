part of view;

/**
 * TODO (TL): Comment
 */
class ReceptionType extends ViewWidget {
  final Controller.Destination    _myDestination;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIReceptionType     _ui;

  /**
   * Constructor.
   */
  ReceptionType(Model.UIModel this._ui,
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
   * Render the widget with [reception].
   */
  void render(Model.Reception reception) {
    if(reception.isEmpty) {
      _ui.clear();
    } else {
      _ui.headerExtra = 'for ${reception.name}';
      //TODO: reception.customertype should be List<String>.
      _ui.type = [reception.customertype];
    }
  }
}
