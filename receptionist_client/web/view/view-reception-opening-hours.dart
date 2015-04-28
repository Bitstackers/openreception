part of view;

/**
 * TODO (TL): Comment
 */
class ReceptionOpeningHours extends ViewWidget {
  final Controller.Destination        _myDestination;
  final Model.UIReceptionSelector     _receptionSelector;
  final Model.UIReceptionOpeningHours _ui;

  /**
   * Constructor.
   */
  ReceptionOpeningHours(Model.UIModel this._ui,
                        Controller.Destination this._myDestination,
                        Model.UIReceptionSelector this._receptionSelector) {
    _ui.setHint('alt+x');
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

    _hotKeys.onAltX.listen(activateMe);

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
      _ui.openingHours = reception.openingHours;
    }
  }
}
