part of view;

class AgentInfo extends Widget {
  Model.UIAgentInfo _ui;

  AgentInfo(Model.UIModel this._ui) {
    _ui.activeCount = 0;
    _ui.pausedCount = 0;
    _ui.agentState = Model.AgentState.UNKNOWN;
    _ui.alertState = Model.AlertState.ON;
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

  void _updateAgentState(Model.AgentState agentState) {
    _ui.agentState = agentState;
  }

  void _updateAlertState(Model.AlertState alertState) {
    _ui.alertState = alertState;
  }

  void _updatePausedCount(int pausedCount) {
    _ui.pausedCount = pausedCount;
  }

  @override
  Model.UIModel get ui => _ui;
}
