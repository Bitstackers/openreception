part of view;

/**
 * TODO (TL): Comment
 */
class ReceptionistclientLoading {
  final  AppClientState                    _appState;
  static ReceptionistclientLoading         _singleton;
  final  Model.UIReceptionistclientLoading _ui;

  /**
   * Constructor.
   */
  factory ReceptionistclientLoading(AppClientState appState,
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
  ReceptionistclientLoading._internal(AppClientState this._appState,
                                      Model.UIReceptionistclientLoading this._ui) {
    _observers();
  }

  /**
   * Observers.
   */
  void _observers() {
    _appState.onStateChange.listen((AppState appState) =>
        appState == AppState.LOADING ? _ui.visible = true : _ui.visible = false);
  }
}
