part of view;

class AgentInfo extends Widget {
  UIAgentInfo _ui;

  AgentInfo(UIModel this._ui) {
    _ui.activeCount = 0;
    _ui.pausedCount = 0;
    _ui.agentState = AgentState.UNKNOWN;
    _ui.alertState = AlertState.ON;
    _ui.portrait = 'images/face.png';

    registerEventListeners();
  }

  @override Place   get myPlace => throw new UnsupportedError('');
  @override UIModel get ui      => _ui;

  void registerEventListeners() {
    /// TODO (TL): Add relevant listeners
    ///   _ui.activeCount = activeCount
    ///   _ui.agentState = agentState
    ///   _ui.alertState = alertState
    ///   _ui.pausedCount = pausedCount
  }
}
