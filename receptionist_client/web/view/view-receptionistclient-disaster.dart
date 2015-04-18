part of view;

class ReceptionistclientDisaster {
  final AppClientState               _appState;
  static ReceptionistclientDisaster  _singleton;
  Model.UIReceptionistclientDisaster _ui;

  /**
   * Constructor.
   */
  factory ReceptionistclientDisaster(AppClientState appClientState,
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
  ReceptionistclientDisaster._internal(AppClientState this._appState,
                                       Model.UIReceptionistclientDisaster this._ui) {
   _observers();
  }

  /**
   * Observers.
   */
  void _observers() {
    _appState.onStateChange.listen((AppState appState) =>
        appState == AppState.ERROR ? _ui.visible = true : _ui.visible = false);
  }
}
