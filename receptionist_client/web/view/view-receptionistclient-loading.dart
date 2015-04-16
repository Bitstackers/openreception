part of view;

class ReceptionistclientLoading {
  AppClientState                    _appState;
  static ReceptionistclientLoading  _singleton;

  final Model.UIReceptionistclientLoading _ui = new Model.UIReceptionistclientLoading('receptionistclient-loading');

  /**
   * Constructor.
   */
  factory ReceptionistclientLoading(AppClientState appState) {
    if(_singleton == null) {
      _singleton = new ReceptionistclientLoading._internal(appState);
    } else {
      return _singleton;
    }
  }

  /**
   * Internal constructor.
   */
  ReceptionistclientLoading._internal(AppClientState appState) {
    _appState = appState;
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
