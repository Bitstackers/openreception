part of view;

/**
 * TODO (TL): Comment
 */
class GlobalCallQueue extends ViewWidget {
  final Controller.Destination  _myDestination;
  final Model.UIGlobalCallQueue _ui;

  /**
   * Constructor.
   */
  GlobalCallQueue(Model.UIGlobalCallQueue this._ui,
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
    _ui.calls = ['Call 1', 'Call 2', 'Call 3','Call 4', 'Call 5', 'Call 6'];
  }
}
