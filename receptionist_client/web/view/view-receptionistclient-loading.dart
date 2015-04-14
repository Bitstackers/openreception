part of view;

class ReceptionistclientLoading {
  ApplicationState                  _appState;
  static ReceptionistclientLoading  _singleton;
  final UIReceptionistclientLoading _ui = new UIReceptionistclientLoading('receptionistclient-loading');

  /**
   * Constructor.
   */
  factory ReceptionistclientLoading(ApplicationState appState) {
    if(_singleton == null) {
      _singleton = new ReceptionistclientLoading._internal(appState);
    } else {
      return _singleton;
    }
  }

  /**
   * Internal constructor.
   */
  ReceptionistclientLoading._internal(ApplicationState appState) {
    _appState = appState;
    _observers();
  }

  /**
   * Observers.
   */
  void _observers() {
    _appState.onChange.listen((AppState appState) =>
        appState == AppState.Loading ? _ui.visible = true : _ui.visible = false);
  }
}
