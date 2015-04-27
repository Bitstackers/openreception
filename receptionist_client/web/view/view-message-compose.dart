part of view;

/**
 * Component for creating/editing and saving/sending messages.
 */
class MessageCompose extends ViewWidget {
  final Controller.Destination _myDestination;
  final Model.UIMessageCompose _ui;

  /**
   * Constructor.
   */
  MessageCompose(Model.UIMessageCompose this._ui,
                 Controller.Destination this._myDestination) {
    _ui.setHint('alt+b');
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
   * TODO (TL): implement and comment
   */
  void cancel(_) {
    print('MessageCompose.cancel() not implemented yet');
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(setWidgetState);

    _hotKeys.onAltB.listen(activateMe);

    _ui.onCancel.listen(cancel);
    _ui.onClick .listen(activateMe);
    _ui.onSave  .listen(save);
    _ui.onSend  .listen(send);
  }

  /**
   * TODO (TL): implement and comment
   */
  void save(_) {
    print('MessageCompose.save() not implemented yet');
  }

  /**
   * TODO (TL): implement and comment
   */
  void send(_) {
    print('MessageCompose.send() not implemented yet');
  }
}
