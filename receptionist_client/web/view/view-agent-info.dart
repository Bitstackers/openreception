part of view;

class AgentInfo {
  static final AgentInfo _singleton = new AgentInfo._internal();
  factory AgentInfo() => _singleton;

  /**
   *
   */
  AgentInfo._internal() {
    _activeCount.text = '0';
    _pausedCount.text = '0';
    _agentState.src = 'images/agentsactive.svg';
    _alertState.src = 'images/alert.svg';
    _face.src = 'images/face.png';

    _registerEventListeners();
  }

  static final DivElement _root = querySelector('#agent-info');

  final TableCellElement _activeCount = _root.querySelector('.active-count');
  final ImageElement     _agentState  = _root.querySelector('.agent-state');
  final ImageElement     _alertState  = _root.querySelector('.alert-state');
  final ImageElement     _face        = _root.querySelector('.face');
  final TableCellElement _pausedCount = _root.querySelector('.paused-count');

  /**
   *
   */
  void _registerEventListeners() {
    // TODO (TL): Stuff...
  }
}
