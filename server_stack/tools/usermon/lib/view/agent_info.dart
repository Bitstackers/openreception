part of usermon.view;

class AgentInfo {
  final or_model.User _user;

  int _numMessage = 0;

  int get numMessage => _numMessage;
  Set<String> _callshandled = new Set();

  set numMessage(int count) {
    _numMessage = count;
    currentCallCell.text = '$_numMessage';
  }

  set agentStatistics(or_model.AgentStatistics stats) {
    statsCell.text = '${stats.total} kald i dag (${stats.recent} for nyligt)';
  }

  set call(or_model.Call c) {
    _callshandled.add(c.ID);
    if (c.state == or_model.CallState.Hungup ||
        c.state == or_model.CallState.Transferred) {
      currentCallCell.text = '';
      _updateStats();
    } else {
      currentCallCell.text = c.callerID;
    }
  }

  _updateStats() {
    statsCell.text = 'Håndterede kald: ${_callshandled.length}';
  }

  set userStatus(or_model.UserStatus status) {
    stateCell.text = '${status.paused ? 'paused' : 'active'}';

    lastSeenCell.text = '??';

    element.classes
      ..clear()
      ..add('speaking');
  }

  /**
   * Default constructor.
   */
  AgentInfo.fromModel(this._user) {
    ///Base data
    element.id = 'uid_${_user.id}';
    nameCell.text = _user.name;

    ///Setup visual model.
    element.children = [
      nameCell,
      stateCell,
      currentCallCell,
      statsCell,
      lastSeenCell
    ];
  }

  final TableCellElement nameCell = new TableCellElement();
  final TableCellElement stateCell = new TableCellElement();
  final TableCellElement statsCell = new TableCellElement();
  final TableCellElement currentCallCell = new TableCellElement();
  final TableCellElement lastSeenCell = new TableCellElement();

  final TableRowElement element = new TableRowElement();
}
