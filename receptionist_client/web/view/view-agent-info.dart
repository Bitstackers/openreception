part of view;

class AgentInfo extends Widget {
  UIAgentInfo _ui;

  AgentInfo(UIModel this._ui) {
    _ui.activeCount = 0;
    _ui.pausedCount = 0;
    _ui.agentState = AgentState.UNKNOWN;
    _ui.alertState = AlertState.ON;
    _ui.portrait = 'images/face.png';

    _registerEventListeners();
  }

  @override
  Place get myPlace => null;

  void _registerEventListeners() {
    /// TODO (TL): Add relevant listeners
  }

  void _updateActiveCount(int activeCount) {
     _ui.activeCount = activeCount;
   }

  void _updateAgentState(AgentState agentState) {
    _ui.agentState = agentState;
  }

  void _updateAlertState(AlertState alertState) {
    _ui.alertState = alertState;
  }

  void _updatePausedCount(int pausedCount) {
    _ui.pausedCount = pausedCount;
  }

  @override
  UIModel get ui => _ui;
}
