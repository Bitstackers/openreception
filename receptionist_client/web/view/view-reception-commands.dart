part of view;

class ReceptionCommands extends ViewWidget {
  final Controller.Place          _myPlace;
  final Model.UIReceptionCommands _ui;

  /**
   * Constructor.
   */
  ReceptionCommands(Model.UIModel this._ui, Controller.Place this._myPlace) {
    _ui.help = 'alt+h';

    _observers();
  }

  @override Controller.Place get myPlace => _myPlace;
  @override Model.UIModel    get ui      => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  /**
   * Simply navigate to my [Place]. Matters not if this widget is already
   * focused.
   */
  void activateMe(_) {
    navigateToMyPlace();
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(setWidgetState);

    _ui.onClick.listen(activateMe);

    _hotKeys.onAltH .listen(activateMe);
  }

  /**
   * Render the widget with .....
   */
  void render() {
    /// TODO (TL): Set up a listener for receptionSelector and add test data
  }
}
