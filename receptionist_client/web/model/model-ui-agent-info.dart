part of model;

class UIAgentInfo extends UIModel {
  final DivElement _root;

  UIAgentInfo(DivElement this._root);

  TableCellElement get activeCountElement => _root.querySelector('.active-count');
  ImageElement     get agentStateElement  => _root.querySelector('.agent-state');
  ImageElement     get alertStateElement  => _root.querySelector('.alert-state');
  TableCellElement get pausedCountElement => _root.querySelector('.paused-count');
  ImageElement     get portraitElement    => _root.querySelector('.portrait');
  HtmlElement      get rootElement        => _root;

  set activeCount (int value) => activeCountElement.text = value.toString();

  set agentState (AgentState agentState) {
    switch(agentState) {
      case AgentState.BUSY:
        agentStateElement.src = 'images/agentsactive.svg';
        break;
      case AgentState.IDLE:
        /// TODO (TL): Need idle state graphic
        agentStateElement.src = 'images/agentsactive.svg';
        break;
      case AgentState.PAUSE:
        agentStateElement.src = 'images/agentssleep.svg';
        break;
      case AgentState.UNKNOWN:
        /// TODO (TL): Need unknown state graphic
        agentStateElement.src = 'images/agentsactive.svg';
        break;
    }
  }

  set alertState (AlertState alertState) {
    switch(alertState) {
      case AlertState.OFF:
        /// TODO (TL): Need alert state OFF graphic
        break;
      case AlertState.ON:
        alertStateElement.src = 'images/alert.svg';
        break;
    }
  }

  set pausedCount (int value) => pausedCountElement.text = value.toString();

  set portrait (String path) => portraitElement.src = path;
}
