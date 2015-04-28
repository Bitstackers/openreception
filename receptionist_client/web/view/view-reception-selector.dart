part of view;

/**
 * TODO (TL): Comment
 */
class ReceptionSelector extends ViewWidget {
  final Controller.Destination    _myDestination;
  final Model.UIReceptionSelector _ui;
  final Controller.Reception      _receptionController;

  /**
   * Constructor.
   */
  ReceptionSelector(Controller.Destination this._myDestination,
                    Model.UIModel this._ui,
                    Controller.Reception this._receptionController) {
    _ui.setHint('alt+v');
    _observers();

    this._receptionController.list()
      .then((Iterable<Model.Reception> receptions) {

      Iterable<Model.Reception> sortedReceptions = receptions.toList()
          ..sort((x,y) => x.name.compareTo(y.name));

      this._ui.receptions = sortedReceptions;
    });
  }

  @override Controller.Destination get myDestination => _myDestination;
  @override Model.UIModel          get ui            => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  /**
   * Activate this widget if it's not already activated.
   */
  void activateMe(_) {
    navigateToMyDestination();
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(setWidgetState);

    _hotKeys.onAltV.listen(activateMe);

    _ui.onClick.listen(activateMe);
  }
}
