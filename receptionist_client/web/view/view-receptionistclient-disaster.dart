part of view;

class ReceptionistclientDisaster {
  ApplicationState                   _appState;
  static ReceptionistclientDisaster  _singleton;
  final UIReceptionistclientDisaster _ui = new UIReceptionistclientDisaster('receptionistclient-disaster');

  /**
   * Constructor.
   */
  factory ReceptionistclientDisaster(ApplicationState appState) {
    if(_singleton == null) {
      _singleton = new ReceptionistclientDisaster._internal(appState);
    } else {
      return _singleton;
    }
  }

  /**
   * Internal constructor.
   */
  ReceptionistclientDisaster._internal(ApplicationState appState) {
    _appState = appState;
    _observers();
  }

  /**
   * Observers.
   */
  void _observers() {
    _appState.onChange.listen((AppState appState) =>
        appState == AppState.Disaster ? _ui.visible = true : _ui.visible = false);
  }
}
