part of view;

class AgentInfo extends Widget {
  DomAgentInfo _dom;

  /**
   *
   */
  AgentInfo(DomAgentInfo this._dom) {
    _dom.activeCount.text = '0';
    _dom.pausedCount.text = '0';
    _dom.agentState.src = 'images/agentsactive.svg';
    _dom.alertState.src = 'images/alert.svg';
    _dom.face.src = 'images/face.png';

    _registerEventListeners();
  }

  /**
   *
   */
  void _registerEventListeners() {
    // TODO (TL): Stuff...
  }
}
