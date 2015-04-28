part of view;

/**
 * TODO (TL): Comment
 */
class ReceptionistclientLoading {
  final  Model.AppClientState                    _appState;
  static ReceptionistclientLoading         _singleton;
  final  Model.UIReceptionistclientLoading _ui;

  /**
   * Constructor.
   */
  factory ReceptionistclientLoading(Model.AppClientState appState,
                                    Model.UIReceptionistclientLoading uiLoading) {
    if(_singleton == null) {
      _singleton = new ReceptionistclientLoading._internal(appState, uiLoading);
    } else {
      return _singleton;
    }
  }

  /**
   * Internal constructor.
   */
  ReceptionistclientLoading._internal(Model.AppClientState this._appState,
                                      Model.UIReceptionistclientLoading this._ui) {
    _observers();
  }

  /**
   * Observers.
   */
  void _observers() {
    _appState.onStateChange.listen((Model.AppState appState) =>
        appState == Model.AppState.LOADING ? _ui.visible = true : _ui.visible = false);
  }
}
