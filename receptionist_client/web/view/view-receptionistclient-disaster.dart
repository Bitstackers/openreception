part of view;

/**
 * TODO (TL): Comment
 */
class ReceptionistclientDisaster {
  final Model.AppClientState               _appState;
  static ReceptionistclientDisaster  _singleton;
  Model.UIReceptionistclientDisaster _ui;

  /**
   * Constructor.
   */
  factory ReceptionistclientDisaster(Model.AppClientState appClientState,
                                     Model.UIReceptionistclientDisaster uiDisaster) {
    if(_singleton == null) {
      _singleton = new ReceptionistclientDisaster._internal(appClientState, uiDisaster);
    } else {
      return _singleton;
    }
  }

  /**
   * Internal constructor.
   */
  ReceptionistclientDisaster._internal(Model.AppClientState this._appState,
                                       Model.UIReceptionistclientDisaster this._ui) {
   _observers();
  }

  /**
   * Observers.
   */
  void _observers() {
    _appState.onStateChange.listen((Model.AppState appState) =>
        appState == Model.AppState.ERROR ? _ui.visible = true : _ui.visible = false);
  }
}
