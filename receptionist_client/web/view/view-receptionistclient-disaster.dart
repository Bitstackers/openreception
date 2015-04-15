part of view;

class ReceptionistclientDisaster {
  AppClientState                     _appState;
  static ReceptionistclientDisaster  _singleton;
  final UIReceptionistclientDisaster _ui = new UIReceptionistclientDisaster('receptionistclient-disaster');

  /**
   * Constructor.
   */
  factory ReceptionistclientDisaster(AppClientState appClientState) {
    if(_singleton == null) {
      _singleton = new ReceptionistclientDisaster._internal(appClientState);
    } else {
      return _singleton;
    }
  }

  /**
   * Internal constructor.
   */
  ReceptionistclientDisaster._internal(AppClientState appState) {
    _appState = appState;
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
