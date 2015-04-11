part of model;

class UIAgentInfo extends UIModel {
  final DivElement _myRoot;

  UIAgentInfo(DivElement this._myRoot);

  @override HtmlElement    get _firstTabElement => null;
  @override HtmlElement    get _focusElement    => null;
  @override HeadingElement get _header          => null;
  @override DivElement     get _help            => null;
  @override HtmlElement    get _lastTabElement  => null;
  @override HtmlElement    get _root            => _myRoot;

  TableCellElement get _activeCount => _root.querySelector('.active-count');
  ImageElement     get _agentState  => _root.querySelector('.agent-state');
  ImageElement     get _alertState  => _root.querySelector('.alert-state');
  TableCellElement get _pausedCount => _root.querySelector('.paused-count');
  ImageElement     get _portrait    => _root.querySelector('.portrait');

  /**
   * Set the ::active:: count.
   */
  set activeCount (int value) => _activeCount.text = value.toString();

  /**
   * Set the visual representation of the current agents state.
   */
  set agentState (AgentState agentState) {
    switch(agentState) {
      case AgentState.Busy:
        _agentState.src = 'images/agentsactive.svg';
        break;
      case AgentState.Idle:
        /// TODO (TL): Need idle state graphic
        _agentState.src = 'images/agentsactive.svg';
        break;
      case AgentState.Pause:
        _agentState.src = 'images/agentssleep.svg';
        break;
      case AgentState.Unknown:
        /// TODO (TL): Need unknown state graphic
        _agentState.src = 'images/agentsactive.svg';
        break;
    }
  }

  /**
   * Toggle the alert state graphic.
   */
  set alertState (AlertState alertState) {
    switch(alertState) {
      case AlertState.Off:
        /// TODO (TL): Need alert state OFF graphic
        break;
      case AlertState.On:
        _alertState.src = 'images/alert.svg';
        break;
    }
  }

  /**
   * Set the ::paused:: count.
   */
  set pausedCount (int value) => _pausedCount.text = value.toString();

  /**
   * Set the agent portrait. [path] must be a valid source path to an image.
   */
  set portrait (String path) => _portrait.src = path;
}
