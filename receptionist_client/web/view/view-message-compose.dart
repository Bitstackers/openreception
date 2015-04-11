part of view;

/**
 * Component for creating/editing and saving/sending messages.
 */
class MessageCompose extends ViewWidget {
  Place            _myPlace;
  UIMessageCompose _ui;

  MessageCompose(UIMessageCompose this._ui, Place this._myPlace) {
    _ui.help = 'alt-b';

    _registerEventListeners();
  }

  @override Place   get myPlace => _myPlace;
  @override UIModel get ui      => _ui;

  @override void onBlur(_) {}
  @override void onFocus(_) {}

  void activateMe(_) {
    navigateToMyPlace();
  }

  /**
   * TODO (TL): implement and comment
   */
  void cancel(_) {
    print('MessageCompose.cancel() not implemented yet');
  }

  void _registerEventListeners() {
    _navigate.onGo.listen(setWidgetState);

    _ui.onClick.listen(activateMe);

    _hotKeys.onAltB.listen(activateMe);

    _ui.onCancel.listen(cancel);
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
