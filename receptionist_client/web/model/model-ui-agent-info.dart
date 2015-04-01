part of model;

class UIAgentInfo extends UIModel {
  final DivElement _root;

  UIAgentInfo(DivElement this._root);

  @override HtmlElement get firstTabElement => throw new UnsupportedError('');
  @override HtmlElement get lastTabElement  => throw new UnsupportedError('');
  @override HtmlElement get focusElement    => _root;
  @override HtmlElement get root            => _root;

  @override set firstTabElement(_) => throw new UnsupportedError('');
  @override set focusElement(_)    => throw new UnsupportedError('');
  @override set lastTabElement(_)  => throw new UnsupportedError('');

  TableCellElement get _activeCountElement => _root.querySelector('.active-count');
  ImageElement     get _agentStateElement  => _root.querySelector('.agent-state');
  ImageElement     get _alertStateElement  => _root.querySelector('.alert-state');
  TableCellElement get _pausedCountElement => _root.querySelector('.paused-count');
  ImageElement     get _portraitElement    => _root.querySelector('.portrait');

  set activeCount (int value) => _activeCountElement.text = value.toString();

  set agentState (AgentState agentState) {
    switch(agentState) {
      case AgentState.BUSY:
        _agentStateElement.src = 'images/agentsactive.svg';
        break;
      case AgentState.IDLE:
        /// TODO (TL): Need idle state graphic
        _agentStateElement.src = 'images/agentsactive.svg';
        break;
      case AgentState.PAUSE:
        _agentStateElement.src = 'images/agentssleep.svg';
        break;
      case AgentState.UNKNOWN:
        /// TODO (TL): Need unknown state graphic
        _agentStateElement.src = 'images/agentsactive.svg';
        break;
    }
  }

  set alertState (AlertState alertState) {
    switch(alertState) {
      case AlertState.OFF:
        /// TODO (TL): Need alert state OFF graphic
        break;
      case AlertState.ON:
        _alertStateElement.src = 'images/alert.svg';
        break;
    }
  }

  set pausedCount (int value) => _pausedCountElement.text = value.toString();

  set portrait (String path) => _portraitElement.src = path;
}
