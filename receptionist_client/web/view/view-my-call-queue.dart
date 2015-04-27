part of view;

/**
 * TODO (TL): Comment
 */
class MyCallQueue extends ViewWidget {
  final Controller.Destination _myDestination;
  final Model.UIMyCallQueue    _ui;

  /**
   * Constructor.
   */
  MyCallQueue(Model.UIMyCallQueue this._ui,
              Controller.Destination this._myDestination) {
    test(); // TODO (TL): get rid of this testing code.

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
  }

  // TODO (TL): Remove this testing code
  void test() {
    _ui.calls = ['Call 10', 'Call 11', 'Call 12','Call 13', 'Call 14', 'Call 15'];
  }
}
