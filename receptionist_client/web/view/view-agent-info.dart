part of view;

class AgentInfo extends ViewWidget {
  UIAgentInfo _ui;

  AgentInfo(UIModel this._ui) {
    _ui.activeCount = 0;
    _ui.pausedCount = 0;
    _ui.agentState = AgentState.UNKNOWN;
    _ui.alertState = AlertState.ON;
    _ui.portrait = 'images/face.png';

    registerEventListeners();
  }

  @override Place   get myPlace => null;
  @override UIModel get ui      => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  void registerEventListeners() {
    /// TODO (TL): Add relevant listeners
    ///   _ui.activeCount = active count
    ///   _ui.agentState = agent state
    ///   _ui.alertState = alert state
    ///   _ui.pausedCount = paused count
  }
}
