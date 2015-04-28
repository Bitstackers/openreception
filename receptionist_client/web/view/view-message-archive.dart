part of view;

/**
 * TODO (TL): Comment
 */
class MessageArchive extends ViewWidget {
  final Controller.Destination _myDestination;
  final Model.UIMessageArchive _ui;

  /**
   * Constructor.
   */
  MessageArchive(Model.UIMessageArchive this._ui,
                 Controller.Destination this._myDestination) {
    _observers();
  }

  @override Controller.Destination get myDestination => _myDestination;
  @override Model.UIModel          get ui            => _ui;

  @override void onBlur(_) {}
  @override void onFocus(_) {}

  /**
   * Simply navigate to my [_myDestination]. Matters not if this widget is already
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

    _ui.onClick .listen(activateMe);
  }
}
