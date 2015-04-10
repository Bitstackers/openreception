part of view;

class AgentInfo extends ViewWidget {
  UIAgentInfo _ui;

  AgentInfo(UIModel this._ui) {
    _ui.activeCount = 0;
    _ui.pausedCount = 0;
    _ui.agentState = AgentState.Unknown;
    _ui.alertState = AlertState.On;
    _ui.portrait = 'images/face.png';

    registerEventListeners();
  }

  @override Place   get myPlace => throw new UnsupportedError('');
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
